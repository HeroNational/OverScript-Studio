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

  Future<void> updateToolbarOrientation(ToolbarOrientation orientation) async {
    state = state.copyWith(toolbarOrientation: orientation);
    await _storageService.saveSettings(state);
  }

  Future<void> updateAutoStartCamera(bool value) async {
    state = state.copyWith(autoStartCamera: value);
    await _storageService.saveSettings(state);
  }

  Future<void> updateCameraAsBackground(bool value) async {
    state = state.copyWith(cameraAsBackground: value);
    await _storageService.saveSettings(state);
  }

  Future<void> updatePromptOpacity(double value) async {
    state = state.copyWith(promptOpacity: value);
    await _storageService.saveSettings(state);
  }

  Future<void> updateSelectedCamera(String? id) async {
    state = state.copyWith(selectedCameraId: id);
    await _storageService.saveSettings(state);
  }

  Future<void> updateSelectedMic(String? id) async {
    state = state.copyWith(selectedMicId: id);
    await _storageService.saveSettings(state);
  }

  Future<void> updateEnableVideoSharing(bool value) async {
    state = state.copyWith(enableVideoSharing: value);
    await _storageService.saveSettings(state);
  }

  Future<void> clearVideoSelection() async {
    state = state.copyWith(selectedCameraId: null, enableVideoSharing: false);
    await _storageService.saveSettings(state);
  }

  Future<void> updateShowTimers(bool value) async {
    state = state.copyWith(showTimers: value);
    await _storageService.saveSettings(state);
  }

  Future<void> updateCountdownDuration(int seconds) async {
    state = state.copyWith(countdownDuration: seconds);
    await _storageService.saveSettings(state);
  }

  Future<void> updateLocale(String locale) async {
    state = state.copyWith(locale: locale);
    await _storageService.saveSettings(state);
  }

  Future<void> updateMockTextType(MockTextType type) async {
    state = state.copyWith(mockTextType: type);
    await _storageService.saveSettings(state);
  }

  Future<void> updateShowMockText(bool value) async {
    state = state.copyWith(showMockTextWhenEmpty: value);
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
