import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'data/services/storage_service.dart';
import 'presentation/screens/prompter/prompter_screen.dart';
import 'presentation/providers/playback_provider.dart';
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
  bool _hasPromptedSource = false;

  @override
  void initState() {
    super.initState();
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

  void _promptSourceDialog() {
    if (_hasPromptedSource || !mounted) return;
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
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Collez ou composez votre texte ci-dessous',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white70,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        quill.QuillSimpleToolbar(
                          controller: _quillController,
                          config: const quill.QuillSimpleToolbarConfig(
                            axis: Axis.horizontal,
                            multiRowsDisplay: true, // évite le scroll/arrow bug
                            showAlignmentButtons: true,
                            showBackgroundColorButton: false,
                            showUndo: true,
                            showRedo: true,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: quill.QuillEditor(
                              controller: _quillController,
                              focusNode: FocusNode(),
                              scrollController: ScrollController(),
                              config: const quill.QuillEditorConfig(
                                scrollable: true,
                                autoFocus: false,
                                expands: true,
                                padding: EdgeInsets.all(12),
                                showCursor: true,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Tooltip(
                        message: 'Choisir une source (fichier, PDF, éditeur)',
                        child: OutlinedButton.icon(
                          onPressed: _promptSourceDialog,
                          icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                          label: const Text(
                            'Choisir une source',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF6366F1)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
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
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          side: BorderSide(color: Colors.white.withOpacity(0.3)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Icon(Icons.settings, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Tooltip(
                        message: 'Lancer le prompteur avec ce texte',
                        child: ElevatedButton(
                          onPressed: () {
                            final json = _quillController.document.toDelta().toJson();
                            _handleSource(
                              SourceData(
                                quillJson: jsonEncode(json),
                                text: _quillController.document.toPlainText(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Démarrer le prompteur',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ),
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
}
