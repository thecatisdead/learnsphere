import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get geminiApiKey {
    final key = dotenv.env['GEMINI_API_KEY'];

    if (key == null || key.isEmpty) {
      throw Exception('GEMINI_API_KEY not found.');
    }

    return key;
  }
}