import 'package:flutter_pdf_text/flutter_pdf_text.dart';

class PdfService {
  static Future<String> extractText(String path) async {
    PDFDoc document = await PDFDoc.fromPath(path);

    String text = await document.text;

    return text;
  }
}