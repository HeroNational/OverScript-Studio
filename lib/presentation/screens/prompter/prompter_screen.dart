import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import '../../providers/playback_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/controls/playback_controls.dart';
import '../../widgets/controls/speed_control.dart';
import 'widgets/text_display.dart';

class PrompterScreen extends ConsumerStatefulWidget {
  const PrompterScreen({super.key});

  @override
  ConsumerState<PrompterScreen> createState() => _PrompterScreenState();
}

class _PrompterScreenState extends ConsumerState<PrompterScreen> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    final settings = ref.read(settingsProvider);

    if (event is KeyDownEvent) {
      // Espace pour play/pause
      if (event.logicalKey == LogicalKeyboardKey.space) {
        ref.read(playbackProvider.notifier).togglePlayPause();
      }
      // F pour fullscreen
      else if (event.logicalKey == LogicalKeyboardKey.keyF) {
        _toggleFullscreen();
      }
      // Escape pour sortir du fullscreen
      else if (event.logicalKey == LogicalKeyboardKey.escape) {
        _exitFullscreen();
      }
      // Flèche haut pour augmenter vitesse
      else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        final currentSpeed = ref.read(playbackProvider).speed;
        ref.read(playbackProvider.notifier).updateSpeed(currentSpeed + 10);
      }
      // Flèche bas pour diminuer vitesse
      else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        final currentSpeed = ref.read(playbackProvider).speed;
        ref.read(playbackProvider.notifier).updateSpeed((currentSpeed - 10).clamp(10, 500));
      }
      // R pour reset
      else if (event.logicalKey == LogicalKeyboardKey.keyR) {
        ref.read(playbackProvider.notifier).reset();
      }
    }
  }

  Future<void> _toggleFullscreen() async {
    final isFullscreen = await windowManager.isFullScreen();
    if (isFullscreen) {
      await windowManager.setFullScreen(false);
    } else {
      await windowManager.setFullScreen(true);
    }
    ref.read(playbackProvider.notifier).toggleFullscreen();
  }

  Future<void> _exitFullscreen() async {
    final isFullscreen = await windowManager.isFullScreen();
    if (isFullscreen) {
      await windowManager.setFullScreen(false);
      ref.read(playbackProvider.notifier).toggleFullscreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final playbackState = ref.watch(playbackProvider);

    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        body: Stack(
          children: [
            // Affichage du texte
            const TextDisplay(),

            // Barre de contrôle en bas
            if (!playbackState.isFullscreen)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const PlaybackControls(),
                      const SizedBox(height: 16),
                      const SpeedControl(),
                      const SizedBox(height: 16),
                      Text(
                        'Raccourcis: Espace=Play/Pause  F=Plein écran  ↑↓=Vitesse  R=Reset',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Toolbar minimale en mode plein écran
            if (playbackState.isFullscreen)
              Positioned(
                bottom: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const PlaybackControls(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
