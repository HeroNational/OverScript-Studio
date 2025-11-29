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
}

@freezed
class SettingsModel with _$SettingsModel {
  const factory SettingsModel({
    @Default(120.0) double defaultSpeed,
    @Default(SpeedUnit.pixelsPerSecond) SpeedUnit speedUnit,
    @Default(true) bool autoFullscreen,
    @Default(false) bool enableFocusMode,
    @Default('#1a1a1a') String backgroundColor,
    @Default('#ffffff') String textColor,
    @Default('System') String fontFamily,
    @Default(48.0) double fontSize,
    @Default(ToolbarPosition.bottom) ToolbarPosition toolbarPosition,
    @Default(true) bool pauseOnMouseMove,
    @Default('Space') String pauseKey,
    @Default('fr') String locale,
    Map<String, String>? customShortcuts,
  }) = _SettingsModel;

  factory SettingsModel.fromJson(Map<String, dynamic> json) =>
      _$SettingsModelFromJson(json);
}
