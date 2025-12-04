import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:camera/camera.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'dart:io' show Platform, File;
import 'dart:convert';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:async';
import 'data/services/storage_service.dart';
import 'data/services/capture_service.dart';
import 'package:open_filex/open_filex.dart';
import 'data/models/settings_model.dart';
import 'presentation/screens/prompter/prompter_screen.dart';
import 'presentation/providers/playback_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/screens/sources/sources_dialog.dart';
import 'presentation/screens/settings/settings_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'presentation/widgets/app_menu_sheet.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Hive pour le stockage
  await StorageService.init();

  // Configurer window_manager uniquement sur desktop
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    try {
      await _initializeDesktop();
    } catch (e) {
      debugPrint('Erreur initialisation desktop: $e');
    }
  }

  runApp(
    ProviderScope(
      child: PrompterApp(
        navigatorKey: _appNavigatorKey,
      ),
    ),
  );
}

/// Initialise les fonctionnalités desktop
/// Cette fonction s'exécute seulement sur Windows/macOS/Linux
Future<void> _initializeDesktop() async {
  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    minimumSize: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}

// Navigator global pour éviter l'accès à un context désactivé
final GlobalKey<NavigatorState> _appNavigatorKey = GlobalKey<NavigatorState>();

class PrompterApp extends ConsumerWidget {
  const PrompterApp({super.key, required this.navigatorKey});

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context);
    return MaterialApp(
      title: l10n?.appTitle ?? 'OverScript Studio',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      locale: Locale(settings.locale),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        sliderTheme: SliderThemeData(
          activeTrackColor: const Color(0xFF8B5CF6),
          thumbColor: const Color(0xFF6366F1),
          overlayColor: const Color(0xFF6366F1).withOpacity(0.2),
        ),
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        quill.FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
      ],
      home: const PrompterHome(),
    );
  }
}

class PrompterHome extends ConsumerStatefulWidget {
  const PrompterHome({super.key});

  @override
  ConsumerState<PrompterHome> createState() => _PrompterHomeState();
}

class _PrompterHomeState extends ConsumerState<PrompterHome> {
  final TextEditingController _textController = TextEditingController();
  final quill.QuillController _quillController = quill.QuillController.basic();
  final CaptureService _captureService = CaptureService();
  final List<String> _bannerAssets = const [
    'assets/banner_texture.jpg',
    'assets/banner_texture_2.jpg',
    'assets/banner_texture_3.jpg',
  ];
  late final String _bannerAsset;
  bool _hasPromptedSource = false;
  bool _trialEnabled = false;
  bool _trialExpired = false;
  int _trialDaysLeft = 0;
  DateTime? _trialExpiry;
  List<CaptureDeviceInfo> _cams = const [];
  List<CaptureDeviceInfo> _mics = const [];
  String? _selectedCam;
  String? _selectedMic;
  bool _previewing = false;
  double _fakeAudioLevel = 0.2;
  Timer? _audioMeterTimer;
  List<File> _recordings = [];

  @override
  void initState() {
    super.initState();
    _bannerAsset = _bannerAssets[math.Random().nextInt(_bannerAssets.length)];
    _computeTrialStatus();
    if (Platform.isAndroid || Platform.isIOS) {
      _requestMobilePermissions().then((granted) {
        if (granted && mounted) {
          _startHomePreview(auto: true);
        }
      });
    } else {
      _startHomePreview(auto: true);
    }
    _loadLastText().then((_) {
      if (!_trialExpired) {
        _promptSourceDialog();
      }
    });
    _loadDevices();
    _refreshRecordings();
    // Démarrer une preview par défaut
    _startHomePreview(auto: true);
  }

  void _computeTrialStatus() {
    const bool enableTrial = bool.fromEnvironment('TRIAL_ENABLED', defaultValue: true);
    const String startIso = String.fromEnvironment('TRIAL_START', defaultValue: '');
    const int durationDays = int.fromEnvironment('TRIAL_DAYS', defaultValue: 90);

    _trialEnabled = enableTrial;
    if (!enableTrial) return;

    DateTime startDate;
    if (startIso.isNotEmpty) {
      startDate = DateTime.tryParse(startIso) ?? DateTime.now();
    } else {
      startDate = DateTime.now();
    }
    _trialExpiry = startDate.add(Duration(days: durationDays));
    final now = DateTime.now();
    _trialExpired = now.isAfter(_trialExpiry!);
    _trialDaysLeft = _trialExpired ? 0 : _trialExpiry!.difference(now).inDays + 1;
  }

  Future<void> _loadDevices() async {
    try {
      final cams = await _captureService.listVideoDevices();
      final mics = await _captureService.listAudioDevices();
      setState(() {
        _cams = cams;
        _mics = mics;
        _selectedCam = cams.isNotEmpty ? cams.first.id : null;
        _selectedMic = mics.isNotEmpty ? mics.first.id : null;
      });
    } catch (_) {
      // ignore loading errors
    }
  }

  Future<bool> _requestMobilePermissions() async {
    if (!(Platform.isAndroid || Platform.isIOS)) return false;
    final ok = await _captureService.requestPermissions();
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Autorisez l’accès Caméra/Micro dans Réglages pour activer la preview.')),
      );
    }
    return ok;
  }

  Future<void> _loadLastText() async {
    final storageService = StorageService();
    final lastText = await storageService.loadLastText();
    final settings = ref.read(settingsProvider);
    if (lastText != null) {
      _textController.text = lastText;
      _setQuillPlainText(lastText);
    } else {
      _maybeInjectMockText(settings);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _quillController.dispose();
    _audioMeterTimer?.cancel();
    _captureService.dispose();
    super.dispose();
  }

  void _promptSourceDialog({bool force = false}) {
    if (!force && (_hasPromptedSource || !mounted)) return;
    if (_trialEnabled && _trialExpired) {
      _showTrialExpiredMessage();
      return;
    }
    _hasPromptedSource = true;
    final navigator = _appNavigatorKey.currentState;
    print('[UI] Open source dialog');
    showDialog<SourceData>(
      context: context,
      useRootNavigator: true,
      builder: (context) => SourcesDialog(
        onSourceSelected: (source) {
          print('[UI] Source selected: $source');
          navigator?.pop(source);
        },
        initialText: _quillController.document.toPlainText(),
        initialQuillJson: jsonEncode(_quillController.document.toDelta().toJson()),
      ),
    ).then((source) {
      if (source != null) {
        _handleSource(source);
      }
    });
  }

  Future<void> _handleSource(SourceData source) async {
    if (_trialEnabled && _trialExpired) {
      _showTrialExpiredMessage();
      return;
    }
    print('[UI] Handle source: pdf=${source.isPdf} rich=${source.isRichText}');
    if (source.isPdf && source.pdfPath != null) {
      await ref.read(playbackProvider.notifier).loadPdf(source.pdfPath!);
      print('[UI] PDF chargé, navigation prompteur');
      _navigateToPrompter();
      return;
    }

    if (source.isRichText && source.quillJson != null) {
      ref.read(playbackProvider.notifier).setRichText(source.quillJson!);
      print('[UI] Rich text chargé');
      // Mettre à jour l'éditeur local avec le texte brut pour cohérence visuelle
      _textController.text = source.text ?? _textController.text;
    } else {
      final text = source.text ?? _textController.text;
      if (text.isEmpty) return;
      _textController.text = text;
      _setQuillPlainText(text);

      final storageService = StorageService();
      await storageService.saveLastText(text);

      ref.read(playbackProvider.notifier).setText(text);
      print('[UI] Texte simple chargé (${text.length} chars)');
    }
    _navigateToPrompter();
  }

  void _setQuillPlainText(String text) {
    final replaceLen = math.max(0, _quillController.document.length - 1);
    _quillController.document.replace(0, replaceLen, '$text\n');
  }

  void _maybeInjectMockText(SettingsModel settings) {
    if (!settings.showMockTextWhenEmpty) return;
    final mock = _pickMockText(settings.mockTextType);
    if (mock == null || mock.isEmpty) return;
    _textController.text = mock;
    _setQuillPlainText(mock);
  }

  String? _pickMockText(MockTextType type) {
    const poems = [
      'Sous le pont Mirabeau coule la Seine\nEt nos amours\nFaut-il qu’il m’en souvienne\nLa joie venait toujours après la peine.\n— Guillaume Apollinaire',
      'Heureux qui, comme Ulysse, a fait un beau voyage,\nOu comme cestuy-là qui conquit la toison,\nEt puis est retourné, plein d’usage et raison,\nVivre entre ses parents le reste de son âge.\n— Joachim du Bellay',
    ];
    const songs = [
      'Ne me quitte pas\nIl faut oublier\nTout peut s’oublier\nQui s’enfuit déjà.\n— Jacques Brel',
      'I’m gonna swing from the chandelier\nFrom the chandelier\nI’m gonna live like tomorrow doesn’t exist\n— Sia',
    ];
    const inspiring = [
      'Ils ne savaient pas que c’était impossible, alors ils l’ont fait. — Mark Twain',
      'Le succès, c’est tomber sept fois, se relever huit. — Proverbe japonais',
      'Start where you are. Use what you have. Do what you can. — Arthur Ashe',
    ];

    List<String> pool;
    switch (type) {
      case MockTextType.none:
        return null;
      case MockTextType.poem:
        pool = poems;
        break;
      case MockTextType.song:
        pool = songs;
        break;
      case MockTextType.inspiring:
        pool = inspiring;
        break;
      case MockTextType.random:
      default:
        pool = [...poems, ...songs, ...inspiring];
        break;
    }
    if (pool.isEmpty) return null;
    return pool[math.Random().nextInt(pool.length)];
  }

  void _navigateToPrompter() {
    if (_trialEnabled && _trialExpired) {
      _showTrialExpiredMessage();
      return;
    }
    if (!mounted) return;
    print('[UI] Navigation vers PrompterScreen');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PrompterScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final primaryButton = ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF6366F1),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
    );

    final subtleButton = OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 18),
      side: BorderSide(color: Colors.white.withOpacity(0.3)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      foregroundColor: Colors.white,
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a1a1a),
              Color(0xFF2d2d2d),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1000),
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                Text(
                  AppLocalizations.of(context)!.homeHeadline,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.homeSubtitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white70,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                if (_trialEnabled)
                  _TrialBanner(
                    expired: _trialExpired,
                    daysLeft: _trialDaysLeft,
                    expiry: _trialExpiry,
                  ),
                const SizedBox(height: 32),
                Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      DropdownButton<String>(
                        value: settings.locale,
                        dropdownColor: const Color(0xFF1f2937),
                        style: const TextStyle(color: Colors.white),
                        underline: const SizedBox(),
                        items: [
                          DropdownMenuItem(value: 'fr', child: Text(AppLocalizations.of(context)!.french)),
                          DropdownMenuItem(value: 'en', child: Text(AppLocalizations.of(context)!.english)),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            print('[UI] Change locale -> $value');
                            ref.read(settingsProvider.notifier).updateLocale(value);
                          }
                        },
                      ),
                      Tooltip(
                        message: AppLocalizations.of(context)!.addSource,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            print('[UI] Add source (top button)');
                            if (_trialEnabled && _trialExpired) {
                              _showTrialExpiredMessage();
                              return;
                            }
                            _promptSourceDialog(force: true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.add),
                          label: Text(AppLocalizations.of(context)!.addSource),
                        ),
                      ),
                      IconButton(
                        tooltip: AppLocalizations.of(context)!.settings,
                        onPressed: () {
                          print('[UI] Open settings');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.settings, color: Colors.white),
                      ),
                      _buildMenuButton(context),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _buildCameraPreviewCard(context),
                const SizedBox(height: 24),
                if (_recordings.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enregistrements',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      ..._recordings.map(
                        (file) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white.withOpacity(0.08)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.play_circle_outline, color: Colors.white70),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  file.path.split('/').last,
                                  style: const TextStyle(color: Colors.white),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.insert_drive_file, color: Colors.white70),
                                tooltip: 'Ouvrir dans Fichiers',
                                onPressed: () => _openRecording(file),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () => _confirmDelete(file),
                                tooltip: 'Supprimer',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                const Divider(color: Colors.white24, height: 32),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.footerCopyright(DateTime.now().year),
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          const SizedBox(width: 8),
                          const Text('|', style: TextStyle(color: Colors.white38)),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () {
                              print('[UI] Open CGU');
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const CguPage()),
                              );
                            },
                            child: Text(
                              AppLocalizations.of(context)!.legalCgu,
                              style: const TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Column(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.footerBy,
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          InkWell(
                            onTap: () async {
                              final Uri url = Uri.parse('https://linkedin.com/in/jacobindanielfokou');
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url, mode: LaunchMode.externalApplication);
                              }
                            },
                            child: Text(
                              '${AppLocalizations.of(context)!.footerLinkedin}: ${AppLocalizations.of(context)!.footerLinkedinUrl}',
                              style: const TextStyle(
                                color: Color(0xFF8B5CF6),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }

  String _tr(SettingsModel settings, String fr, String en) {
    return settings.locale.toLowerCase().startsWith('en') ? en : fr;
  }

  Widget _buildMenuButton(BuildContext context) {
    return IconButton(
      tooltip: AppLocalizations.of(context)?.settings ?? 'Menu',
      onPressed: () => _showMenu(context),
      icon: const Icon(Icons.menu, color: Colors.white),
    );
  }

  Widget _buildCameraPreviewCard(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isDesktop = !(Platform.isAndroid || Platform.isIOS);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.videocam, color: Colors.white70),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)?.cameraAsBackground ?? 'Caméra',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const Spacer(),
              _buildAudioMeter(),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDeviceDropdown(
                  context,
                  label: 'Caméra',
                  value: _selectedCam,
                  items: _cams,
                  onChanged: (v) {
                    setState(() => _selectedCam = v);
                    if (v != null) {
                      _startHomePreview(auto: false);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDeviceDropdown(
                  context,
                  label: 'Micro',
                  value: _selectedMic,
                  items: _mics,
                  onChanged: (v) {
                    setState(() => _selectedMic = v);
                    if (v != null) {
                      _startHomePreview(auto: false);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      if (!isDesktop && _captureService.hasActiveController && _captureService.controller!.value.isInitialized)
                        CameraPreview(_captureService.controller!)
                      else if (isDesktop && _captureService.desktopRenderer != null)
                        RTCVideoView(
                          _captureService.desktopRenderer!,
                          objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                        )
                      else
                        Center(
                          child: Text(
                            'Preview inactive',
                            style: const TextStyle(color: Colors.white54),
                          ),
                        ),
                      Positioned(
                        left: 8,
                        bottom: 8,
                        child: IconButton(
                          tooltip: _captureService.isRecording ? 'Stop' : 'Rec',
                          icon: Icon(
                            _captureService.isRecording ? Icons.stop : Icons.fiber_manual_record,
                            color: _captureService.isRecording ? Colors.redAccent : Colors.red,
                          ),
                          onPressed: _toggleRecording,
                        ),
                      ),
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: IconButton(
                          tooltip: 'Plein écran',
                          icon: const Icon(Icons.fullscreen, color: Colors.white),
                          onPressed: _openFullscreenPreview,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              runSpacing: 8,
              children: [
                IconButton(
                  tooltip: 'Lecture',
                  onPressed: () => _startHomePreview(auto: false),
                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                ),
                IconButton(
                  tooltip: 'Pause',
                  onPressed: _pausePreview,
                  icon: const Icon(Icons.pause, color: Colors.white),
                ),
                IconButton(
                  tooltip: _captureService.isRecording ? 'Stop' : 'Rec',
                  onPressed: _toggleRecording,
                  icon: Icon(
                    _captureService.isRecording ? Icons.stop : Icons.fiber_manual_record,
                    color: _captureService.isRecording ? Colors.redAccent : Colors.red,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _captureService.isRecording ? 'Enregistrement en cours' : 'Prêt',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceDropdown(
    BuildContext context, {
    required String label,
    required String? value,
    required List<CaptureDeviceInfo> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dropdownColor: const Color(0xFF1f2937),
      style: const TextStyle(color: Colors.white),
      items: items
          .map((d) => DropdownMenuItem(
                value: d.id,
                child: Text(d.label, overflow: TextOverflow.ellipsis),
              ))
          .toList(),
      onChanged: onChanged,
      // Flutter 3.33: utilise initialValue plutôt que value déprécié
      // Note: pour compat compatibilité, on conserve value ici mais la warning est bénin.
    );
  }

  Widget _buildAudioMeter() {
    return Container(
      width: 60,
      height: 12,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: _fakeAudioLevel.clamp(0.05, 1.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFFF59E0B), Color(0xFFEF4444)],
              ),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ),
    );
  }

  void _toggleHomePreview() async {
    if (_previewing) return;
    await _startHomePreview(auto: false);
  }

  void _startAudioMeter() {
    _audioMeterTimer?.cancel();
    _audioMeterTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (!mounted) return;
      setState(() {
        // Oscillation factice pour montrer la variation
        _fakeAudioLevel = 0.2 + math.Random().nextDouble() * 0.8;
      });
    });
  }

  void _stopAudioMeter() {
    _audioMeterTimer?.cancel();
    _audioMeterTimer = null;
    _fakeAudioLevel = 0.2;
  }

  Future<void> _pausePreview() async {
    await _captureService.stopPreview();
    _previewing = false;
    _stopAudioMeter();
    if (mounted) setState(() {});
  }

  Future<void> _refreshRecordings() async {
    final list = await _captureService.listRecordings();
    setState(() {
      _recordings = list.map((e) => File(e.path)).toList();
    });
  }

  Future<void> _openRecording(File file) async {
    final result = await OpenFilex.open(file.path);
    if (result.type != ResultType.done && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible d\'ouvrir le fichier: ${result.message}')),
      );
    }
  }

  Future<void> _toggleRecording() async {
    if (_captureService.isRecording) {
      final path = await _captureService.stopCapture();
      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Enregistrement sauvegardé : $path')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aucun fichier enregistré (desktop non supporté ?)')),
        );
      }
      await _refreshRecordings();
      setState(() {});
      return;
    }
    try {
      await _captureService.startCapture(cameraId: _selectedCam, micId: _selectedMic);
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enregistrement non disponible sur cet appareil.')),
      );
    }
  }

  Future<void> _confirmDelete(File file) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ?'),
        content: Text('Voulez-vous supprimer ${file.path.split('/').last} ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (res == true) {
      await _captureService.deleteRecording(file);
      await _refreshRecordings();
    }
  }

  Future<void> _startHomePreview({required bool auto}) async {
    try {
      await _captureService.startPreview(cameraId: _selectedCam, micId: _selectedMic);
      _previewing = true;
      _startAudioMeter();
      if (mounted) setState(() {});
    } catch (_) {
      _previewing = false;
      _stopAudioMeter();
      if (mounted) setState(() {});
    }
  }

  void _openFullscreenPreview() {
    final isMobile = Platform.isAndroid || Platform.isIOS;
    if (isMobile) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    showDialog(
      context: context,
      builder: (_) {
        final isDesktop = !(Platform.isAndroid || Platform.isIOS);
        return Dialog(
          backgroundColor: Colors.black87,
          insetPadding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100, maxHeight: 700),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                children: [
                  if (!isDesktop && _captureService.hasActiveController && _captureService.controller!.value.isInitialized)
                    CameraPreview(_captureService.controller!)
                  else if (isDesktop && _captureService.desktopRenderer != null)
                    RTCVideoView(
                      _captureService.desktopRenderer!,
                      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    )
                  else
                    const Center(
                      child: Text('Preview inactive', style: TextStyle(color: Colors.white70)),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).whenComplete(() {
      if (isMobile) {
        // Restaure les orientations autorisées après la fermeture du plein écran
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      }
    });
  }

  void _showTrialExpiredMessage() {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.redAccent.shade200,
        content: Text(
          l10n.trialExpiredMessage,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: const AppMenuSheet(),
      ),
    );
  }
}

class _TrialBanner extends StatelessWidget {
  final bool expired;
  final int daysLeft;
  final DateTime? expiry;

  const _TrialBanner({
    required this.expired,
    required this.daysLeft,
    required this.expiry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final expiryStr = expiry != null ? DateFormat.yMMMd().format(expiry!) : '';
    final gradientColors = expired
        ? [Colors.redAccent.withOpacity(0.8), Colors.red.withOpacity(0.7)]
        : [const Color(0xFF10B981), const Color(0xFF3B82F6)];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            expired ? Icons.lock_clock : Icons.timer,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expired ? l10n.trialExpiredTitle : l10n.trialActiveTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  expired
                      ? l10n.trialExpiredMessage
                      : l10n.trialActiveLabel(daysLeft.toString()),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                if (!expired && expiryStr.isNotEmpty)
                  Text(
                    l10n.trialExpiresOn(expiryStr),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CguPage extends ConsumerWidget {
  const CguPage({super.key});

  Future<String> _loadCgu(String locale) async {
    // Charger le fichier CGU en fonction de la langue
    final String fileName = locale.toLowerCase().startsWith('en') ? 'cgu_en.md' : 'cgu_fr.md';
    return rootBundle.loadString('assets/$fileName');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.legalCgu),
        backgroundColor: const Color(0xFF111827),
      ),
      body: FutureBuilder<String>(
        future: _loadCgu(settings.locale),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                l10n.error,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.redAccent),
              ),
            );
          }
          final data = snapshot.data ?? '';
          return Markdown(
            data: data,
            styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
              p: const TextStyle(color: Colors.white),
              h1: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              h2: const TextStyle(color: Colors.white70, fontSize: 20, fontWeight: FontWeight.w600),
              h3: const TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w600),
              listBullet: const TextStyle(color: Colors.white70),
            ),
            padding: const EdgeInsets.all(16),
          );
        },
      ),
      backgroundColor: const Color(0xFF0F172A),
    );
  }
}
