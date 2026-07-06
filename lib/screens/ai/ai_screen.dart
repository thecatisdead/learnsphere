import 'package:flutter/material.dart';


void main() {
  runApp(const MaterialApp(home:AiScreen()));
}

class AiScreen extends StatelessWidget {
  const AiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Screen'),
      ),
      body: const Center(
        child: Text('Welcome to the AI Screen!'),
      ),
    );
  }
}