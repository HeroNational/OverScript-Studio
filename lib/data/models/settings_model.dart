import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_model.freezed.dart';
part 'settings_model.g.dart';

enum SpeedUnit {
  pixelsPerSecond,
  linesPerMinute,
  wordsPerMinute,
}

enum ToolbarPosition {
  top,
  bottom,
  left,
  right,
  topCenter,
  bottomCenter,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

enum ToolboxTheme {
  modern,
  glass,
  contrast,
}

enum ToolbarOrientation {
  auto,
  horizontal,
  vertical,
}

enum ThemeMode {
  light,
  dark,
}

enum MockTextType {
  none,
  poem,
  song,
  inspiring,
  random,
}

@freezed
class SettingsModel with _$SettingsModel {
  const factory SettingsModel({
    @Default(120.0) double defaultSpeed,
    @Default(SpeedUnit.pixelsPerSecond) SpeedUnit speedUnit,
    @Default(true) bool autoFullscreen,
    @Default(false) bool autoStartCamera,
    @Default(false) bool cameraAsBackground,
  @Default(0.9) double promptOpacity,
  String? selectedCameraId,
  String? selectedMicId,
  @Default(false) bool enableVideoSharing,
  @Default(false) bool enableFocusMode,
  @Default('#1a1a1a') String backgroundColor,
    @Default('#ffffff') String textColor,
    @Default('System') String fontFamily,
    @Default(48.0) double fontSize,
    @Default(ToolbarPosition.bottom) ToolbarPosition toolbarPosition,
    @Default(1.0) double toolbarScale,
  @Default(ToolboxTheme.modern) ToolboxTheme toolboxTheme,
  @Default(ToolbarOrientation.auto) ToolbarOrientation toolbarOrientation,
  @Default(true) bool pauseOnMouseMove,
  @Default('Space') String pauseKey,
  @Default('fr') String locale,
  @Default(true) bool showTimers,
  @Default(5) int countdownDuration,
  @Default(ThemeMode.dark) ThemeMode themeMode,
  @Default(MockTextType.random) MockTextType mockTextType,
  @Default(true) bool showMockTextWhenEmpty,
  Map<String, String>? customShortcuts,
  }) = _SettingsModel;

  factory SettingsModel.fromJson(Map<String, dynamic> json) =>
      _$SettingsModelFromJson(json);
}
