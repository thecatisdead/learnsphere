import  'package:flutter/material.dart';


class QuizzesScreen extends StatelessWidget {
const QuizzesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quizzes'),
      ),
      body: const Center(
        child: Text('Welcome to the Quizzes Screen!'),
      ),
    );
  }
}