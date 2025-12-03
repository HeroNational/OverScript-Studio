import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:prompteur/l10n/app_localizations.dart';
import '../../../data/models/playback_state.dart';
import '../../../data/models/settings_model.dart';
import '../../providers/playback_provider.dart';

class GlasmorphicToolbox extends ConsumerWidget {
  final VoidCallback onSourcesPressed;
  final VoidCallback onMenuPressed;
  final VoidCallback onFullscreenPressed;
  final VoidCallback onHomePressed;
  final bool isVertical;
  final double scale;
  final ToolboxTheme themeStyle;
  final VoidCallback? onOrientationToggle;
  final bool isMobile;

  const GlasmorphicToolbox({
    super.key,
    required this.onSourcesPressed,
    required this.onMenuPressed,
    required this.onFullscreenPressed,
    required this.onHomePressed,
    required this.scale,
    required this.isVertical,
    required this.themeStyle,
    this.onOrientationToggle,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playbackState = ref.watch(playbackProvider);
    final l10n = AppLocalizations.of(context);
    final palette = _paletteFor(themeStyle);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobileSize = screenWidth < 500;

    // Adaptive sizing: clamp scale to avoid oversizing
    // Mobile: 0.5 - 0.7
    // Desktop: 0.7 - 1.0 (100% remains the current baseline)
    double finalScale = isMobileSize ? scale.clamp(0.5, 0.7) : scale.clamp(0.7, 1.0);
    double adaptiveMargin = isMobileSize ? 12.0 : 24.0;

    final baseRadius = 24.0 * finalScale;
    final renderScale = finalScale;

    return Transform.scale(
      scale: finalScale,
      alignment: Alignment.center,
      child: Container(
        margin: EdgeInsets.all(adaptiveMargin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(baseRadius),
          boxShadow: [
            BoxShadow(
              color: palette.shadowColor.withOpacity(0.7),
              blurRadius: 14 * renderScale,
              offset: Offset(0, 10 * renderScale),
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
              constraints: BoxConstraints(
                maxWidth: isVertical ? double.infinity : 600,
              ),
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
              padding: EdgeInsets.symmetric(horizontal: 10 * renderScale, vertical: 12 * renderScale),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  isVertical
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isMobileSize && onOrientationToggle != null)
                              Padding(
                                padding: EdgeInsets.only(bottom: 8 * renderScale),
                                child: _GlassButton(
                                  icon: LucideIcons.rotate_cw,
                                  onPressed: onOrientationToggle!,
                                  tooltip: l10n?.toggleOrientation ?? 'Changer l\'orientation',
                                  size: 16 * renderScale,
                                ),
                              ),
                            _PlaybackPanel(
                              playbackState: playbackState,
                              l10n: l10n,
                              palette: palette,
                              scale: renderScale,
                              isVertical: true,
                              showTimers: false,
                            ),
                            SizedBox(height: 8 * renderScale),
                            _Divider(isVertical: true, palette: palette, scale: renderScale),
                            SizedBox(height: 8 * renderScale),
                            _ActionsPanel(
                              onHomePressed: onHomePressed,
                              onSourcesPressed: onSourcesPressed,
                              onMenuPressed: onMenuPressed,
                              onFullscreenPressed: onFullscreenPressed,
                              isFullscreen: playbackState.isFullscreen,
                              l10n: l10n,
                              palette: palette,
                              scale: renderScale,
                              isVertical: true,
                              isMobileSize: isMobileSize,
                            ),
                          ],
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _PlaybackPanel(
                                playbackState: playbackState,
                                l10n: l10n,
                                palette: palette,
                                scale: renderScale,
                                isVertical: isVertical,
                                showTimers: false,
                              ),
                              SizedBox(width: 10 * renderScale),
                              _Divider(isVertical: false, palette: palette, scale: renderScale),
                              SizedBox(width: 10 * renderScale),
                              _ActionsPanel(
                                onHomePressed: onHomePressed,
                                onSourcesPressed: onSourcesPressed,
                              onMenuPressed: onMenuPressed,
                              onFullscreenPressed: onFullscreenPressed,
                              isFullscreen: playbackState.isFullscreen,
                                l10n: l10n,
                                palette: palette,
                                scale: renderScale,
                                isVertical: isVertical,
                                isMobileSize: isMobileSize,
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
}

class _PlaybackPanel extends ConsumerWidget {
  final PlaybackState playbackState;
  final _ToolboxPalette palette;
  final double scale;
  final bool isVertical;
  final bool showTimers;
  final AppLocalizations? l10n;

  const _PlaybackPanel({
    required this.playbackState,
    required this.l10n,
    required this.palette,
    required this.scale,
    required this.isVertical,
    required this.showTimers,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 10 * scale),
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
    final spacing = SizedBox(width: isVertical ? 0 : 10 * scale, height: isVertical ? 10 * scale : 0);
    return [
      _GlassButton(
        icon: LucideIcons.skip_back,
        onPressed: () => ref.read(playbackProvider.notifier).reset(),
        tooltip: l10n?.reset ?? 'Réinitialiser',
        size: 20 * scale,
      ),
      spacing,
      _GlassButton(
        icon: playbackState.isPlaying ? LucideIcons.pause : LucideIcons.play,
        onPressed: () => ref.read(playbackProvider.notifier).togglePlayPause(),
        tooltip: playbackState.isPlaying ? (l10n?.pause ?? 'Pause') : (l10n?.play ?? 'Lecture'),
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

class _TimersHeader extends StatelessWidget {
  final PlaybackState playbackState;
  final double scale;

  const _TimersHeader({required this.playbackState, required this.scale});

  @override
  Widget build(BuildContext context) {
    final elapsed = _formatDuration(Duration(seconds: playbackState.elapsedSeconds));
    final now = DateTime.now();
    final clock = '${_two(now.hour)}:${_two(now.minute)}:${_two(now.second)}';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.timer, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              elapsed,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16 * scale),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.clock_3, color: Colors.white70, size: 18),
            const SizedBox(width: 8),
            Text(
              clock,
              style: TextStyle(color: Colors.white70, fontSize: 15 * scale, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  String _two(int v) => v.toString().padLeft(2, '0');

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    if (h > 0) {
      return '${_two(h)}:${_two(m)}:${_two(s)}';
    }
    return '${_two(m)}:${_two(s)}';
  }
}

class _ActionsPanel extends StatelessWidget {
  final VoidCallback onHomePressed;
  final VoidCallback onSourcesPressed;
  final VoidCallback onMenuPressed;
  final VoidCallback onFullscreenPressed;
  final bool isFullscreen;
  final AppLocalizations? l10n;
  final _ToolboxPalette palette;
  final double scale;
  final bool isVertical;
  final bool isMobileSize;

  const _ActionsPanel({
    required this.onHomePressed,
    required this.onSourcesPressed,
    required this.onMenuPressed,
    required this.onFullscreenPressed,
    required this.isFullscreen,
    required this.l10n,
    required this.palette,
    required this.scale,
    required this.isVertical,
    required this.isMobileSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 10 * scale),
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
    final spacing = SizedBox(width: isVertical ? 0 : 12 * scale, height: isVertical ? 10 * scale : 0);
    final buttons = [
      _GlassButton(
        icon: LucideIcons.house,
        onPressed: onHomePressed,
        tooltip: l10n?.home ?? 'Accueil',
        size: 22 * scale,
      ),
      spacing,
      _GlassButton(
        icon: LucideIcons.circle_plus,
        onPressed: onSourcesPressed,
        tooltip: l10n?.addSource ?? 'Ajouter une source',
        size: 24 * scale,
      ),
      spacing,
    ];

    // Hide fullscreen button on mobile (picture-in-picture handled differently)
    if (!isMobileSize) {
      buttons.addAll([
        _GlassButton(
          icon: isFullscreen ? LucideIcons.minimize_2 : LucideIcons.maximize_2,
          onPressed: onFullscreenPressed,
          tooltip: isFullscreen
              ? (l10n?.exitFullscreen ?? 'Quitter le plein écran')
              : (l10n?.fullscreen ?? 'Plein écran'),
          size: 24 * scale,
        ),
        spacing,
      ]);
    }

    buttons.add(_GlassButton(
        icon: LucideIcons.menu,
        onPressed: onMenuPressed,
        tooltip: l10n?.settings ?? 'Menu',
      size: 24 * scale,
    ));

    return buttons;
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
