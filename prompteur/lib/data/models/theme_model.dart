import 'package:freezed_annotation/freezed_annotation.dart';

part 'theme_model.freezed.dart';
part 'theme_model.g.dart';

enum AppTheme {
  dark,
  light,
  custom,
}

@freezed
class ThemeModel with _$ThemeModel {
  const factory ThemeModel({
    @Default(AppTheme.dark) AppTheme themeType,
    @Default('#1a1a1a') String primaryBackground,
    @Default('#2d2d2d') String secondaryBackground,
    @Default('#ffffff') String primaryText,
    @Default('#a0a0a0') String secondaryText,
    @Default('#6366F1') String accentColor,
    @Default('#8B5CF6') String secondaryAccent,
  }) = _ThemeModel;

  factory ThemeModel.fromJson(Map<String, dynamic> json) =>
      _$ThemeModelFromJson(json);

  // Thèmes prédéfinis
  static const ThemeModel darkTheme = ThemeModel(
    themeType: AppTheme.dark,
    primaryBackground: '#1a1a1a',
    secondaryBackground: '#2d2d2d',
    primaryText: '#ffffff',
    secondaryText: '#a0a0a0',
    accentColor: '#6366F1',
    secondaryAccent: '#8B5CF6',
  );

  static const ThemeModel lightTheme = ThemeModel(
    themeType: AppTheme.light,
    primaryBackground: '#f5f5f5',
    secondaryBackground: '#e0e0e0',
    primaryText: '#1a1a1a',
    secondaryText: '#5a5a5a',
    accentColor: '#6366F1',
    secondaryAccent: '#8B5CF6',
  );
}
