
import 'package:flutter/material.dart';


class LessonOptionCard extends StatelessWidget {

  final IconData icon;
  final Color color;
  final String title;
  final VoidCallback onTap;

  const LessonOptionCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Row(children: [
          Icon(icon, size: 40, color: color),
          
          SizedBox(width: 16),
          Text(title, style: TextStyle(fontSize: 18)),
          Spacer(),
          Icon(Icons.arrow_forward_ios, size: 16),
        ],)
      )
    );

  }



}

