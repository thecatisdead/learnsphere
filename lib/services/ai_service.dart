
import '../../models/question.dart';
import '../../models/flashcard.dart';
import '../../models/flashcarddeck.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {

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

      print("GENERATING QUIZ CHUNK");
      print("Questions: $questionsForThisChunk");
      print("Chunk length: ${chunk.length}");

      final response = await http.post(
        Uri.parse('http://192.168.5.31:8787/quiz'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'chunk': chunk,
          'questionsForThisChunk': questionsForThisChunk,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(response.body);
      }

      final data = jsonDecode(response.body);

      final decoded = data['questions'] as List<dynamic>;

      final chunkQuestions =
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
    print("GENERATING SUMMARY CHUNK");

    print("Chunk length: ${chunk.length}");

    final response = await http.post(
      Uri.parse('http://192.168.5.31:8787/summary'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'context': chunk}),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    final data = jsonDecode(response.body);

    return data['summary'] as String;
  }

  static Future<FlashcardDeck> generateFlashcards(
    String fileName,
    String text,
  ) async {
    print("GENERATING FLASHCARDS CHUNK");

    final chunks = splitIntoChunks(text);
    final List<Flashcard> flashcards = [];

    for (final chunk in chunks) {
      final response = await http.post(
        Uri.parse('http://192.168.5.31:8787/flashcards'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'context': chunk}),
      );

      if (response.statusCode != 200) {
        throw Exception(response.body);
      }

      final data = jsonDecode(response.body);

      final decoded = data['flashcards'] as List<dynamic>;
      final List<Flashcard> chunkFlashcards =
          decoded
              .map((q) => Flashcard.fromJson(q as Map<String, dynamic>))
              .toList();

      flashcards.addAll(chunkFlashcards);
    }

    return FlashcardDeck(fileName: fileName, flashcards: flashcards);
  }

  static Future<String> askAboutPdf({
    required String pdfText,
    required String question,
  }) async {
    print("🔥 askAboutPdf() WAS CALLED");
    final chunks = splitIntoChunks(pdfText);

    final scoredChunks = findRelevantChunks(chunks, question);

    print("Total chunks: ${chunks.length}");

    final relevantChunks =
        scoredChunks.take(3).map((item) => item['chunk'] as String).toList();

    final context = relevantChunks.join("\n\n---\n\n");

    print("SENDING CHAT REQUEST TO WORKER");
    print("Question: $question");
    print("Context length: ${context.length}");

    final response = await http.post(
      Uri.parse('http://192.168.5.31:8787/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'question': question, 'context': context}),
    );
    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    final data = jsonDecode(response.body);

    return data['answer'] as String;
  }

  static List<Map<String, dynamic>> findRelevantChunks(
    List<String> chunks,
    String question,
  ) {
    final words =
        question
            .toLowerCase()
            .split(RegExp(r'\s+'))
            .where((word) => word.length > 3)
            .toList();

    final scoredChunks = <Map<String, dynamic>>[];

    for (final chunk in chunks) {
      final lowerChunk = chunk.toLowerCase();

      int score = 0;

      for (final word in words) {
        if (lowerChunk.contains(word)) {
          score++;
        }
      }

      scoredChunks.add({'chunk': chunk, 'score': score});
    }

    scoredChunks.sort(
      (a, b) => (b['score'] as int).compareTo(a['score'] as int),
    );

    return scoredChunks;
  }
}
