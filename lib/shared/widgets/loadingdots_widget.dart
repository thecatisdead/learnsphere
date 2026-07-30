import 'dart:async';
import 'package:flutter/material.dart';

class LoadingDots extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const LoadingDots({super.key, required this.text, this.style});

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots> {
  int dots = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      setState(() {
        dots = (dots + 1) % 4;
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      "${widget.text}${"." * dots}",
      style:
          widget.style ??
          const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF2C2C2A),
          ),
    );
  }
}
