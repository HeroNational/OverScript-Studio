import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../data/models/playback_state.dart';
import '../../../data/models/settings_model.dart';
import '../../providers/playback_provider.dart';

class GlasmorphicToolbox extends ConsumerWidget {
  final VoidCallback onSourcesPressed;
  final VoidCallback onSettingsPressed;
  final VoidCallback onFullscreenPressed;
  final bool isVertical;
  final double scale;
  final ToolboxTheme themeStyle;

  const GlasmorphicToolbox({
    super.key,
    required this.onSourcesPressed,
    required this.onSettingsPressed,
    required this.onFullscreenPressed,
    required this.isVertical,
    required this.scale,
    required this.themeStyle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playbackState = ref.watch(playbackProvider);
    final palette = _paletteFor(themeStyle);
    final baseRadius = 24.0 * scale;

    return Transform.scale(
      scale: scale,
      alignment: Alignment.center,
      child: Container(
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(baseRadius),
          boxShadow: [
            BoxShadow(
              color: palette.shadowColor,
              blurRadius: 26 * scale,
              offset: Offset(0, 16 * scale),
            ),
          ],
          border: Border.all(
            color: palette.borderColor,
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(baseRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    palette.surfaceStart,
                    palette.surfaceEnd,
                  ],
                ),
                borderRadius: BorderRadius.circular(baseRadius),
                border: Border.all(
                  color: palette.borderStrong,
                  width: 1.5,
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 16 * scale),
              child: isVertical
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _PlaybackPanel(playbackState: playbackState, palette: palette, scale: scale, isVertical: isVertical),
                        SizedBox(height: 12 * scale),
                        _Divider(isVertical: true, palette: palette, scale: scale),
                        SizedBox(height: 12 * scale),
                        _ActionsPanel(
                          onSourcesPressed: onSourcesPressed,
                          onSettingsPressed: onSettingsPressed,
                          onFullscreenPressed: onFullscreenPressed,
                          isFullscreen: playbackState.isFullscreen,
                          palette: palette,
                          scale: scale,
                          isVertical: isVertical,
                        ),
                      ],
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _PlaybackPanel(playbackState: playbackState, palette: palette, scale: scale, isVertical: isVertical),
                        SizedBox(width: 16 * scale),
                        _Divider(isVertical: false, palette: palette, scale: scale),
                        SizedBox(width: 16 * scale),
                        _ActionsPanel(
                          onSourcesPressed: onSourcesPressed,
                          onSettingsPressed: onSettingsPressed,
                          onFullscreenPressed: onFullscreenPressed,
                          isFullscreen: playbackState.isFullscreen,
                          palette: palette,
                          scale: scale,
                          isVertical: isVertical,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaybackPanel extends ConsumerWidget {
  final PlaybackState playbackState;
   final _ToolboxPalette palette;
   final double scale;
   final bool isVertical;

  const _PlaybackPanel({
    required this.playbackState,
    required this.palette,
    required this.scale,
    required this.isVertical,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 12 * scale),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            palette.primary.withOpacity(0.3),
            palette.secondary.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(
          color: palette.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: isVertical
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: _buildButtons(ref),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: _buildButtons(ref),
            ),
    );
  }

  List<Widget> _buildButtons(WidgetRef ref) {
    final spacing = SizedBox(width: isVertical ? 0 : 12 * scale, height: isVertical ? 12 * scale : 0);
    return [
      _GlassButton(
        icon: LucideIcons.skip_back,
        onPressed: () => ref.read(playbackProvider.notifier).reset(),
        tooltip: 'Réinitialiser',
        size: 20 * scale,
      ),
      spacing,
      _GlassButton(
        icon: playbackState.isPlaying ? LucideIcons.pause : LucideIcons.play,
        onPressed: () => ref.read(playbackProvider.notifier).togglePlayPause(),
        tooltip: playbackState.isPlaying ? 'Pause' : 'Lecture',
        size: 28 * scale,
        primary: true,
      ),
      spacing,
      Container(
        padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8 * scale),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Text(
          '${playbackState.speed.toInt()}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14 * scale,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ];
  }
}

class _ActionsPanel extends StatelessWidget {
  final VoidCallback onSourcesPressed;
  final VoidCallback onSettingsPressed;
  final VoidCallback onFullscreenPressed;
  final bool isFullscreen;
  final _ToolboxPalette palette;
  final double scale;
  final bool isVertical;

  const _ActionsPanel({
    required this.onSourcesPressed,
    required this.onSettingsPressed,
    required this.onFullscreenPressed,
    required this.isFullscreen,
    required this.palette,
    required this.scale,
    required this.isVertical,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 12 * scale),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            palette.accent.withOpacity(0.3),
            palette.highlight.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(
          color: palette.accent.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: isVertical
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: _buildButtons(),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: _buildButtons(),
            ),
    );
  }

  List<Widget> _buildButtons() {
    final spacing = SizedBox(width: isVertical ? 0 : 16 * scale, height: isVertical ? 12 * scale : 0);
    return [
      _GlassButton(
        icon: LucideIcons.circle_plus,
        onPressed: onSourcesPressed,
        tooltip: 'Ajouter une source',
        size: 24 * scale,
      ),
      spacing,
      _GlassButton(
        icon: isFullscreen ? LucideIcons.minimize_2 : LucideIcons.maximize_2,
        onPressed: onFullscreenPressed,
        tooltip: isFullscreen ? 'Quitter le plein écran' : 'Plein écran',
        size: 24 * scale,
      ),
      spacing,
      _GlassButton(
        icon: LucideIcons.settings,
        onPressed: onSettingsPressed,
        tooltip: 'Paramètres',
        size: 24 * scale,
      ),
    ];
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

class _Divider extends StatelessWidget {
  final bool isVertical;
  final _ToolboxPalette palette;
  final double scale;

  const _Divider({
    required this.isVertical,
    required this.palette,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isVertical ? 60 * scale : 1,
      height: isVertical ? 1 : 60 * scale,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: isVertical ? Alignment.centerLeft : Alignment.topCenter,
          end: isVertical ? Alignment.centerRight : Alignment.bottomCenter,
          colors: [
            palette.dividerStart,
            palette.dividerMid,
            palette.dividerEnd,
          ],
        ),
      ),
    );
  }
}

class _ToolboxPalette {
  final Color surfaceStart;
  final Color surfaceEnd;
  final Color borderColor;
  final Color borderStrong;
  final Color shadowColor;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color highlight;
  final Color dividerStart;
  final Color dividerMid;
  final Color dividerEnd;

  const _ToolboxPalette({
    required this.surfaceStart,
    required this.surfaceEnd,
    required this.borderColor,
    required this.borderStrong,
    required this.shadowColor,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.highlight,
    required this.dividerStart,
    required this.dividerMid,
    required this.dividerEnd,
  });
}

_ToolboxPalette _paletteFor(ToolboxTheme theme) {
  switch (theme) {
    case ToolboxTheme.glass:
      return _ToolboxPalette(
        surfaceStart: Colors.white.withOpacity(0.18),
        surfaceEnd: Colors.white.withOpacity(0.07),
        borderColor: Colors.white.withOpacity(0.08),
        borderStrong: Colors.white.withOpacity(0.25),
        shadowColor: Colors.black.withOpacity(0.2),
        primary: const Color(0xFF4F46E5),
        secondary: const Color(0xFF7C3AED),
        accent: const Color(0xFFEC4899),
        highlight: const Color(0xFFF59E0B),
        dividerStart: Colors.white.withOpacity(0.0),
        dividerMid: Colors.white.withOpacity(0.35),
        dividerEnd: Colors.white.withOpacity(0.0),
      );
    case ToolboxTheme.contrast:
      return _ToolboxPalette(
        surfaceStart: const Color(0xFF0F172A).withOpacity(0.85),
        surfaceEnd: const Color(0xFF111827).withOpacity(0.9),
        borderColor: const Color(0xFF0EA5E9).withOpacity(0.3),
        borderStrong: const Color(0xFF0EA5E9).withOpacity(0.6),
        shadowColor: Colors.black.withOpacity(0.35),
        primary: const Color(0xFF06B6D4),
        secondary: const Color(0xFF0EA5E9),
        accent: const Color(0xFF22D3EE),
        highlight: const Color(0xFF0EA5E9),
        dividerStart: const Color(0xFF22D3EE).withOpacity(0.0),
        dividerMid: const Color(0xFF22D3EE).withOpacity(0.6),
        dividerEnd: const Color(0xFF22D3EE).withOpacity(0.0),
      );
    case ToolboxTheme.modern:
    default:
      return _ToolboxPalette(
        surfaceStart: const Color(0xFF1F2937).withOpacity(0.6),
        surfaceEnd: const Color(0xFF111827).withOpacity(0.6),
        borderColor: Colors.white.withOpacity(0.08),
        borderStrong: Colors.white.withOpacity(0.25),
        shadowColor: Colors.black.withOpacity(0.25),
        primary: const Color(0xFF6366F1),
        secondary: const Color(0xFF8B5CF6),
        accent: const Color(0xFFEC4899),
        highlight: const Color(0xFFF59E0B),
        dividerStart: Colors.white.withOpacity(0.0),
        dividerMid: Colors.white.withOpacity(0.35),
        dividerEnd: Colors.white.withOpacity(0.0),
      );
  }
}
