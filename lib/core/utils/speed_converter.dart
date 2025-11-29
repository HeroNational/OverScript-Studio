import '../../data/models/settings_model.dart';

class SpeedConverter {
  /// Convertit une valeur de vitesse vers pixels par seconde (unité de base)
  static double toPixelsPerSecond(
    double value,
    SpeedUnit unit, {
    double fontSize = 48.0,
    double lineHeight = 1.5,
  }) {
    switch (unit) {
      case SpeedUnit.pixelsPerSecond:
        return value;
      case SpeedUnit.linesPerMinute:
        final lineHeightPx = fontSize * lineHeight;
        return (value * lineHeightPx) / 60;
      case SpeedUnit.wordsPerMinute:
        // Moyenne: ~10 mots par ligne
        const wordsPerLine = 10;
        final linesPerMinute = value / wordsPerLine;
        final lineHeightPx = fontSize * lineHeight;
        return (linesPerMinute * lineHeightPx) / 60;
    }
  }

  /// Convertit pixels par seconde vers l'unité cible
  static double fromPixelsPerSecond(
    double pixelsPerSecond,
    SpeedUnit targetUnit, {
    double fontSize = 48.0,
    double lineHeight = 1.5,
  }) {
    switch (targetUnit) {
      case SpeedUnit.pixelsPerSecond:
        return pixelsPerSecond;
      case SpeedUnit.linesPerMinute:
        final lineHeightPx = fontSize * lineHeight;
        return (pixelsPerSecond * 60) / lineHeightPx;
      case SpeedUnit.wordsPerMinute:
        final lineHeightPx = fontSize * lineHeight;
        final linesPerMinute = (pixelsPerSecond * 60) / lineHeightPx;
        return linesPerMinute * 10; // ~10 mots par ligne
    }
  }

  /// Retourne le label de l'unité
  static String getUnitLabel(SpeedUnit unit) {
    switch (unit) {
      case SpeedUnit.pixelsPerSecond:
        return 'px/s';
      case SpeedUnit.linesPerMinute:
        return 'lignes/min';
      case SpeedUnit.wordsPerMinute:
        return 'mots/min';
    }
  }
}
