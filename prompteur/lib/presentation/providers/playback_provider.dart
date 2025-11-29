import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/speed_converter.dart';
import '../../data/models/playback_state.dart';
import '../../data/models/settings_model.dart';
import '../../data/services/pdf_service.dart';
import 'settings_provider.dart';

class PlaybackNotifier extends StateNotifier<PlaybackState> {
  PlaybackNotifier(this._ref, this._pdfService) : super(const PlaybackState()) {
    final settings = _ref.read(settingsProvider);
    state = state.copyWith(speed: settings.defaultSpeed);

    _settingsSub = _ref.listen<SettingsModel>(settingsProvider, (previous, next) {
      if (previous?.defaultSpeed != next.defaultSpeed) {
        updateSpeed(next.defaultSpeed);
      }
      if (previous?.speedUnit != next.speedUnit && state.isPlaying) {
        _stopScrolling();
        _startScrolling();
      }
    });
  }

  final Ref _ref;
  final PdfService _pdfService;
  Timer? _scrollTimer;
  ScrollController? _scrollController;
  late final ProviderSubscription<SettingsModel> _settingsSub;

  void setScrollController(ScrollController controller) {
    _scrollController = controller;
  }

  void setText(String text) {
    _scrollController?.jumpTo(0);
    state = state.copyWith(
      currentText: text,
      contentType: PlaybackContentType.text,
      pdfPages: null,
      pdfPath: null,
      pdfError: null,
      isLoadingPdf: false,
      scrollPosition: 0,
    );
  }

  Future<void> loadPdf(String path) async {
    _scrollController?.jumpTo(0);
    state = state.copyWith(
      contentType: PlaybackContentType.pdf,
      isLoadingPdf: true,
      currentText: null,
      pdfPages: null,
      pdfPath: path,
      pdfError: null,
      scrollPosition: 0,
    );

    try {
      final pages = await _pdfService.renderDocument(path);
      state = state.copyWith(
        isLoadingPdf: false,
        pdfPages: pages,
      );
      if (state.isPlaying) {
        _stopScrolling();
        _startScrolling();
      }
    } catch (e) {
      state = state.copyWith(
        isLoadingPdf: false,
        pdfError: e.toString(),
      );
    }
  }

  void play() {
    if (state.isPlaying) return;
    state = state.copyWith(isPlaying: true);
    _startScrolling();
  }

  void pause() {
    if (!state.isPlaying) return;
    state = state.copyWith(isPlaying: false);
    _stopScrolling();
  }

  void togglePlayPause() {
    if (state.isPlaying) {
      pause();
    } else {
      play();
    }
  }

  void updateSpeed(double speed) {
    state = state.copyWith(speed: speed);
    if (state.isPlaying) {
      _stopScrolling();
      _startScrolling();
    }
  }

  void reset() {
    pause();
    _scrollController?.jumpTo(0);
    state = state.copyWith(scrollPosition: 0);
  }

  void _startScrolling() {
    if (_scrollController == null) return;

    final settings = _ref.read(settingsProvider);
    final pixelsPerSecond = SpeedConverter.toPixelsPerSecond(
      state.speed,
      settings.speedUnit,
      fontSize: settings.fontSize,
    );

    _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (_scrollController == null || !_scrollController!.hasClients) {
        return;
      }

      final delta = pixelsPerSecond / 60;
      final newPosition = _scrollController!.offset + delta;

      if (newPosition >= _scrollController!.position.maxScrollExtent) {
        pause();
        return;
      }

      _scrollController!.jumpTo(newPosition);
      state = state.copyWith(scrollPosition: newPosition);
    });
  }

  void _stopScrolling() {
    _scrollTimer?.cancel();
    _scrollTimer = null;
  }

  void toggleFullscreen() {
    state = state.copyWith(isFullscreen: !state.isFullscreen);
  }

  @override
  void dispose() {
    _stopScrolling();
    _settingsSub.close();
    super.dispose();
  }
}

final playbackProvider = StateNotifierProvider<PlaybackNotifier, PlaybackState>((ref) {
  return PlaybackNotifier(
    ref,
    ref.read(pdfServiceProvider),
  );
});

final pdfServiceProvider = Provider((ref) => PdfService());
