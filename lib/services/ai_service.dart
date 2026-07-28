import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models/question.dart';
import '../../models/flashcard.dart';
import '../../models/flashcarddeck.dart';
import 'dart:convert';

class AiService {
  static final model = GenerativeModel(
    model: "gemini-3.1-flash-lite",
    apiKey: dotenv.env['GEMINI_API_KEY']!,
  );
  static Future<List<Question>> generateQuiz(String text) async {
    final chunks = splitIntoChunks(text);

    final totalQuestions = 10;

    final chunkCount = chunks.length;

    final questionsPerChunk = totalQuestions ~/ chunkCount;
    final List<Question> questions = [];

    var remainingQuestions = totalQuestions - (questionsPerChunk * chunkCount);

    for (final chunk in chunks) {
      int questionsForThisChunk = questionsPerChunk;

      if (remainingQuestions > 0) {
        questionsForThisChunk++;
        remainingQuestions--;
      }

      final prompt = """

You are an AI that generates study quizzes.

Based on the following document, generate exactly $questionsForThisChunk multiple-choice questions.

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

$chunk
""";

      final response = await model.generateContent([Content.text(prompt)]);

      final responseText = response.text ?? "";

      print(responseText);

      print(responseText.substring(0, 300));
      print("...");
      print(responseText.substring(responseText.length - 300));
      final decoded = jsonDecode(response.text!) as List<dynamic>;
      final List<Question> chunkQuestions =
          decoded
              .map((q) => Question.fromJson(q as Map<String, dynamic>))
              .toList();

      questions.addAll(chunkQuestions);
    }

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

  static Future<FlashcardDeck> generateFlashcards(
    String fileName,
    String text,
  ) async {
    final chunks = splitIntoChunks(text);
    final List<Flashcard> flashcards = [];

    for (final chunk in chunks) {
      final prompt = """ You are an AI that creates study flashcards.

Based on the following study material, generate flashcards for the most important concepts.

Rules:
- Return ONLY valid JSON.
- Do NOT use markdown.
- Do NOT explain anything.
- Each flashcard must have:
  - "front"
  - "back"
- Keep the front short.
- Keep the back clear and concise.

Return this format:

[
  {
    "front": "...",
    "back": "..."
  }
]

Document:

$chunk """;

      final response = await model.generateContent([Content.text(prompt)]);
      final decoded = jsonDecode(response.text!) as List<dynamic>;
      final List<Flashcard> chunkFlashcards =
          decoded
              .map((q) => Flashcard.fromJson(q as Map<String, dynamic>))
              .toList();

               flashcards.addAll(chunkFlashcards);
    }

    return FlashcardDeck(fileName: fileName, flashcards: flashcards);
  }
}
