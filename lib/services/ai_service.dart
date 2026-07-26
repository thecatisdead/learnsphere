import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models/question.dart';
import 'dart:convert';

class AiService {
  static final model = GenerativeModel(
    model: "gemini-3.1-flash-lite",
    apiKey: dotenv.env['GEMINI_API_KEY']!,
  );
  static Future<List<Question>> generateQuiz(String text) async {
    final chunks = splitIntoChunks(text);
    final firstChunk = chunks.first;
    final prompt = '''
You are an AI that generates study quizzes.

Based on the following document, generate exactly 10 multiple-choice questions.

Rules:
- Return ONLY valid JSON.
- Do NOT use markdown.
- Do NOT explain anything.
- Each question must have exactly 4 options.
- Only one option is correct.
- The correctAnswer must exactly match one option.

Return this format:

[
  {
    "question": "...",
    "options": [
      "...",
      "...",
      "...",
      "..."
    ],
    "correctAnswer": "..."
  }
]

Document:

$firstChunk
''';
    final response = await model.generateContent([Content.text(prompt)]);

    final responseText = response.text ?? "";

    print(responseText);

    print(responseText.substring(0, 300));
    print("...");
    print(responseText.substring(responseText.length - 300));

    final decoded = jsonDecode(responseText) as List;

    final questions = decoded.map((q) => Question.fromJson(q)).toList();

    return questions;
  }

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
