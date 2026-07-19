import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: PlannerScreen()));
}

class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(child: Text('Welcome to the Planner Screen!')),
    );
  }
}
