import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'data/services/storage_service.dart';
import 'data/services/youtube_subtitle_service.dart';
import 'data/models/settings_model.dart';
import 'presentation/screens/prompter/prompter_screen.dart';
import 'presentation/providers/playback_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/screens/sources/sources_dialog.dart';
import 'presentation/screens/settings/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Hive pour le stockage
  await StorageService.init();

  // Configurer window_manager
  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(1200, 800),
    minimumSize: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    title: 'Prompteur Pro',
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(
    const ProviderScope(
      child: PrompterApp(),
    ),
  );
}

class PrompterApp extends StatelessWidget {
  const PrompterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prompteur Pro',
      debugShowCheckedModeBanner: false,
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
  final TextEditingController _youtubeController = TextEditingController();
  final YoutubeSubtitleService _youtubeService = YoutubeSubtitleService();
  final List<String> _bannerAssets = const [
    'assets/banner_texture.jpg',
    'assets/banner_texture_2.jpg',
    'assets/banner_texture_3.jpg',
  ];
  late final String _bannerAsset;
  bool _isLoadingYoutube = false;
  bool _hasPromptedSource = false;

  @override
  void initState() {
    super.initState();
    _bannerAsset = _bannerAssets[math.Random().nextInt(_bannerAssets.length)];
    _loadLastText().then((_) => _promptSourceDialog());
  }

  Future<void> _loadLastText() async {
    final storageService = StorageService();
    final lastText = await storageService.loadLastText();
    if (lastText != null) {
      _textController.text = lastText;
      _setQuillPlainText(lastText);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _quillController.dispose();
    _youtubeController.dispose();
    _youtubeService.dispose();
    super.dispose();
  }

  void _promptSourceDialog({bool force = false}) {
    if (!force && (_hasPromptedSource || !mounted)) return;
    _hasPromptedSource = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) => SourcesDialog(
          onSourceSelected: (source) {
            Navigator.pop(context);
            _handleSource(source);
          },
          initialText: _quillController.document.toPlainText(),
          initialQuillJson: jsonEncode(_quillController.document.toDelta().toJson()),
        ),
      );
    });
  }

  Future<void> _handleSource(SourceData source) async {
    if (source.isPdf && source.pdfPath != null) {
      await ref.read(playbackProvider.notifier).loadPdf(source.pdfPath!);
      _navigateToPrompter();
      return;
    }

    if (source.isRichText && source.quillJson != null) {
      ref.read(playbackProvider.notifier).setRichText(source.quillJson!);
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
    }
    _navigateToPrompter();
  }

  void _setQuillPlainText(String text) {
    final replaceLen = math.max(0, _quillController.document.length - 1);
    _quillController.document.replace(0, replaceLen, '$text\n');
  }

  void _navigateToPrompter() {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PrompterScreen(),
      ),
    );
  }

  Future<void> _toggleFullscreen() async {
    final isFullscreen = await windowManager.isFullScreen();
    await windowManager.setFullScreen(!isFullscreen);
    ref.read(playbackProvider.notifier).toggleFullscreen();
  }

  @override
  Widget build(BuildContext context) {
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
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1000),
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Prompteur Pro',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Imports rapides : Fichiers, PDF ou sous-titres YouTube',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white70,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Bannière illustrative
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(_bannerAsset),
                      fit: BoxFit.cover,
                      opacity: 0.35,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1F2937),
                        Color(0xFF111827),
                      ],
                    ),
                    border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.tv, color: Colors.white, size: 48),
                      SizedBox(height: 12),
                      Text(
                        'Diffusez vos prompts sans distraction',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Bloc YouTube
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Importer depuis YouTube',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _youtubeController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'URL de la vidéo YouTube',
                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.06),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF6366F1)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: _isLoadingYoutube ? null : _importFromYoutube,
                            icon: _isLoadingYoutube
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.cloud_download, size: 18),
                            label: const Text('Importer'),
                            style: primaryButton.copyWith(
                              padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
                              minimumSize: MaterialStateProperty.all(const Size(0, 56)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Boutons d’action
                Row(
                  children: [
                    Expanded(
                      child: Tooltip(
                        message: 'Choisir une source (fichier, PDF, éditeur)',
                        child: ElevatedButton.icon(
                          onPressed: () => _promptSourceDialog(force: true),
                          icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                          label: const Text(
                            'Choisir une source',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                          style: primaryButton,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Tooltip(
                      message: 'Paramètres',
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        },
                        style: subtleButton,
                        child: const Icon(Icons.settings, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _importFromYoutube() async {
    final url = _youtubeController.text.trim();
    if (url.isEmpty) return;
    setState(() {
      _isLoadingYoutube = true;
    });
    try {
      final settings = ref.read(settingsProvider);
      final lang = settings.locale.startsWith('en') ? 'en' : 'fr';
      final text = await _youtubeService.fetchPlainSubtitles(url, languageCode: lang);
      _textController.text = text;
      _setQuillPlainText(text);
      _handleSource(SourceData(text: text));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible de récupérer les sous-titres : $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingYoutube = false;
        });
      }
    }
  }

  String _tr(SettingsModel settings, String fr, String en) {
    return settings.locale.toLowerCase().startsWith('en') ? en : fr;
  }
}
