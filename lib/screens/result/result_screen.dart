import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget{

  final int score;
  final int totalQuestions;

const ResultScreen({super.key, required this.score, required this.totalQuestions});

@override

Widget build(BuildContext context){
return Scaffold(
  appBar: AppBar(title: const Text("Result Screen")),
); 
}

}

