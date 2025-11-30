import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import '../../providers/playback_provider.dart';
import '../../providers/settings_provider.dart';
import '../../../data/models/settings_model.dart';
import '../../widgets/toolbox/glassmorphic_toolbox.dart';
import '../settings/settings_screen.dart';
import '../sources/sources_dialog.dart';
import 'widgets/text_display.dart';
import '../../../data/services/focus_mode_service.dart';

class PrompterScreen extends ConsumerStatefulWidget {
  const PrompterScreen({super.key});

  @override
  ConsumerState<PrompterScreen> createState() => _PrompterScreenState();
}

class _PrompterScreenState extends ConsumerState<PrompterScreen> {
  final FocusNode _focusNode = FocusNode();
  final FocusModeService _focusService = FocusModeService();
  Timer? _countdownTimer;
  int? _countdown;
  bool _focusModeEnabled = false;
  int _countdownStart = 0;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();

    // Activer le plein écran automatique si configuré
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(settingsProvider);
      _focusModeEnabled = settings.enableFocusMode;
      _countdownStart = settings.countdownDuration;
      _startCountdown();
      if (settings.autoFullscreen) {
        _toggleFullscreen();
      }
      if (_focusModeEnabled) {
        _focusService.enable();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    if (_focusModeEnabled) {
      _focusService.disable();
    }
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSource(SourceData source) async {
    if (source.isPdf && source.pdfPath != null) {
      await ref.read(playbackProvider.notifier).loadPdf(source.pdfPath!);
      return;
    }

    if (source.isRichText && source.quillJson != null) {
      ref.read(playbackProvider.notifier).setRichText(source.quillJson!);
    } else {
      final text = source.text ?? '';
      if (text.isNotEmpty) {
        ref.read(playbackProvider.notifier).setText(text);
      }
    }
  }

  void _handleKeyEvent(KeyEvent event) {
    // Ignore repeated keydown events to avoid pressed-key assertion
    if (event is KeyRepeatEvent) {
      return;
    }

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
          fit: StackFit.expand,
          children: [
            // Affichage du texte
            const Positioned.fill(child: TextDisplay()),
            if (_countdown != null)
              Container(
                color: Colors.black.withOpacity(0.55),
                alignment: Alignment.center,
                child: Text(
                  _countdown.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 96,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            _buildPositionedToolbox(playbackState.isFullscreen),
          ],
        ),
      ),
    );
  }

  void _startCountdown() {
    final settings = ref.read(settingsProvider);
    _countdown = settings.countdownDuration;
    if (_countdown != null && _countdown! <= 0) {
      _countdown = null;
      ref.read(playbackProvider.notifier).play();
      return;
    }
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_countdown != null && _countdown! > 1) {
          _countdown = _countdown! - 1;
        } else {
          _countdown = null;
          _countdownTimer?.cancel();
          ref.read(playbackProvider.notifier).play();
        }
      });
    });
  }

  Widget _buildPositionedToolbox(bool isFullscreen) {
    final settings = ref.watch(settingsProvider);
    final playback = ref.watch(playbackProvider);

    final toolbox = GlasmorphicToolbox(
      onHomePressed: () {
        print('[UI] Home (toolbar)');
        _countdownTimer?.cancel();
        ref.read(playbackProvider.notifier).pause();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
          }
        });
      },
      onSourcesPressed: () {
        print('[UI] Sources (toolbar)');
        showDialog<SourceData>(
          context: context,
          useRootNavigator: true,
          builder: (context) => SourcesDialog(
            onSourceSelected: (source) {
              Navigator.of(context, rootNavigator: true).pop(source);
            },
            initialText: playback.currentText,
            initialQuillJson: playback.richContentJson,
          ),
        ).then((source) {
          if (source != null) {
            _handleSource(source);
          }
        });
      },
      onSettingsPressed: () {
        print('[UI] Settings (toolbar)');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SettingsScreen(),
          ),
        );
      },
      onFullscreenPressed: () {
        print('[UI] Fullscreen toggle (toolbar)');
        _toggleFullscreen();
      },
      isVertical: _isVertical(settings.toolbarPosition, settings.toolbarOrientation),
      scale: settings.toolbarScale,
      themeStyle: settings.toolboxTheme,
    );

    switch (settings.toolbarPosition) {
      case ToolbarPosition.top:
        return Positioned(
          top: 16,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Center(child: toolbox),
          ),
        );
      case ToolbarPosition.topCenter:
        return Positioned(
          top: 16,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Center(child: toolbox),
          ),
        );
      case ToolbarPosition.bottom:
        return Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Center(child: toolbox),
          ),
        );
      case ToolbarPosition.bottomCenter:
        return Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Center(child: toolbox),
          ),
        );
      case ToolbarPosition.left:
        return Positioned(
          top: 0,
          bottom: 0,
          left: 16,
          child: SafeArea(
            child: Align(
              alignment: Alignment.centerLeft,
              child: toolbox,
            ),
          ),
        );
      case ToolbarPosition.right:
        return Positioned(
          top: 0,
          bottom: 0,
          right: 16,
          child: SafeArea(
            child: Align(
              alignment: Alignment.centerRight,
              child: toolbox,
            ),
          ),
        );
      case ToolbarPosition.topLeft:
        return Positioned(
          top: 16,
          left: 16,
          child: SafeArea(child: toolbox),
        );
      case ToolbarPosition.topRight:
        return Positioned(
          top: 16,
          right: 16,
          child: SafeArea(child: toolbox),
        );
      case ToolbarPosition.bottomLeft:
        return Positioned(
          bottom: 16,
          left: 16,
          child: SafeArea(child: toolbox),
        );
      case ToolbarPosition.bottomRight:
        return Positioned(
          bottom: 16,
          right: 16,
          child: SafeArea(child: toolbox),
        );
    }
  }

  bool _isVertical(ToolbarPosition position, ToolbarOrientation orientation) {
    if (orientation == ToolbarOrientation.horizontal) return false;
    if (orientation == ToolbarOrientation.vertical) return true;
    // auto : vertical si latéral ou coin ou centre haut/bas
    return position == ToolbarPosition.left ||
        position == ToolbarPosition.right ||
        position == ToolbarPosition.topLeft ||
        position == ToolbarPosition.bottomLeft ||
        position == ToolbarPosition.topRight ||
        position == ToolbarPosition.bottomRight ||
        position == ToolbarPosition.topCenter ||
        position == ToolbarPosition.bottomCenter;
  }
}
