import 'question.dart';

class Quiz {
  final String fileName;
  final List<Question> questions;

  const Quiz({
    required this.fileName,
    required this.questions,
  });
}