import 'dart:typed_data';
import 'package:pdfx/pdfx.dart';

class PdfService {
  /// Rend chaque page du document en image PNG pour un défilement fluide.
  Future<List<Uint8List>> renderDocument(
    String path, {
    int targetWidth = 1400,
    String backgroundColorHex = '#FFFFFF',
  }) async {
    final document = await PdfDocument.openFile(path);
    final pages = <Uint8List>[];
    final sanitizedColor = _sanitizeHex(backgroundColorHex);

    try {
      for (var i = 1; i <= document.pagesCount; i++) {
        final page = await document.getPage(i);
        final renderWidth = targetWidth.toDouble();
        final renderHeight = (renderWidth / page.width) * page.height;

        final pageImage = await page.render(
          width: renderWidth,
          height: renderHeight,
          format: PdfPageImageFormat.png,
          backgroundColor: sanitizedColor,
        );
        final bytes = pageImage?.bytes;
        if (bytes != null) {
          pages.add(bytes);
        }
        await page.close();
      }
    } finally {
      await document.close();
    }

    return pages;
  }

  /// S'assure que la couleur est bien au format #RRGGBB.
  String _sanitizeHex(String hex) {
    var value = hex.trim();
    if (!value.startsWith('#')) {
      value = '#$value';
    }
    // On accepte #RGB ou #RRGGBB. Si invalide, on retourne blanc.
    if (value.length == 4) {
      // #RGB -> #RRGGBB
      final r = value[1];
      final g = value[2];
      final b = value[3];
      value = '#$r$r$g$g$b$b';
    }
    if (value.length != 7) {
      return '#FFFFFF';
    }
    return value.toUpperCase();
  }
}
