import 'dart:typed_data';
import 'package:pdfx/pdfx.dart';

class PdfService {
  /// Rend chaque page du document en image PNG pour un défilement fluide.
  Future<List<Uint8List>> renderDocument(String path, {int targetWidth = 1400}) async {
    final document = await PdfDocument.openFile(path);
    final pages = <Uint8List>[];

    try {
      for (var i = 1; i <= document.pagesCount; i++) {
        final page = await document.getPage(i);
        final pageImage = await page.render(
          width: targetWidth,
          height: (targetWidth / page.width) * page.height,
          format: PdfPageImageFormat.png,
          backgroundColor: '#000000',
        );
        pages.add(pageImage.bytes);
        await page.close();
      }
    } finally {
      await document.close();
    }

    return pages;
  }
}
