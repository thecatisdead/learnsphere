import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learnsphere/services/pdf_services.dart';

class PdfTextNotifier extends Notifier<Map<String, String>> {
  @override
  Map<String, String> build() {
    return {};
  }

  void setText({required String filePath, required String text}) {
    state = {...state, filePath: text};
  }

  String? getText(String filePath) {
    return state[filePath];
  }

  Future<String> loadText(String filePath) async {
    final existingText = state[filePath];

    if (existingText != null) {
      return existingText;
    }

    final text = await PdfService.extractText(filePath);

    setText(filePath: filePath, text: text);

    return text;
  }

  void clearText(String filePath) {
    final newState = {...state};
    newState.remove(filePath);
    state = newState;
  }

  void clearAll() {
    state = {};
  }
}

final pdfTextProvider = NotifierProvider<PdfTextNotifier, Map<String, String>>(
  PdfTextNotifier.new,
);
