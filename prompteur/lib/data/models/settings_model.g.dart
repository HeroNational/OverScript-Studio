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
      pauseOnMouseMove: json['pauseOnMouseMove'] as bool? ?? true,
      pauseKey: json['pauseKey'] as String? ?? 'Space',
      locale: json['locale'] as String? ?? 'fr',
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
      'pauseOnMouseMove': instance.pauseOnMouseMove,
      'pauseKey': instance.pauseKey,
      'locale': instance.locale,
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
};
