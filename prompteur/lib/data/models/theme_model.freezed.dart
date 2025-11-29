// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'theme_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ThemeModel _$ThemeModelFromJson(Map<String, dynamic> json) {
  return _ThemeModel.fromJson(json);
}

/// @nodoc
mixin _$ThemeModel {
  AppTheme get themeType => throw _privateConstructorUsedError;
  String get primaryBackground => throw _privateConstructorUsedError;
  String get secondaryBackground => throw _privateConstructorUsedError;
  String get primaryText => throw _privateConstructorUsedError;
  String get secondaryText => throw _privateConstructorUsedError;
  String get accentColor => throw _privateConstructorUsedError;
  String get secondaryAccent => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ThemeModelCopyWith<ThemeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ThemeModelCopyWith<$Res> {
  factory $ThemeModelCopyWith(
          ThemeModel value, $Res Function(ThemeModel) then) =
      _$ThemeModelCopyWithImpl<$Res, ThemeModel>;
  @useResult
  $Res call(
      {AppTheme themeType,
      String primaryBackground,
      String secondaryBackground,
      String primaryText,
      String secondaryText,
      String accentColor,
      String secondaryAccent});
}

/// @nodoc
class _$ThemeModelCopyWithImpl<$Res, $Val extends ThemeModel>
    implements $ThemeModelCopyWith<$Res> {
  _$ThemeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? themeType = null,
    Object? primaryBackground = null,
    Object? secondaryBackground = null,
    Object? primaryText = null,
    Object? secondaryText = null,
    Object? accentColor = null,
    Object? secondaryAccent = null,
  }) {
    return _then(_value.copyWith(
      themeType: null == themeType
          ? _value.themeType
          : themeType // ignore: cast_nullable_to_non_nullable
              as AppTheme,
      primaryBackground: null == primaryBackground
          ? _value.primaryBackground
          : primaryBackground // ignore: cast_nullable_to_non_nullable
              as String,
      secondaryBackground: null == secondaryBackground
          ? _value.secondaryBackground
          : secondaryBackground // ignore: cast_nullable_to_non_nullable
              as String,
      primaryText: null == primaryText
          ? _value.primaryText
          : primaryText // ignore: cast_nullable_to_non_nullable
              as String,
      secondaryText: null == secondaryText
          ? _value.secondaryText
          : secondaryText // ignore: cast_nullable_to_non_nullable
              as String,
      accentColor: null == accentColor
          ? _value.accentColor
          : accentColor // ignore: cast_nullable_to_non_nullable
              as String,
      secondaryAccent: null == secondaryAccent
          ? _value.secondaryAccent
          : secondaryAccent // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ThemeModelImplCopyWith<$Res>
    implements $ThemeModelCopyWith<$Res> {
  factory _$$ThemeModelImplCopyWith(
          _$ThemeModelImpl value, $Res Function(_$ThemeModelImpl) then) =
      __$$ThemeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {AppTheme themeType,
      String primaryBackground,
      String secondaryBackground,
      String primaryText,
      String secondaryText,
      String accentColor,
      String secondaryAccent});
}

/// @nodoc
class __$$ThemeModelImplCopyWithImpl<$Res>
    extends _$ThemeModelCopyWithImpl<$Res, _$ThemeModelImpl>
    implements _$$ThemeModelImplCopyWith<$Res> {
  __$$ThemeModelImplCopyWithImpl(
      _$ThemeModelImpl _value, $Res Function(_$ThemeModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? themeType = null,
    Object? primaryBackground = null,
    Object? secondaryBackground = null,
    Object? primaryText = null,
    Object? secondaryText = null,
    Object? accentColor = null,
    Object? secondaryAccent = null,
  }) {
    return _then(_$ThemeModelImpl(
      themeType: null == themeType
          ? _value.themeType
          : themeType // ignore: cast_nullable_to_non_nullable
              as AppTheme,
      primaryBackground: null == primaryBackground
          ? _value.primaryBackground
          : primaryBackground // ignore: cast_nullable_to_non_nullable
              as String,
      secondaryBackground: null == secondaryBackground
          ? _value.secondaryBackground
          : secondaryBackground // ignore: cast_nullable_to_non_nullable
              as String,
      primaryText: null == primaryText
          ? _value.primaryText
          : primaryText // ignore: cast_nullable_to_non_nullable
              as String,
      secondaryText: null == secondaryText
          ? _value.secondaryText
          : secondaryText // ignore: cast_nullable_to_non_nullable
              as String,
      accentColor: null == accentColor
          ? _value.accentColor
          : accentColor // ignore: cast_nullable_to_non_nullable
              as String,
      secondaryAccent: null == secondaryAccent
          ? _value.secondaryAccent
          : secondaryAccent // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ThemeModelImpl implements _ThemeModel {
  const _$ThemeModelImpl(
      {this.themeType = AppTheme.dark,
      this.primaryBackground = '#1a1a1a',
      this.secondaryBackground = '#2d2d2d',
      this.primaryText = '#ffffff',
      this.secondaryText = '#a0a0a0',
      this.accentColor = '#6366F1',
      this.secondaryAccent = '#8B5CF6'});

  factory _$ThemeModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ThemeModelImplFromJson(json);

  @override
  @JsonKey()
  final AppTheme themeType;
  @override
  @JsonKey()
  final String primaryBackground;
  @override
  @JsonKey()
  final String secondaryBackground;
  @override
  @JsonKey()
  final String primaryText;
  @override
  @JsonKey()
  final String secondaryText;
  @override
  @JsonKey()
  final String accentColor;
  @override
  @JsonKey()
  final String secondaryAccent;

  @override
  String toString() {
    return 'ThemeModel(themeType: $themeType, primaryBackground: $primaryBackground, secondaryBackground: $secondaryBackground, primaryText: $primaryText, secondaryText: $secondaryText, accentColor: $accentColor, secondaryAccent: $secondaryAccent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ThemeModelImpl &&
            (identical(other.themeType, themeType) ||
                other.themeType == themeType) &&
            (identical(other.primaryBackground, primaryBackground) ||
                other.primaryBackground == primaryBackground) &&
            (identical(other.secondaryBackground, secondaryBackground) ||
                other.secondaryBackground == secondaryBackground) &&
            (identical(other.primaryText, primaryText) ||
                other.primaryText == primaryText) &&
            (identical(other.secondaryText, secondaryText) ||
                other.secondaryText == secondaryText) &&
            (identical(other.accentColor, accentColor) ||
                other.accentColor == accentColor) &&
            (identical(other.secondaryAccent, secondaryAccent) ||
                other.secondaryAccent == secondaryAccent));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      themeType,
      primaryBackground,
      secondaryBackground,
      primaryText,
      secondaryText,
      accentColor,
      secondaryAccent);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ThemeModelImplCopyWith<_$ThemeModelImpl> get copyWith =>
      __$$ThemeModelImplCopyWithImpl<_$ThemeModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ThemeModelImplToJson(
      this,
    );
  }
}

abstract class _ThemeModel implements ThemeModel {
  const factory _ThemeModel(
      {final AppTheme themeType,
      final String primaryBackground,
      final String secondaryBackground,
      final String primaryText,
      final String secondaryText,
      final String accentColor,
      final String secondaryAccent}) = _$ThemeModelImpl;

  factory _ThemeModel.fromJson(Map<String, dynamic> json) =
      _$ThemeModelImpl.fromJson;

  @override
  AppTheme get themeType;
  @override
  String get primaryBackground;
  @override
  String get secondaryBackground;
  @override
  String get primaryText;
  @override
  String get secondaryText;
  @override
  String get accentColor;
  @override
  String get secondaryAccent;
  @override
  @JsonKey(ignore: true)
  _$$ThemeModelImplCopyWith<_$ThemeModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
