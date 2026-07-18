import 'package:flutter/material.dart';

class SubjectCard extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const SubjectCard({super.key, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(onTap: onTap, child: ListTile(title: Text(title))),
    );
  }
}
