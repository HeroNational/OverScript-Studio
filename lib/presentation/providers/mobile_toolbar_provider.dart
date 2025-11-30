import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/settings_model.dart';

class MobileToolbarOrientationNotifier extends StateNotifier<ToolbarOrientation> {
  MobileToolbarOrientationNotifier() : super(ToolbarOrientation.auto);

  void toggleOrientation() {
    state = switch (state) {
      ToolbarOrientation.auto => ToolbarOrientation.horizontal,
      ToolbarOrientation.horizontal => ToolbarOrientation.vertical,
      ToolbarOrientation.vertical => ToolbarOrientation.auto,
    };
  }

  void reset() {
    state = ToolbarOrientation.auto;
  }
}

final mobileToolbarOrientationProvider =
    StateNotifierProvider<MobileToolbarOrientationNotifier, ToolbarOrientation>(
  (ref) => MobileToolbarOrientationNotifier(),
);