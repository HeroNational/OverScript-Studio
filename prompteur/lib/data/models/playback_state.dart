import 'dart:typed_data';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'playback_state.freezed.dart';

enum PlaybackContentType {
  text,
  pdf,
}

@freezed
class PlaybackState with _$PlaybackState {
  const factory PlaybackState({
    @Default(false) bool isPlaying,
    @Default(0.0) double scrollPosition,
    @Default(120.0) double speed,
    @Default(false) bool isFullscreen,
    @Default(0) int elapsedSeconds,
    @Default(PlaybackContentType.text) PlaybackContentType contentType,
    @Default(false) bool isLoadingPdf,
    List<Uint8List>? pdfPages,
    String? pdfPath,
    String? pdfError,
    String? richContentJson,
    String? currentText,
  }) = _PlaybackState;
}
