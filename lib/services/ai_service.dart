import '../../models/question.dart';
import '../../models/flashcard.dart';
import '../../models/flashcarddeck.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/chat_message.dart';

import 'dart:async';
import 'dart:io';

class AiService {
  static Future<http.Response> postRequest({
    required String url,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 40));

      if (response.statusCode == 429) {
        throw Exception(
          "RATE_LIMIT: Too many requests. Please try again later.",
        );
      }

      if (response.statusCode >= 500) {
        throw Exception(
          "SERVER_ERROR: The AI server is currently unavailable.",
        );
      }

      if (response.statusCode != 200) {
        throw Exception("REQUEST_ERROR: ${response.body}");
      }

      return response;
    } on TimeoutException {
      throw Exception("TIMEOUT: The request took too long. Please try again.");
    } on SocketException {
      throw Exception("NO_INTERNET: Please check your internet connection.");
    }
  }

  //Quiz

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
      final response = await postRequest(
        url: 'https://backend.regeryl1100.workers.dev/quiz',
        body: {'chunk': chunk, 'questionsForThisChunk': questionsForThisChunk},
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

  static List<String> splitIntoChunks(String text, {int chunkSize = 3000}) {
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

  //Summary
  static Future<String> summarizeChunk(String chunk) async {
    print("GENERATING SUMMARY CHUNK");
    print("Chunk length: ${chunk.length}");

    final response = await postRequest(
      url: 'https://backend.regeryl1100.workers.dev/summary',
      body: {'context': chunk},
    );

    final data = jsonDecode(response.body);
    return data['summary'] as String;
  }

  //Flashcards
  static Future<FlashcardDeck> generateFlashcards(
    String fileName,
    String text,
  ) async {
    print("GENERATING FLASHCARDS CHUNK");

    final chunks = splitIntoChunks(text);
    final List<Flashcard> flashcards = [];

    for (final chunk in chunks) {
      final response = await postRequest(
        url: 'https://backend.regeryl1100.workers.dev/flashcards',
        body: {'context': chunk},
      );

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

  //Chat
  static Future<String> askAboutPdf({
    required String fileName,
    required String question,
    required List<ChatMessage> history,
  }) async {
    Future<String> attempt() async {
      final response = await postRequest(
        url: 'https://backend.regeryl1100.workers.dev/chat',
        body: {
          'fileName': fileName,
          'question': question,
          'history':
              history
                  .map(
                    (m) => {
                      'role': m.isUser ? 'user' : 'assistant',
                      'text': m.text,
                    },
                  )
                  .toList(),
        },
      );

      final data = jsonDecode(response.body);
      return data['answer'] as String;
    }

    try {
      return await attempt();
    } catch (_) {
      // one silent retry — covers cold starts / transient network blips
      return await attempt();
    }
  }

  static Future<void> indexPdf({
    required String fileName,
    required String text,
  }) async {
    final chunks = splitIntoChunks(text);

    await postRequest(
      url: 'https://backend.regeryl1100.workers.dev/index-pdf',
      body: {'fileName': fileName, 'chunks': chunks},
    );
  }
}
