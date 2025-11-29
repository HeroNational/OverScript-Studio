import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/settings_model.dart';
import '../../data/services/storage_service.dart';

class SettingsNotifier extends StateNotifier<SettingsModel> {
  SettingsNotifier(this._storageService) : super(const SettingsModel()) {
    _loadSettings();
  }

  final StorageService _storageService;

  Future<void> _loadSettings() async {
    final settings = await _storageService.loadSettings();
    if (settings != null) {
      state = settings;
    }
  }

  Future<void> updateSpeed(double speed) async {
    state = state.copyWith(defaultSpeed: speed);
    await _storageService.saveSettings(state);
  }

  Future<void> updateSpeedUnit(SpeedUnit unit) async {
    state = state.copyWith(speedUnit: unit);
    await _storageService.saveSettings(state);
  }

  Future<void> updateBackgroundColor(String color) async {
    state = state.copyWith(backgroundColor: color);
    await _storageService.saveSettings(state);
  }

  Future<void> updateTextColor(String color) async {
    state = state.copyWith(textColor: color);
    await _storageService.saveSettings(state);
  }

  Future<void> updateFontFamily(String font) async {
    state = state.copyWith(fontFamily: font);
    await _storageService.saveSettings(state);
  }

  Future<void> updateFontSize(double size) async {
    state = state.copyWith(fontSize: size);
    await _storageService.saveSettings(state);
  }

  Future<void> updateAutoFullscreen(bool enabled) async {
    state = state.copyWith(autoFullscreen: enabled);
    await _storageService.saveSettings(state);
  }

  Future<void> updateToolbarPosition(ToolbarPosition position) async {
    state = state.copyWith(toolbarPosition: position);
    await _storageService.saveSettings(state);
  }

  Future<void> updateToolbarScale(double scale) async {
    state = state.copyWith(toolbarScale: scale);
    await _storageService.saveSettings(state);
  }

  Future<void> updateToolboxTheme(ToolboxTheme theme) async {
    state = state.copyWith(toolboxTheme: theme);
    await _storageService.saveSettings(state);
  }

  Future<void> updateSettings(SettingsModel settings) async {
    state = settings;
    await _storageService.saveSettings(state);
  }
}

final storageServiceProvider = Provider((ref) => StorageService());

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsModel>((ref) {
  return SettingsNotifier(ref.read(storageServiceProvider));
});
