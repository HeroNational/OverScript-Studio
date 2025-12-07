import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:prompteur/l10n/app_localizations.dart';
import '../../../data/models/settings_model.dart';
import '../../../core/utils/speed_converter.dart';
import '../../providers/settings_provider.dart';
import '../../providers/capture_device_provider.dart'
    show videoDevicesProvider, audioDevicesProvider, translateDeviceLabel;

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    final isMobilePlatform = Platform.isAndroid || Platform.isIOS;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a1a1a), Color(0xFF2d2d2d)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildSection(context, l10n.playback, [
              _buildSpeedUnitSelector(context, ref, settings, l10n),
              const SizedBox(height: 16),
              _buildSpeedSlider(context, ref, settings, l10n),
              const SizedBox(height: 16),
              _buildCountdownSlider(context, ref, settings, l10n),
              const SizedBox(height: 16),
              _buildSwitchTile(
                context,
                l10n.autoFullscreenOnStart,
                l10n.autoFullscreenDescription,
                settings.autoFullscreen,
                (value) => ref
                    .read(settingsProvider.notifier)
                    .updateAutoFullscreen(value),
                LucideIcons.maximize,
              ),
            ]),
            const SizedBox(height: 32),
            _buildSection(context, _tr(settings, 'Apparence', 'Appearance'), [
              _buildColorPicker(
                context,
                ref,
                _tr(settings, 'Couleur de fond', 'Background color'),
                settings.backgroundColor,
                (color) => ref
                    .read(settingsProvider.notifier)
                    .updateBackgroundColor(_colorToHex(color)),
                LucideIcons.palette,
              ),
              const SizedBox(height: 16),
              _buildColorPicker(
                context,
                ref,
                _tr(settings, 'Couleur du texte', 'Text color'),
                settings.textColor,
                (color) => ref
                    .read(settingsProvider.notifier)
                    .updateTextColor(_colorToHex(color)),
                LucideIcons.type,
              ),
              const SizedBox(height: 16),
              _buildSwitchTile(
                context,
                l10n.mirrorMode,
                l10n.mirrorModeDescription,
                settings.mirrorMode,
                (value) =>
                    ref.read(settingsProvider.notifier).updateMirrorMode(value),
                LucideIcons.flip_horizontal,
              ),
              const SizedBox(height: 16),
              _buildFontSizeSlider(context, ref, settings),
              const SizedBox(height: 16),
              _buildMockTextControls(context, ref, settings),
              const SizedBox(height: 16),
              _buildCameraOverlayControls(context, ref),
            ]),
            const SizedBox(height: 32),
            _buildSection(context, _tr(settings, 'Toolbox', 'Toolbox'), [
              _buildToolbarPositionSelector(context, ref, settings),
              const SizedBox(height: 16),
              _buildToolbarOrientationSelector(context, ref, settings),
              const SizedBox(height: 16),
              if (Platform.isWindows ||
                  Platform.isMacOS ||
                  Platform.isLinux) ...[
                _buildToolbarScaleSelector(context, ref, settings),
                const SizedBox(height: 16),
              ],
              _buildToolbarThemeSelector(context, ref, settings),
              const SizedBox(height: 16),
              _buildSwitchTile(
                context,
                _tr(
                  settings,
                  'Afficher chrono et heure',
                  'Show timer and clock',
                ),
                _tr(
                  settings,
                  'Affiche le chronomètre et l\'horloge dans la toolbox',
                  'Display timer and clock in the toolbox',
                ),
                settings.showTimers,
                (value) =>
                    ref.read(settingsProvider.notifier).updateShowTimers(value),
                LucideIcons.timer,
              ),
            ]),
            const SizedBox(height: 32),
            _buildSection(context, _tr(settings, 'Contrôles', 'Controls'), [
              _buildSwitchTile(
                context,
                _tr(
                  settings,
                  'Bloquer les notifications (mode Focus)',
                  'Block notifications (Focus mode)',
                ),
                _tr(
                  settings,
                  'Active le mode Ne pas déranger pendant le prompteur',
                  'Enable Do Not Disturb while the prompter runs',
                ),
                settings.enableFocusMode,
                (value) => ref
                    .read(settingsProvider.notifier)
                    .updateSettings(settings.copyWith(enableFocusMode: value)),
                LucideIcons.bell_off,
              ),
            ]),
            const SizedBox(height: 32),
            if (!isMobilePlatform)
              _buildSection(
                context,
                _tr(settings, 'Raccourcis clavier', 'Keyboard shortcuts'),
                [
                  _buildShortcutInfo(
                    'Espace',
                    _tr(settings, 'Play / Pause', 'Play / Pause'),
                  ),
                  _buildShortcutInfo(
                    'F',
                    _tr(settings, 'Basculer plein écran', 'Toggle fullscreen'),
                  ),
                  _buildShortcutInfo(
                    'Échap',
                    _tr(settings, 'Sortir du plein écran', 'Exit fullscreen'),
                  ),
                  _buildShortcutInfo(
                    '↑',
                    _tr(settings, 'Augmenter la vitesse', 'Increase speed'),
                  ),
                  _buildShortcutInfo(
                    '↓',
                    _tr(settings, 'Diminuer la vitesse', 'Decrease speed'),
                  ),
                  _buildShortcutInfo(
                    'R',
                    _tr(settings, 'Réinitialiser', 'Reset'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownSlider(
    BuildContext context,
    WidgetRef ref,
    SettingsModel settings,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(LucideIcons.timer, color: Colors.white70, size: 20),
            const SizedBox(width: 8),
            Text(
              l10n.countdownSeconds,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              '${settings.countdownDuration}s',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
        Slider(
          value: settings.countdownDuration.toDouble(),
          min: 0,
          max: 10,
          divisions: 10,
          label: '${settings.countdownDuration}s',
          onChanged: (v) => ref
              .read(settingsProvider.notifier)
              .updateCountdownDuration(v.round()),
        ),
      ],
    );
  }

  String _tr(SettingsModel settings, String fr, String en) {
    return settings.locale.toLowerCase().startsWith('en') ? en : fr;
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSpeedUnitSelector(
    BuildContext context,
    WidgetRef ref,
    SettingsModel settings,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(LucideIcons.gauge, color: Colors.white70, size: 20),
            const SizedBox(width: 8),
            Text(
              l10n.speedUnit,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<SpeedUnit>(
              value: settings.speedUnit,
              isExpanded: true,
              dropdownColor: const Color(0xFF2d2d2d),
              style: const TextStyle(color: Colors.white, fontSize: 16),
              items: [
                DropdownMenuItem(
                  value: SpeedUnit.pixelsPerSecond,
                  child: Text(l10n.speedUnitPixels),
                ),
                DropdownMenuItem(
                  value: SpeedUnit.linesPerMinute,
                  child: Text(l10n.speedUnitLines),
                ),
                DropdownMenuItem(
                  value: SpeedUnit.wordsPerMinute,
                  child: Text(l10n.speedUnitWords),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).updateSpeedUnit(value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpeedSlider(
    BuildContext context,
    WidgetRef ref,
    SettingsModel settings,
    AppLocalizations l10n,
  ) {
    final minSpeed = _getMinSpeed(settings.speedUnit);
    final maxSpeed = _getMaxSpeed(settings.speedUnit);

    // Convert defaultSpeed (px/s) to display unit
    final displaySpeed = SpeedConverter.fromPixelsPerSecond(
      settings.defaultSpeed,
      settings.speedUnit,
      fontSize: settings.fontSize,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${l10n.defaultSpeed}: ${displaySpeed.toInt()} ${SpeedConverter.getUnitLabel(settings.speedUnit)}',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        Slider(
          value: displaySpeed.clamp(minSpeed, maxSpeed),
          min: minSpeed,
          max: maxSpeed,
          divisions: 100,
          activeColor: const Color(0xFF6366F1),
          onChanged: (value) {
            // Convert display value back to px/s before saving
            final pixelsPerSecond = SpeedConverter.toPixelsPerSecond(
              value,
              settings.speedUnit,
              fontSize: settings.fontSize,
            );
            ref.read(settingsProvider.notifier).updateSpeed(pixelsPerSecond);
          },
        ),
      ],
    );
  }

  Widget _buildFontSizeSlider(
    BuildContext context,
    WidgetRef ref,
    SettingsModel settings,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(LucideIcons.case_sensitive, color: Colors.white70, size: 20),
            const SizedBox(width: 8),
            Text(
              'Taille de police: ${settings.fontSize.toInt()}px',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Slider(
          value: settings.fontSize,
          min: 24,
          max: 120,
          divisions: 96,
          activeColor: const Color(0xFF6366F1),
          onChanged: (value) {
            ref.read(settingsProvider.notifier).updateFontSize(value);
          },
        ),
      ],
    );
  }

  Widget _buildMockTextControls(
    BuildContext context,
    WidgetRef ref,
    SettingsModel settings,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(LucideIcons.book_open, color: Colors.white70, size: 20),
            const SizedBox(width: 8),
            Text(
              _tr(settings, 'Texte mock quand vide', 'Mock text when empty'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Switch(
              value: settings.showMockTextWhenEmpty,
              onChanged: (v) =>
                  ref.read(settingsProvider.notifier).updateShowMockText(v),
              activeThumbColor: const Color(0xFF6366F1),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (settings.showMockTextWhenEmpty)
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<MockTextType>(
                value: settings.mockTextType,
                isExpanded: true,
                dropdownColor: const Color(0xFF2d2d2d),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                items: [
                  DropdownMenuItem(
                    value: MockTextType.random,
                    child: Text(_tr(settings, 'Aléatoire', 'Random')),
                  ),
                  DropdownMenuItem(
                    value: MockTextType.poem,
                    child: Text(_tr(settings, 'Poème', 'Poem')),
                  ),
                  DropdownMenuItem(
                    value: MockTextType.song,
                    child: Text(
                      _tr(settings, 'Paroles de chanson', 'Song lyrics'),
                    ),
                  ),
                  DropdownMenuItem(
                    value: MockTextType.inspiring,
                    child: Text(_tr(settings, 'Inspirant', 'Inspiring')),
                  ),
                  DropdownMenuItem(
                    value: MockTextType.none,
                    child: Text(_tr(settings, 'Aucun', 'None')),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(settingsProvider.notifier)
                        .updateMockTextType(value);
                  }
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCameraOverlayControls(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final videosAsync = ref.watch(videoDevicesProvider);
    final audiosAsync = ref.watch(audioDevicesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(LucideIcons.video, color: Colors.white70, size: 20),
            const SizedBox(width: 8),
            Text(
              l10n.cameraRecording,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          l10n.camera,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: videosAsync.when(
            data: (devices) {
              debugPrint('[Settings] Video devices loaded: ${devices.length}');
              final items = [
                DropdownMenuItem<String>(
                  value: null,
                  child: Text(l10n.systemDefault),
                ),
                ...devices.map((d) {
                  debugPrint('[Settings] Device: id=${d.id}, label=${d.label}');
                  return DropdownMenuItem<String>(
                    value: d.id,
                    child: Text(
                      translateDeviceLabel(d.label.isNotEmpty ? d.label : d.id),
                    ),
                  );
                }),
              ];
              final selectedCamera =
                  items.any((item) => item.value == settings.selectedCameraId)
                  ? settings.selectedCameraId
                  : null;
              return DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCamera,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF2d2d2d),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  items: items,
                  onChanged: (v) => ref
                      .read(settingsProvider.notifier)
                      .updateSelectedCamera(v),
                ),
              );
            },
            loading: () => const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (err, st) {
              debugPrint('[Settings] Error loading video devices: $err');
              return Text(
                'Error: $err',
                style: const TextStyle(color: Colors.red, fontSize: 14),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.microphone,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: audiosAsync.when(
            data: (devices) {
              final items = [
                DropdownMenuItem<String>(
                  value: null,
                  child: Text(l10n.systemDefault),
                ),
                ...devices.map(
                  (d) => DropdownMenuItem<String>(
                    value: d.id,
                    child: Text(d.label.isNotEmpty ? d.label : d.id),
                  ),
                ),
              ];
              final selectedMic =
                  items.any((item) => item.value == settings.selectedMicId)
                  ? settings.selectedMicId
                  : null;
              return DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedMic,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF2d2d2d),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  items: items,
                  onChanged: (v) =>
                      ref.read(settingsProvider.notifier).updateSelectedMic(v),
                ),
              );
            },
            loading: () => const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (err, st) => Text(
              'Error: $err',
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorPicker(
    BuildContext context,
    WidgetRef ref,
    String label,
    String hexColor,
    Function(Color) onColorChanged,
    IconData icon,
  ) {
    final color = _parseColor(hexColor);

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF2d2d2d),
            title: Text(label, style: const TextStyle(color: Colors.white)),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: color,
                onColorChanged: onColorChanged,
                pickerAreaHeightPercent: 0.8,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
            ],
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24, width: 2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbarPositionSelector(
    BuildContext context,
    WidgetRef ref,
    SettingsModel settings,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(LucideIcons.layout_grid, color: Colors.white70, size: 20),
            const SizedBox(width: 8),
            Text(
              _tr(settings, 'Position de la toolbar', 'Toolbar position'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ToolbarPosition>(
              value: settings.toolbarPosition,
              isExpanded: true,
              dropdownColor: const Color(0xFF2d2d2d),
              style: const TextStyle(color: Colors.white, fontSize: 16),
              items: const [
                DropdownMenuItem(
                  value: ToolbarPosition.top,
                  child: Text('Haut'),
                ),
                DropdownMenuItem(
                  value: ToolbarPosition.topCenter,
                  child: Text('Haut (centre)'),
                ),
                DropdownMenuItem(
                  value: ToolbarPosition.bottom,
                  child: Text('Bas'),
                ),
                DropdownMenuItem(
                  value: ToolbarPosition.bottomCenter,
                  child: Text('Bas (centre)'),
                ),
                DropdownMenuItem(
                  value: ToolbarPosition.left,
                  child: Text('Gauche'),
                ),
                DropdownMenuItem(
                  value: ToolbarPosition.right,
                  child: Text('Droite'),
                ),
                DropdownMenuItem(
                  value: ToolbarPosition.topLeft,
                  child: Text('Coin haut gauche'),
                ),
                DropdownMenuItem(
                  value: ToolbarPosition.topRight,
                  child: Text('Coin haut droit'),
                ),
                DropdownMenuItem(
                  value: ToolbarPosition.bottomLeft,
                  child: Text('Coin bas gauche'),
                ),
                DropdownMenuItem(
                  value: ToolbarPosition.bottomRight,
                  child: Text('Coin bas droit'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(settingsProvider.notifier)
                      .updateToolbarPosition(value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToolbarThemeSelector(
    BuildContext context,
    WidgetRef ref,
    SettingsModel settings,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(LucideIcons.palette, color: Colors.white70, size: 20),
            const SizedBox(width: 8),
            Text(
              _tr(settings, 'Thème de la toolbox', 'Toolbox theme'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ToolboxTheme>(
              value: settings.toolboxTheme,
              isExpanded: true,
              dropdownColor: const Color(0xFF2d2d2d),
              style: const TextStyle(color: Colors.white, fontSize: 16),
              items: [
                DropdownMenuItem(
                  value: ToolboxTheme.modern,
                  child: Text(_tr(settings, 'Moderne', 'Modern')),
                ),
                DropdownMenuItem(
                  value: ToolboxTheme.glass,
                  child: Text(_tr(settings, 'Verre brillant', 'Glass')),
                ),
                DropdownMenuItem(
                  value: ToolboxTheme.contrast,
                  child: Text(_tr(settings, 'Contraste fort', 'High contrast')),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).updateToolboxTheme(value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToolbarScaleSelector(
    BuildContext context,
    WidgetRef ref,
    SettingsModel settings,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(LucideIcons.maximize_2, color: Colors.white70, size: 20),
            const SizedBox(width: 8),
            Text(
              _tr(
                settings,
                'Taille de la toolbox: ${(settings.toolbarScale * 100).toInt()}%',
                'Toolbox size: ${(settings.toolbarScale * 100).toInt()}%',
              ),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Slider(
          value: settings.toolbarScale.clamp(0.7, 1.0),
          min: 0.7,
          max: 1.0,
          divisions: 6,
          activeColor: const Color(0xFF6366F1),
          onChanged: (value) {
            ref.read(settingsProvider.notifier).updateToolbarScale(value);
          },
        ),
      ],
    );
  }

  Widget _buildToolbarOrientationSelector(
    BuildContext context,
    WidgetRef ref,
    SettingsModel settings,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(LucideIcons.panel_top, color: Colors.white70, size: 20),
            const SizedBox(width: 8),
            Text(
              _tr(settings, 'Orientation de la toolbox', 'Toolbox orientation'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ToolbarOrientation>(
              value: settings.toolbarOrientation,
              isExpanded: true,
              dropdownColor: const Color(0xFF2d2d2d),
              style: const TextStyle(color: Colors.white, fontSize: 16),
              items: const [
                DropdownMenuItem(
                  value: ToolbarOrientation.auto,
                  child: Text('Auto (selon position)'),
                ),
                DropdownMenuItem(
                  value: ToolbarOrientation.horizontal,
                  child: Text('Horizontal'),
                ),
                DropdownMenuItem(
                  value: ToolbarOrientation.vertical,
                  child: Text('Vertical'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(settingsProvider.notifier)
                      .updateToolbarOrientation(value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF6366F1),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutInfo(String key, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF6366F1), width: 1),
            ),
            child: Text(
              key,
              style: const TextStyle(
                color: Color(0xFF6366F1),
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String hexColor) {
    final hex = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  double _getMinSpeed(SpeedUnit unit) {
    switch (unit) {
      case SpeedUnit.pixelsPerSecond:
        return 10.0;
      case SpeedUnit.linesPerMinute:
        return 5.0;
      case SpeedUnit.wordsPerMinute:
        return 50.0;
    }
  }

  double _getMaxSpeed(SpeedUnit unit) {
    switch (unit) {
      case SpeedUnit.pixelsPerSecond:
        return 500.0;
      case SpeedUnit.linesPerMinute:
        return 100.0;
      case SpeedUnit.wordsPerMinute:
        return 1000.0;
    }
  }

  Widget _buildVideoActions(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final shareLabel = _tr(ref.read(settingsProvider), 'Partager', 'Share');

    Future<void> pickAndShare() async {
      final result = await FilePicker.platform.pickFiles(type: FileType.video);
      if (result == null || result.files.single.path == null) return;

      final path = result.files.single.path!;
      await Share.shareXFiles([XFile(path)], text: shareLabel);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _tr(ref.read(settingsProvider), 'Vidéo partagée', 'Shared'),
          ),
        ),
      );
    }

    Future<void> pickAndDelete() async {
      final result = await FilePicker.platform.pickFiles(type: FileType.video);
      if (result == null || result.files.single.path == null) return;

      final path = result.files.single.path!;
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _tr(ref.read(settingsProvider), 'Vidéo supprimée', 'Deleted'),
            ),
          ),
        );
      }
    }

    Widget buildButton({
      required IconData icon,
      required String label,
      required VoidCallback onPressed,
    }) {
      return SizedBox(
        height: 48,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.08),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: onPressed,
          icon: Icon(icon, size: 20),
          label: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
