class SubtitleParser {
  static final _timestampLine = RegExp(
    r'^(?:\d{1,2}:)?\d{2}:\d{2}(?:[.,]\d{3})?\s+-->\s+(?:\d{1,2}:)?\d{2}:\d{2}(?:[.,]\d{3})?',
  );
  static final _numericCue = RegExp(r'^\d+$');
  static final _speakerLine = RegExp(r'^[A-Za-zÀ-ÿ0-9 ,._-]+:$');
  static final _metadataPrefixes = <String>[
    'WEBVTT',
    'NOTE',
    'STYLE',
    'REGION',
    'X-TIMESTAMP-MAP',
    'Kind:',
    'Language:',
    'Author:',
    'Title:',
  ];

  /// Supprime les lignes de métadonnées/timestamps des fichiers SRT/VTT.
  static String cleanSubtitleContent(String raw) {
    final normalized = raw.replaceAll('\r\n', '\n');
    final lines = normalized.split('\n');
    final cleanedLines = <String>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        // Préserve des sauts de paragraphe sans multiplier les lignes vides.
        if (cleanedLines.isNotEmpty && cleanedLines.last.isNotEmpty) {
          cleanedLines.add('');
        }
        continue;
      }

      if (_timestampLine.hasMatch(trimmed)) continue;
      if (_numericCue.hasMatch(trimmed)) continue;
      if (_metadataPrefixes.any((prefix) => trimmed.startsWith(prefix))) {
        continue;
      }
      if (_speakerLine.hasMatch(trimmed)) continue;

      cleanedLines.add(trimmed);
    }

    return cleanedLines.join('\n').trim();
  }
}
