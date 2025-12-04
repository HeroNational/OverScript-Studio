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
  final VoidCallback onRecordPressed;
  final bool isRecording;
  final int recordSeconds;
  final Animation<double> recordPulse;
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
    required this.onRecordPressed,
    required this.isRecording,
    required this.recordSeconds,
    required this.recordPulse,
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

    // Sur mobile : largeur plus contenue et légère réduction d'échelle pour limiter la hauteur.
    double finalScale = isMobileSize ? 0.95 : scale.clamp(0.7, 1.0);
    double adaptiveMargin = isMobileSize ? 8.0 : 24.0;
    final double maxWidth = isMobileSize ? MediaQuery.of(context).size.width * 0.7 : 600;

    final baseRadius = 24.0 * finalScale;
    final renderScale = finalScale;

    return Align(
      alignment: Alignment.center,
      child: Transform.scale(
        scale: finalScale,
        alignment: Alignment.center,
        child: SizedBox(
          width: maxWidth,
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
                  constraints: isMobileSize
                      ? BoxConstraints.tightFor(width: maxWidth)
                      : BoxConstraints(maxWidth: maxWidth),
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
                  padding: EdgeInsets.symmetric(
                    horizontal: 10 * renderScale,
                    vertical: (isMobileSize ? 8 : 12) * renderScale,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (isRecording) ...[
                        _RecordStatusChip(seconds: recordSeconds, pulse: recordPulse, scale: renderScale),
                        SizedBox(height: 8 * renderScale),
                      ],
                      SizedBox(
                        width: double.infinity,
                        child: _PlaybackPanel(
                          playbackState: playbackState,
                          l10n: l10n,
                          palette: palette,
                          scale: renderScale,
                          isVertical: isVertical,
                          showTimers: false,
                          onRecordPressed: onRecordPressed,
                          isRecording: isRecording,
                        ),
                      ),
                      SizedBox(height: 8 * renderScale),
                      if (!isMobileSize) ...[
                        _Divider(isVertical: isVertical, palette: palette, scale: renderScale),
                        SizedBox(height: 8 * renderScale),
                      ],
                      SizedBox(
                        width: double.infinity,
                        child: _ActionsPanel(
                          onHomePressed: onHomePressed,
                          onSourcesPressed: onSourcesPressed,
                          onMenuPressed: onMenuPressed,
                          onFullscreenPressed: onFullscreenPressed,
                          onRecordPressed: onRecordPressed,
                          isRecording: isRecording,
                          isFullscreen: playbackState.isFullscreen,
                          l10n: l10n,
                          palette: palette,
                          scale: renderScale,
                          isVertical: isVertical,
                          isMobileSize: isMobileSize,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RecordStatusChip extends StatelessWidget {
  final int seconds;
  final Animation<double> pulse;
  final double scale;

  const _RecordStatusChip({
    required this.seconds,
    required this.pulse,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    String two(int v) => v.toString().padLeft(2, '0');
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    final time = h > 0 ? '${two(h)}:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScaleTransition(
          scale: Tween(begin: 0.85, end: 1.2).animate(
            CurvedAnimation(parent: pulse, curve: Curves.easeInOut),
          ),
          child: Container(
            width: 12 * scale,
            height: 12 * scale,
            decoration: BoxDecoration(
              color: Colors.redAccent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.redAccent.withOpacity(0.5), blurRadius: 12),
              ],
            ),
          ),
        ),
        SizedBox(width: 8 * scale),
        Text(
          time,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14 * scale),
        ),
      ],
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
  final VoidCallback onRecordPressed;
  final bool isRecording;

  const _PlaybackPanel({
    required this.playbackState,
    required this.l10n,
    required this.palette,
    required this.scale,
    required this.isVertical,
    required this.showTimers,
    required this.onRecordPressed,
    required this.isRecording,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buttons = _buildButtons(ref);
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 14 * scale,
            runSpacing: 12 * scale,
            children: buttons,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildButtons(WidgetRef ref) {
    final buttons = <Widget>[
      _GlassButton(
        icon: LucideIcons.refresh_cw,
        onPressed: () => ref.read(playbackProvider.notifier).reset(),
        tooltip: l10n?.reset ?? 'Réinitialiser',
        size: 24 * scale,
        toastMessage: l10n?.reset ?? 'Revenir au début',
      ),
      _GlassButton(
        icon: playbackState.isPlaying ? LucideIcons.pause : LucideIcons.play,
        onPressed: () => ref.read(playbackProvider.notifier).togglePlayPause(),
        tooltip: playbackState.isPlaying ? (l10n?.pause ?? 'Pause') : (l10n?.play ?? 'Lecture'),
        size: 24 * scale,
        toastMessage: playbackState.isPlaying
            ? (l10n?.pause ?? 'Lecture mise en pause')
            : (l10n?.play ?? 'Lecture démarrée'),
      ),
      _GlassButton(
        icon: isRecording ? LucideIcons.circle_stop : LucideIcons.video,
        onPressed: onRecordPressed,
        tooltip: isRecording ? 'Arrêter l\'enregistrement' : (l10n?.camera ?? 'Démarrer l\'enregistrement'),
        size: 24 * scale,
        toastMessage: isRecording ? 'Enregistrement arrêté' : 'Enregistrement démarré',
      ),
    ];

    return buttons;
  }
}


class _ActionsPanel extends StatelessWidget {
  final VoidCallback onHomePressed;
  final VoidCallback onSourcesPressed;
  final VoidCallback onMenuPressed;
  final VoidCallback onFullscreenPressed;
  final VoidCallback onRecordPressed;
  final bool isRecording;
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
    required this.onRecordPressed,
    required this.isRecording,
    required this.isFullscreen,
    required this.l10n,
    required this.palette,
    required this.scale,
    required this.isVertical,
    required this.isMobileSize,
  });

  @override
  Widget build(BuildContext context) {
    final buttons = _buildButtons();
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
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12 * scale,
        runSpacing: 10 * scale,
        children: buttons,
      ),
    );
  }

  List<Widget> _buildButtons() {
    final buttons = <Widget>[
      _GlassButton(
        icon: LucideIcons.house,
        onPressed: onHomePressed,
        tooltip: l10n?.home ?? 'Accueil',
        size: 22 * scale,
      ),
      _GlassButton(
        icon: LucideIcons.circle_plus,
        onPressed: onSourcesPressed,
        tooltip: l10n?.addSource ?? 'Ajouter une source',
        size: 24 * scale,
      ),
    ];

    // Hide fullscreen button on mobile (picture-in-picture handled differently)
    if (!isMobileSize) {
      buttons.add(
        _GlassButton(
          icon: isFullscreen ? LucideIcons.minimize_2 : LucideIcons.maximize_2,
          onPressed: onFullscreenPressed,
          tooltip: isFullscreen
              ? (l10n?.exitFullscreen ?? 'Quitter le plein écran')
              : (l10n?.fullscreen ?? 'Plein écran'),
          size: 24 * scale,
          toastMessage: isFullscreen
              ? (l10n?.exitFullscreen ?? 'Plein écran désactivé')
              : (l10n?.fullscreen ?? 'Plein écran activé'),
        ),
      );
    }

    buttons.add(
      _GlassButton(
        icon: LucideIcons.menu,
        onPressed: onMenuPressed,
        tooltip: l10n?.settings ?? 'Menu',
        size: 24 * scale,
      ),
    );

    return buttons;
  }
}

class _GlassButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final double size;
  final bool primary;
  final String? toastMessage;

  const _GlassButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.size = 24,
    this.primary = false,
    this.toastMessage,
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
          onTap: () {
            widget.onPressed();
            if (widget.toastMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(widget.toastMessage!),
                  duration: const Duration(milliseconds: 1200),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
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
