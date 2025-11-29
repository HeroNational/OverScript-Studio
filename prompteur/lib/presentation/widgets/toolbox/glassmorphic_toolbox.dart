import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../data/models/playback_state.dart';
import '../../providers/playback_provider.dart';

class GlasmorphicToolbox extends ConsumerWidget {
  final VoidCallback onSourcesPressed;
  final VoidCallback onSettingsPressed;
  final VoidCallback onFullscreenPressed;

  const GlasmorphicToolbox({
    super.key,
    required this.onSourcesPressed,
    required this.onSettingsPressed,
    required this.onFullscreenPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playbackState = ref.watch(playbackProvider);

    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 26,
            offset: const Offset(0, 16),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.18),
                  Colors.white.withOpacity(0.07),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.25),
                width: 1.5,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PlaybackPanel(playbackState: playbackState),
                const SizedBox(width: 16),
                Container(
                  width: 1,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.0),
                        Colors.white.withOpacity(0.35),
                        Colors.white.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                _ActionsPanel(
                  onSourcesPressed: onSourcesPressed,
                  onSettingsPressed: onSettingsPressed,
                  onFullscreenPressed: onFullscreenPressed,
                  isFullscreen: playbackState.isFullscreen,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaybackPanel extends ConsumerWidget {
  final PlaybackState playbackState;

  const _PlaybackPanel({required this.playbackState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6366F1).withOpacity(0.3),
            const Color(0xFF8B5CF6).withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _GlassButton(
            icon: LucideIcons.skip_back,
            onPressed: () => ref.read(playbackProvider.notifier).reset(),
            tooltip: 'Réinitialiser',
            size: 20,
          ),
          const SizedBox(width: 12),

          // Play/Pause
          _GlassButton(
            icon: playbackState.isPlaying ? LucideIcons.pause : LucideIcons.play,
            onPressed: () => ref.read(playbackProvider.notifier).togglePlayPause(),
            tooltip: playbackState.isPlaying ? 'Pause' : 'Lecture',
            size: 28,
            primary: true,
          ),
          const SizedBox(width: 12),

          // Speed indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              '${playbackState.speed.toInt()}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionsPanel extends StatelessWidget {
  final VoidCallback onSourcesPressed;
  final VoidCallback onSettingsPressed;
  final VoidCallback onFullscreenPressed;
  final bool isFullscreen;

  const _ActionsPanel({
    required this.onSourcesPressed,
    required this.onSettingsPressed,
    required this.onFullscreenPressed,
    required this.isFullscreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFEC4899).withOpacity(0.3),
            const Color(0xFFF59E0B).withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEC4899).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _GlassButton(
            icon: LucideIcons.circle_plus,
            onPressed: onSourcesPressed,
            tooltip: 'Ajouter une source',
            size: 24,
          ),
          const SizedBox(width: 16),
          _GlassButton(
            icon: isFullscreen ? LucideIcons.minimize_2 : LucideIcons.maximize_2,
            onPressed: onFullscreenPressed,
            tooltip: isFullscreen ? 'Quitter le plein écran' : 'Plein écran',
            size: 24,
          ),
          const SizedBox(width: 16),
          _GlassButton(
            icon: LucideIcons.settings,
            onPressed: onSettingsPressed,
            tooltip: 'Paramètres',
            size: 24,
          ),
        ],
      ),
    );
  }
}

class _GlassButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final double size;
  final bool primary;

  const _GlassButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.size = 24,
    this.primary = false,
  });

  @override
  State<_GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<_GlassButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onPressed,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 160),
            scale: _isHovered ? 1.05 : 1.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(widget.primary ? 12 : 8),
              decoration: BoxDecoration(
                color: _isHovered
                    ? Colors.white.withOpacity(0.22)
                    : Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(widget.primary ? 12 : 8),
                border: Border.all(
                  color: _isHovered
                      ? Colors.white.withOpacity(0.45)
                      : Colors.white.withOpacity(0.25),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(_isHovered ? 0.28 : 0.18),
                    blurRadius: _isHovered ? 14 : 10,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                widget.icon,
                size: widget.size,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
