import 'package:flutter/material.dart';

class VideoScreen extends StatelessWidget {
  const VideoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Videos')),
      body: const Center(child: Text('Welcome to the Videos Screen!')),
    );
  }
}
