// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SettingsModelImpl _$$SettingsModelImplFromJson(Map<String, dynamic> json) =>
    _$SettingsModelImpl(
      defaultSpeed: (json['defaultSpeed'] as num?)?.toDouble() ?? 120.0,
      speedUnit: $enumDecodeNullable(_$SpeedUnitEnumMap, json['speedUnit']) ??
          SpeedUnit.pixelsPerSecond,
      autoFullscreen: json['autoFullscreen'] as bool? ?? true,
      enableFocusMode: json['enableFocusMode'] as bool? ?? false,
      backgroundColor: json['backgroundColor'] as String? ?? '#1a1a1a',
      textColor: json['textColor'] as String? ?? '#ffffff',
      fontFamily: json['fontFamily'] as String? ?? 'System',
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 48.0,
      toolbarPosition: $enumDecodeNullable(
              _$ToolbarPositionEnumMap, json['toolbarPosition']) ??
          ToolbarPosition.bottom,
      toolbarScale: (json['toolbarScale'] as num?)?.toDouble() ?? 1.0,
      toolboxTheme:
          $enumDecodeNullable(_$ToolboxThemeEnumMap, json['toolboxTheme']) ??
              ToolboxTheme.modern,
      toolbarOrientation: $enumDecodeNullable(
              _$ToolbarOrientationEnumMap, json['toolbarOrientation']) ??
          ToolbarOrientation.auto,
      pauseOnMouseMove: json['pauseOnMouseMove'] as bool? ?? true,
      pauseKey: json['pauseKey'] as String? ?? 'Space',
      locale: json['locale'] as String? ?? 'fr',
      showTimers: json['showTimers'] as bool? ?? true,
      countdownDuration: (json['countdownDuration'] as num?)?.toInt() ?? 5,
      customShortcuts: (json['customShortcuts'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$$SettingsModelImplToJson(_$SettingsModelImpl instance) =>
    <String, dynamic>{
      'defaultSpeed': instance.defaultSpeed,
      'speedUnit': _$SpeedUnitEnumMap[instance.speedUnit]!,
      'autoFullscreen': instance.autoFullscreen,
      'enableFocusMode': instance.enableFocusMode,
      'backgroundColor': instance.backgroundColor,
      'textColor': instance.textColor,
      'fontFamily': instance.fontFamily,
      'fontSize': instance.fontSize,
      'toolbarPosition': _$ToolbarPositionEnumMap[instance.toolbarPosition]!,
      'toolbarScale': instance.toolbarScale,
      'toolboxTheme': _$ToolboxThemeEnumMap[instance.toolboxTheme]!,
      'toolbarOrientation':
          _$ToolbarOrientationEnumMap[instance.toolbarOrientation]!,
      'pauseOnMouseMove': instance.pauseOnMouseMove,
      'pauseKey': instance.pauseKey,
      'locale': instance.locale,
      'showTimers': instance.showTimers,
      'countdownDuration': instance.countdownDuration,
      'customShortcuts': instance.customShortcuts,
    };

const _$SpeedUnitEnumMap = {
  SpeedUnit.pixelsPerSecond: 'pixelsPerSecond',
  SpeedUnit.linesPerMinute: 'linesPerMinute',
  SpeedUnit.wordsPerMinute: 'wordsPerMinute',
};

const _$ToolbarPositionEnumMap = {
  ToolbarPosition.top: 'top',
  ToolbarPosition.bottom: 'bottom',
  ToolbarPosition.left: 'left',
  ToolbarPosition.right: 'right',
  ToolbarPosition.topCenter: 'topCenter',
  ToolbarPosition.bottomCenter: 'bottomCenter',
  ToolbarPosition.topLeft: 'topLeft',
  ToolbarPosition.topRight: 'topRight',
  ToolbarPosition.bottomLeft: 'bottomLeft',
  ToolbarPosition.bottomRight: 'bottomRight',
};

const _$ToolboxThemeEnumMap = {
  ToolboxTheme.modern: 'modern',
  ToolboxTheme.glass: 'glass',
  ToolboxTheme.contrast: 'contrast',
};

const _$ToolbarOrientationEnumMap = {
  ToolbarOrientation.auto: 'auto',
  ToolbarOrientation.horizontal: 'horizontal',
  ToolbarOrientation.vertical: 'vertical',
};
