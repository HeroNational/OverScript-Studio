import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'data/services/storage_service.dart';
import 'presentation/screens/prompter/prompter_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _loadLastText();
  }

  Future<void> _loadLastText() async {
    final storageService = StorageService();
    final lastText = await storageService.loadLastText();
    if (lastText != null) {
      _textController.text = lastText;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _handleSource(SourceData source) async {
    if (source.isPdf && source.pdfPath != null) {
      await ref.read(playbackProvider.notifier).loadPdf(source.pdfPath!);
      _navigateToPrompter();
      return;
    }

    final text = source.text ?? _textController.text;
    if (text.isEmpty) return;

    _textController.text = text;

    final storageService = StorageService();
    await storageService.saveLastText(text);

    ref.read(playbackProvider.notifier).setText(text);
    _navigateToPrompter();
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
            constraints: const BoxConstraints(maxWidth: 800),
            padding: const EdgeInsets.all(48),
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
                  'Collez votre texte ci-dessous',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white70,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _textController,
                    maxLines: null,
                    expands: true,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Collez votre texte ici...',
                      hintStyle: TextStyle(color: Colors.white38),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(24),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _startPrompter,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
