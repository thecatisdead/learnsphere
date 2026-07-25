import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiService {
  static final model = GenerativeModel(
    model: "gemini-3.1-flash-lite",
    apiKey: dotenv.env['GEMINI_API_KEY']!,
  );

  static List<String> splitIntoChunks(String text, {int chunkSize = 8000}) {
    final chunks = <String>[];

    for (int i = 0; i < text.length; i += chunkSize) {
      final end = (i + chunkSize < text.length) ? i + chunkSize : text.length;

      chunks.add(text.substring(i, end));
    }

    return chunks;
  }

  static Future<String> generateSummary(String text) async {
    final chunks = splitIntoChunks(text);

    final summaries = <String>[];

    for (final chunk in chunks) {
      final summary = await summarizeChunk(chunk);
      summaries.add(summary);
    }

    return summaries.join("\n\n");
  }

  static Future<String> summarizeChunk(String chunk) async {
    final prompt = """
You are an expert study assistant.

Summarize the following study material into concise bullet points.

$chunk
""";

    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        final response = await model.generateContent([Content.text(prompt)]);

        return response.text ?? "";
      } catch (e) {
        if (attempt == 3) rethrow;

        await Future.delayed(const Duration(seconds: 2));
      }
    }

    final response = await model.generateContent([Content.text(prompt)]);

    return response.text ?? "";
  }
}
