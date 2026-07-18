import 'package:flutter/material.dart';

class StudyMaterialScreen extends StatelessWidget {
  final String fileName;

  const StudyMaterialScreen({
    super.key,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Study Material"),
      ),
      body: Center(
        child: Text(
          fileName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}