import  'package:flutter/material.dart';

class SubjectCard extends StatelessWidget {
  final String title;

  const SubjectCard({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
      ),
    );
  }
}