import 'package:flutter/foundation.dart';
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
    debugPrint('[Settings] Update speed: $speed px/s');
    state = state.copyWith(defaultSpeed: speed);
    await _storageService.saveSettings(state);
  }

  Future<void> updateSpeedUnit(SpeedUnit unit) async {
    debugPrint('[Settings] Update speed unit: $unit');
    state = state.copyWith(speedUnit: unit);
    await _storageService.saveSettings(state);
  }

  Future<void> updateBackgroundColor(String color) async {
    debugPrint('[Settings] Update background color: $color');
    state = state.copyWith(backgroundColor: color);
    await _storageService.saveSettings(state);
  }

  Future<void> updateTextColor(String color) async {
    debugPrint('[Settings] Update text color: $color');
    state = state.copyWith(textColor: color);
    await _storageService.saveSettings(state);
  }

  Future<void> updateFontFamily(String font) async {
    debugPrint('[Settings] Update font family: $font');
    state = state.copyWith(fontFamily: font);
    await _storageService.saveSettings(state);
  }

  Future<void> updateFontSize(double size) async {
    debugPrint('[Settings] Update font size: $size');
    state = state.copyWith(fontSize: size);
    await _storageService.saveSettings(state);
  }

  Future<void> updateAutoFullscreen(bool enabled) async {
    debugPrint('[Settings] Update auto fullscreen: $enabled');
    state = state.copyWith(autoFullscreen: enabled);
    await _storageService.saveSettings(state);
  }

  Future<void> updateToolbarPosition(ToolbarPosition position) async {
    debugPrint('[Settings] Update toolbar position: $position');
    state = state.copyWith(toolbarPosition: position);
    await _storageService.saveSettings(state);
  }

  Future<void> updateToolbarScale(double scale) async {
    debugPrint('[Settings] Update toolbar scale: $scale');
    state = state.copyWith(toolbarScale: scale);
    await _storageService.saveSettings(state);
  }

  Future<void> updateToolboxTheme(ToolboxTheme theme) async {
    debugPrint('[Settings] Update toolbox theme: $theme');
    state = state.copyWith(toolboxTheme: theme);
    await _storageService.saveSettings(state);
  }

  Future<void> updateToolbarOrientation(ToolbarOrientation orientation) async {
    debugPrint('[Settings] Update toolbar orientation: $orientation');
    state = state.copyWith(toolbarOrientation: orientation);
    await _storageService.saveSettings(state);
  }

  Future<void> updateAutoStartCamera(bool value) async {
    debugPrint('[Settings] Update auto start camera: $value');
    state = state.copyWith(autoStartCamera: value);
    await _storageService.saveSettings(state);
  }

  Future<void> updateCameraAsBackground(bool value) async {
    debugPrint('[Settings] Update camera as background: $value');
    state = state.copyWith(cameraAsBackground: value);
    await _storageService.saveSettings(state);
  }

  Future<void> updatePromptOpacity(double value) async {
    debugPrint('[Settings] Update prompt opacity: $value');
    state = state.copyWith(promptOpacity: value);
    await _storageService.saveSettings(state);
  }

  Future<void> updateSelectedCamera(String? id) async {
    debugPrint('[Settings] Update selected camera: $id');
    state = state.copyWith(selectedCameraId: id);
    await _storageService.saveSettings(state);
  }

  Future<void> updateSelectedMic(String? id) async {
    debugPrint('[Settings] Update selected microphone: $id');
    state = state.copyWith(selectedMicId: id);
    await _storageService.saveSettings(state);
  }

  Future<void> updateEnableVideoSharing(bool value) async {
    debugPrint('[Settings] Update enable video sharing: $value');
    state = state.copyWith(enableVideoSharing: value);
    await _storageService.saveSettings(state);
  }

  Future<void> clearVideoSelection() async {
    debugPrint('[Settings] Clear video selection');
    state = state.copyWith(selectedCameraId: null, enableVideoSharing: false);
    await _storageService.saveSettings(state);
  }

  Future<void> updateShowTimers(bool value) async {
    debugPrint('[Settings] Update show timers: $value');
    state = state.copyWith(showTimers: value);
    await _storageService.saveSettings(state);
  }

  Future<void> updateCountdownDuration(int seconds) async {
    debugPrint('[Settings] Update countdown duration: ${seconds}s');
    state = state.copyWith(countdownDuration: seconds);
    await _storageService.saveSettings(state);
  }

  Future<void> updateLocale(String locale) async {
    debugPrint('[Settings] Update locale: $locale');
    state = state.copyWith(locale: locale);
    await _storageService.saveSettings(state);
  }

  Future<void> updateMockTextType(MockTextType type) async {
    debugPrint('[Settings] Update mock text type: $type');
    state = state.copyWith(mockTextType: type);
    await _storageService.saveSettings(state);
  }

  Future<void> updateShowMockText(bool value) async {
    debugPrint('[Settings] Update show mock text: $value');
    state = state.copyWith(showMockTextWhenEmpty: value);
    await _storageService.saveSettings(state);
  }

  Future<void> updateSettings(SettingsModel settings) async {
    debugPrint('[Settings] Bulk update settings');
    state = settings;
    await _storageService.saveSettings(state);
  }
}

final storageServiceProvider = Provider((ref) => StorageService());

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsModel>((ref) {
  return SettingsNotifier(ref.read(storageServiceProvider));
});
