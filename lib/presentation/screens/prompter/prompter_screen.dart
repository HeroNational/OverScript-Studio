import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart' show windowManager;
import '../../providers/playback_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/mobile_toolbar_provider.dart';
import '../../../data/models/settings_model.dart';
import '../../widgets/toolbox/glassmorphic_toolbox.dart';
import '../sources/sources_dialog.dart';
import '../../widgets/app_menu_sheet.dart';
import 'widgets/text_display.dart';
import '../../../data/services/focus_mode_service.dart';
import '../../../data/services/capture_service.dart';

class PrompterScreen extends ConsumerStatefulWidget {
  const PrompterScreen({super.key});

  @override
  ConsumerState<PrompterScreen> createState() => _PrompterScreenState();
}

class _PrompterScreenState extends ConsumerState<PrompterScreen> {
  final FocusNode _focusNode = FocusNode();
  final FocusModeService _focusService = FocusModeService();
  final CaptureService _captureService = CaptureService();
  Timer? _countdownTimer;
  int? _countdown;
  bool _focusModeEnabled = false;
  int _countdownStart = 0;
  bool _recording = false;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();

    // Activer le plein écran automatique si configuré
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settings = ref.read(settingsProvider);
      _focusModeEnabled = settings.enableFocusMode;
      _countdownStart = settings.countdownDuration;
      _startCountdown();
      if (settings.autoFullscreen) {
        await _toggleFullscreen();
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
    _captureService.dispose();
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
    // Keyboard shortcuts not available on mobile platforms
    if (Platform.isAndroid || Platform.isIOS) {
      return;
    }

    // Ignore repeated keydown events to avoid pressed-key assertion
    if (event is KeyRepeatEvent) {
      return;
    }

    if (event is KeyDownEvent) {
      debugPrint('[Keyboard] Key pressed: ${event.logicalKey.keyLabel}');

      // Espace pour play/pause
      if (event.logicalKey == LogicalKeyboardKey.space) {
        debugPrint('[Keyboard] Space pressed - toggling play/pause');
        ref.read(playbackProvider.notifier).togglePlayPause();
      }
      // F pour fullscreen
      else if (event.logicalKey == LogicalKeyboardKey.keyF) {
        debugPrint('[Keyboard] F pressed - toggling fullscreen');
        _toggleFullscreen();
      }
      // Escape pour sortir du fullscreen
      else if (event.logicalKey == LogicalKeyboardKey.escape) {
        debugPrint('[Keyboard] Escape pressed - exiting fullscreen');
        _exitFullscreen();
      }
      // Flèche haut pour augmenter vitesse
      else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        debugPrint('[Keyboard] Arrow Up pressed - increasing speed');
        final currentSpeed = ref.read(playbackProvider).speed;
        ref.read(playbackProvider.notifier).updateSpeed(currentSpeed + 10);
      }
      // Flèche bas pour diminuer vitesse
      else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        debugPrint('[Keyboard] Arrow Down pressed - decreasing speed');
        final currentSpeed = ref.read(playbackProvider).speed;
        ref.read(playbackProvider.notifier).updateSpeed((currentSpeed - 10).clamp(10, 500));
      }
      // R pour reset
      else if (event.logicalKey == LogicalKeyboardKey.keyR) {
        debugPrint('[Keyboard] R pressed - resetting');
        ref.read(playbackProvider.notifier).reset();
      }
    }
  }

  Future<void> _toggleFullscreen() async {
    if (Platform.isAndroid || Platform.isIOS) {
      // Use picture-in-picture on mobile
      await _togglePictureInPicture();
    } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      // Use window_manager for all desktop platforms (macOS, Windows, Linux)
      try {
        final isFullscreen = await windowManager.isFullScreen();
        await windowManager.setFullScreen(!isFullscreen);
      } catch (e) {
        debugPrint('Error toggling fullscreen: $e');
      }
    }
    ref.read(playbackProvider.notifier).toggleFullscreen();
  }

  Future<void> _togglePictureInPicture() async {
    try {
      const platform = MethodChannel('com.overscript.studio/pip');
      await platform.invokeMethod('togglePiP');
    } catch (e) {
      debugPrint('Error toggling picture-in-picture: $e');
    }
  }

  Future<void> _exitFullscreen() async {
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      // Use window_manager for all desktop platforms
      try {
        final isFullscreen = await windowManager.isFullScreen();
        if (isFullscreen) {
          await windowManager.setFullScreen(false);
        }
      } catch (e) {
        debugPrint('Error exiting fullscreen: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final playbackState = ref.watch(playbackProvider);

    return Focus(
      autofocus: true,
      child: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: _handleKeyEvent,
        child: GestureDetector(
          onTap: () {
            // Request focus when tapping anywhere on the screen
            _focusNode.requestFocus();
          },
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

                _buildPositionedToolbars(playbackState.isFullscreen),
              ],
            ),
          ),
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

  Widget _buildPositionedToolbars(bool isFullscreen) {
    final settings = ref.watch(settingsProvider);
    final playback = ref.watch(playbackProvider);
    final mobileOrientation = ref.watch(mobileToolbarOrientationProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobileSize = screenWidth < 500;

    // Determine effective orientation: use mobile override on small screens
    final effectiveOrientation = isMobileSize ? mobileOrientation : settings.toolbarOrientation;

    final isVertical = _isVertical(settings.toolbarPosition, effectiveOrientation, isMobileSize);

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
      onMenuPressed: () {
        print('[UI] Menu (toolbar)');
        _showMenu();
      },
      onFullscreenPressed: () {
        print('[UI] Fullscreen toggle (toolbar)');
        _toggleFullscreen();
      },
      isVertical: isVertical,
      scale: settings.toolbarScale,
      themeStyle: settings.toolboxTheme,
      isMobile: isMobileSize,
      onOrientationToggle: isMobileSize
          ? () {
              print('[UI] Toggle toolbar orientation');
              ref.read(mobileToolbarOrientationProvider.notifier).toggleOrientation();
            }
          : null,
    );

    final dock = _RecordingDock(
      isVertical: isVertical,
      isRecording: _recording,
      onPlay: () => ref.read(playbackProvider.notifier).play(),
      onPause: () => ref.read(playbackProvider.notifier).pause(),
      onRecord: _toggleRecord,
    );

    final grouped = Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        toolbox,
        dock,
      ],
    );

    switch (settings.toolbarPosition) {
      case ToolbarPosition.top:
        return Positioned(
          top: 16,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Center(child: grouped),
          ),
        );
      case ToolbarPosition.topCenter:
        return Positioned(
          top: 16,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Center(child: grouped),
          ),
        );
      case ToolbarPosition.bottom:
        return Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Center(child: grouped),
          ),
        );
      case ToolbarPosition.bottomCenter:
        return Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Center(child: grouped),
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
              child: grouped,
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
              child: grouped,
            ),
          ),
        );
      case ToolbarPosition.topLeft:
        return Positioned(
          top: 16,
          left: 16,
          child: SafeArea(child: grouped),
        );
      case ToolbarPosition.topRight:
        return Positioned(
          top: 16,
          right: 16,
          child: SafeArea(child: grouped),
        );
      case ToolbarPosition.bottomLeft:
        return Positioned(
          bottom: 16,
          left: 16,
          child: SafeArea(child: grouped),
        );
      case ToolbarPosition.bottomRight:
        return Positioned(
          bottom: 16,
          right: 16,
          child: SafeArea(child: grouped),
        );
    }
  }

  bool _isVertical(ToolbarPosition position, ToolbarOrientation orientation, bool isMobileSize) {
    // Sur mobile: toujours horizontal en haut/bas
    if (isMobileSize && (position == ToolbarPosition.top ||
        position == ToolbarPosition.topCenter ||
        position == ToolbarPosition.bottom ||
        position == ToolbarPosition.bottomCenter)) {
      return false;
    }

    // Respect explicite de l'orientation utilisateur
    if (orientation == ToolbarOrientation.horizontal) return false;
    if (orientation == ToolbarOrientation.vertical) return true;

    // auto : vertical si latéral ou coin, horizontal pour haut/bas centré
    return position == ToolbarPosition.left ||
        position == ToolbarPosition.right ||
        position == ToolbarPosition.topLeft ||
        position == ToolbarPosition.bottomLeft ||
        position == ToolbarPosition.topRight ||
        position == ToolbarPosition.bottomRight;
  }

  void _showMenu() {
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

  Future<void> _toggleRecord() async {
    if (_recording) {
      await _captureService.stopCapture();
      setState(() => _recording = false);
      return;
    }
    try {
      await _captureService.startCapture();
      setState(() => _recording = true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enregistrement non disponible sur cet appareil.')),
      );
    }
  }
}

class _RecordingDock extends StatelessWidget {
  const _RecordingDock({
    required this.isVertical,
    required this.isRecording,
    required this.onPlay,
    required this.onPause,
    required this.onRecord,
  });

  final bool isVertical;
  final bool isRecording;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final VoidCallback onRecord;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      IconButton(
        tooltip: 'Lecture',
        icon: const Icon(Icons.play_arrow, color: Colors.white),
        onPressed: onPlay,
      ),
      IconButton(
        tooltip: 'Pause',
        icon: const Icon(Icons.pause, color: Colors.white),
        onPressed: onPause,
      ),
      IconButton(
        tooltip: isRecording ? 'Stop' : 'Rec',
        icon: Icon(
          isRecording ? Icons.stop : Icons.fiber_manual_record,
          color: isRecording ? Colors.redAccent : Colors.red,
        ),
        onPressed: onRecord,
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: isVertical
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: children,
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: children,
            ),
    );
  }
}
