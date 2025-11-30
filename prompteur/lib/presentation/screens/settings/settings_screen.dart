import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../data/models/settings_model.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
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
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildSection(
              context,
              'Lecture',
              [
                _buildSpeedUnitSelector(context, ref, settings),
                const SizedBox(height: 16),
                _buildSpeedSlider(context, ref, settings),
                const SizedBox(height: 16),
                _buildSwitchTile(
                  context,
                  'Plein écran automatique au démarrage',
                  'L\'application passera en plein écran quand vous lancez le prompteur',
                  settings.autoFullscreen,
                  (value) => ref.read(settingsProvider.notifier).updateAutoFullscreen(value),
                  LucideIcons.maximize,
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildSection(
              context,
              'Apparence',
              [
                _buildColorPicker(
                  context,
                  ref,
                  'Couleur de fond',
                  settings.backgroundColor,
                  (color) => ref.read(settingsProvider.notifier).updateBackgroundColor(_colorToHex(color)),
                  LucideIcons.palette,
                ),
                const SizedBox(height: 16),
                _buildColorPicker(
                  context,
                  ref,
                  'Couleur du texte',
                  settings.textColor,
                  (color) => ref.read(settingsProvider.notifier).updateTextColor(_colorToHex(color)),
                  LucideIcons.type,
                ),
                const SizedBox(height: 16),
                _buildFontSizeSlider(context, ref, settings),
              ],
            ),
            const SizedBox(height: 32),
            _buildSection(
              context,
              'Contrôles',
              [
                _buildSwitchTile(
                  context,
                  'Pause sur mouvement de souris',
                  'Le défilement se met en pause quand vous bougez la souris',
                  settings.pauseOnMouseMove,
                  (value) => ref.read(settingsProvider.notifier).updateSettings(
                    settings.copyWith(pauseOnMouseMove: value),
                  ),
                  LucideIcons.mouse,
                ),
                const SizedBox(height: 16),
                _buildToolbarPositionSelector(context, ref, settings),
                const SizedBox(height: 16),
                _buildToolbarScaleSelector(context, ref, settings),
                const SizedBox(height: 16),
                _buildToolbarThemeSelector(context, ref, settings),
                const SizedBox(height: 16),
                _buildSwitchTile(
                  context,
                  'Bloquer les notifications (mode Focus)',
                  'Active le mode Ne pas déranger pendant le prompteur',
                  settings.enableFocusMode,
                  (value) => ref.read(settingsProvider.notifier).updateSettings(
                        settings.copyWith(enableFocusMode: value),
                      ),
                  LucideIcons.bell_off,
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildSection(
              context,
              'Raccourcis clavier',
              [
                _buildShortcutInfo('Espace', 'Play / Pause'),
                _buildShortcutInfo('F', 'Basculer plein écran'),
                _buildShortcutInfo('Échap', 'Sortir du plein écran'),
                _buildShortcutInfo('↑', 'Augmenter la vitesse'),
                _buildShortcutInfo('↓', 'Diminuer la vitesse'),
                _buildShortcutInfo('R', 'Réinitialiser'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
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

  Widget _buildSpeedUnitSelector(BuildContext context, WidgetRef ref, SettingsModel settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(LucideIcons.gauge, color: Colors.white70, size: 20),
            const SizedBox(width: 8),
            Text(
              'Unité de vitesse',
              style: TextStyle(
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
              items: const [
                DropdownMenuItem(
                  value: SpeedUnit.pixelsPerSecond,
                  child: Text('Pixels par seconde'),
                ),
                DropdownMenuItem(
                  value: SpeedUnit.linesPerMinute,
                  child: Text('Lignes par minute'),
                ),
                DropdownMenuItem(
                  value: SpeedUnit.wordsPerMinute,
                  child: Text('Mots par minute'),
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

  Widget _buildSpeedSlider(BuildContext context, WidgetRef ref, SettingsModel settings) {
    final minSpeed = _getMinSpeed(settings.speedUnit);
    final maxSpeed = _getMaxSpeed(settings.speedUnit);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vitesse par défaut: ${settings.defaultSpeed.toInt()}',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        Slider(
          value: settings.defaultSpeed.clamp(minSpeed, maxSpeed),
          min: minSpeed,
          max: maxSpeed,
          divisions: 100,
          activeColor: const Color(0xFF6366F1),
          onChanged: (value) {
            ref.read(settingsProvider.notifier).updateSpeed(value);
          },
        ),
      ],
    );
  }

  Widget _buildFontSizeSlider(BuildContext context, WidgetRef ref, SettingsModel settings) {
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

  Widget _buildToolbarPositionSelector(BuildContext context, WidgetRef ref, SettingsModel settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(LucideIcons.layout_grid, color: Colors.white70, size: 20),
            const SizedBox(width: 8),
            Text(
              'Position de la toolbar',
              style: TextStyle(
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
                DropdownMenuItem(value: ToolbarPosition.top, child: Text('Haut')),
                DropdownMenuItem(value: ToolbarPosition.bottom, child: Text('Bas')),
                DropdownMenuItem(value: ToolbarPosition.left, child: Text('Gauche')),
                DropdownMenuItem(value: ToolbarPosition.right, child: Text('Droite')),
                DropdownMenuItem(value: ToolbarPosition.topLeft, child: Text('Coin haut gauche')),
                DropdownMenuItem(value: ToolbarPosition.topRight, child: Text('Coin haut droit')),
                DropdownMenuItem(value: ToolbarPosition.bottomLeft, child: Text('Coin bas gauche')),
                DropdownMenuItem(value: ToolbarPosition.bottomRight, child: Text('Coin bas droit')),
              ],
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).updateToolbarPosition(value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToolbarScaleSelector(BuildContext context, WidgetRef ref, SettingsModel settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(LucideIcons.maximize_2, color: Colors.white70, size: 20),
            const SizedBox(width: 8),
            Text(
              'Taille de la toolbox: ${(settings.toolbarScale * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Slider(
          value: settings.toolbarScale.clamp(0.7, 1.4),
          min: 0.7,
          max: 1.4,
          divisions: 14,
          activeColor: const Color(0xFF6366F1),
          onChanged: (value) {
            ref.read(settingsProvider.notifier).updateToolbarScale(value);
          },
        ),
      ],
    );
  }

  Widget _buildToolbarThemeSelector(BuildContext context, WidgetRef ref, SettingsModel settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(LucideIcons.palette, color: Colors.white70, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Thème de la toolbox',
              style: TextStyle(
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
              items: const [
                DropdownMenuItem(value: ToolboxTheme.modern, child: Text('Moderne')),
                DropdownMenuItem(value: ToolboxTheme.glass, child: Text('Verre brillant')),
                DropdownMenuItem(value: ToolboxTheme.contrast, child: Text('Contraste fort')),
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
            activeColor: const Color(0xFF6366F1),
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
}
