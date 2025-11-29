// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ThemeModelImpl _$$ThemeModelImplFromJson(Map<String, dynamic> json) =>
    _$ThemeModelImpl(
      themeType: $enumDecodeNullable(_$AppThemeEnumMap, json['themeType']) ??
          AppTheme.dark,
      primaryBackground: json['primaryBackground'] as String? ?? '#1a1a1a',
      secondaryBackground: json['secondaryBackground'] as String? ?? '#2d2d2d',
      primaryText: json['primaryText'] as String? ?? '#ffffff',
      secondaryText: json['secondaryText'] as String? ?? '#a0a0a0',
      accentColor: json['accentColor'] as String? ?? '#6366F1',
      secondaryAccent: json['secondaryAccent'] as String? ?? '#8B5CF6',
    );

Map<String, dynamic> _$$ThemeModelImplToJson(_$ThemeModelImpl instance) =>
    <String, dynamic>{
      'themeType': _$AppThemeEnumMap[instance.themeType]!,
      'primaryBackground': instance.primaryBackground,
      'secondaryBackground': instance.secondaryBackground,
      'primaryText': instance.primaryText,
      'secondaryText': instance.secondaryText,
      'accentColor': instance.accentColor,
      'secondaryAccent': instance.secondaryAccent,
    };

const _$AppThemeEnumMap = {
  AppTheme.dark: 'dark',
  AppTheme.light: 'light',
  AppTheme.custom: 'custom',
};
