import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'data/services/storage_service.dart';
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
    title: 'OverScript Studio',
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(
    ProviderScope(
      child: PrompterApp(
        navigatorKey: _appNavigatorKey,
      ),
    ),
  );
}

// Navigator global pour éviter l'accès à un context désactivé
final GlobalKey<NavigatorState> _appNavigatorKey = GlobalKey<NavigatorState>();

class PrompterApp extends ConsumerWidget {
  const PrompterApp({super.key, required this.navigatorKey});

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return MaterialApp(
      title: 'OverScript Studio',
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
  final List<String> _bannerAssets = const [
    'assets/banner_texture.jpg',
    'assets/banner_texture_2.jpg',
    'assets/banner_texture_3.jpg',
  ];
  late final String _bannerAsset;
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
    super.dispose();
  }

  void _promptSourceDialog({bool force = false}) {
    if (!force && (_hasPromptedSource || !mounted)) return;
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

  void _navigateToPrompter() {
    if (!mounted) return;
    print('[UI] Navigation vers PrompterScreen');
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
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1000),
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'OverScript Studio',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.welcomeSubtitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white70,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
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
                  ],
                ),
                // Bannière illustrative
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    print('[UI] Tap banner add source');
                    _promptSourceDialog(force: true);
                  },
                  child: Container(
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
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.15),
                            border: Border.all(color: Colors.white.withOpacity(0.45), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.35),
                                blurRadius: 18,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 42),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppLocalizations.of(context)!.addSource,
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Boutons d’action (paramètres uniquement)
                Align(
                  alignment: Alignment.centerRight,
                  child: Tooltip(
                    message: AppLocalizations.of(context)!.settings,
                    child: OutlinedButton(
                      onPressed: () {
                        print('[UI] Open settings');
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
                ),
                const SizedBox(height: 24),
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
                            '© ${DateTime.now().year} OverLimits Digital Enterprise',
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
                            child: const Text(
                              'CGU',
                              style: TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Column(
                        children: const [
                          Text(
                            'Réalisé par Jacobin Fokou pour OverLimits Digital Enterprise',
                            style: TextStyle(color: Colors.white54, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'GitHub: github.com/HeroNational',
                            style: TextStyle(color: Colors.white54, fontSize: 12),
                            textAlign: TextAlign.center,
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
    );
  }

  String _tr(SettingsModel settings, String fr, String en) {
    return settings.locale.toLowerCase().startsWith('en') ? en : fr;
  }
}

class CguPage extends StatelessWidget {
  const CguPage({super.key});

  Future<String> _loadCgu() async {
    return rootBundle.loadString('assets/cgu.md');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CGU'),
        backgroundColor: const Color(0xFF111827),
      ),
      body: FutureBuilder<String>(
        future: _loadCgu(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Impossible de charger les CGU.',
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
