import 'package:flutter/material.dart';


class SummaryScreen extends StatelessWidget {


  
  const SummaryScreen({super.key,});

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary Screen'),
      ),
      body: const Center(
        child: Text('Welcome to the Summary Screen!'),
      ),
    );
  }
}