import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/speed_converter.dart';
import '../../../data/models/settings_model.dart';
import '../../providers/playback_provider.dart';
import '../../providers/settings_provider.dart';

class SpeedControl extends ConsumerWidget {
  const SpeedControl({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playbackState = ref.watch(playbackProvider);
    final settings = ref.watch(settingsProvider);

    // Convertir la vitesse actuelle vers l'unité affichée
    final displaySpeed = SpeedConverter.fromPixelsPerSecond(
      playbackState.speed,
      settings.speedUnit,
      fontSize: settings.fontSize,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Vitesse: ${displaySpeed.toStringAsFixed(0)} ${SpeedConverter.getUnitLabel(settings.speedUnit)}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 300,
          child: Slider(
            value: displaySpeed,
            min: _getMinSpeed(settings.speedUnit),
            max: _getMaxSpeed(settings.speedUnit),
            divisions: 100,
            onChanged: (value) {
              // Convertir la valeur vers pixels par seconde
              final pixelsPerSecond = SpeedConverter.toPixelsPerSecond(
                value,
                settings.speedUnit,
                fontSize: settings.fontSize,
              );
              ref.read(playbackProvider.notifier).updateSpeed(pixelsPerSecond);
            },
          ),
        ),
      ],
    );
  }

  double _getMinSpeed(SpeedUnit unit) {
    switch (unit) {
      case SpeedUnit.pixelsPerSecond:
        return 10.0;
      case SpeedUnit.linesPerMinute:
        return 5.0;
      case SpeedUnit.wordsPerMinute:
        return 50.0;
    }
  }

  double _getMaxSpeed(SpeedUnit unit) {
    switch (unit) {
      case SpeedUnit.pixelsPerSecond:
        return 500.0;
      case SpeedUnit.linesPerMinute:
        return 100.0;
      case SpeedUnit.wordsPerMinute:
        return 1000.0;
    }
  }
}
