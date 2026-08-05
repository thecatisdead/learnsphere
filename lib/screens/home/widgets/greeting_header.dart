import 'package:flutter/material.dart';

class GreetingHeader extends StatefulWidget {
  const GreetingHeader({super.key});

  @override
  State<GreetingHeader> createState() => _GreetingHeaderState();
}

class _GreetingHeaderState extends State<GreetingHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _waveAnimation = Tween<double>(begin: -0.15, end: 0.15).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );

    _waveController.repeat(
      reverse: true,
      period: const Duration(milliseconds: 350),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _waveController.stop();
      }
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 18) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '${getGreeting()} ',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: AnimatedBuilder(
                  animation: _waveAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _waveAnimation.value,
                      child: child,
                    );
                  },
                  child: const Text('👋', style: TextStyle(fontSize: 30)),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 6),

        Text(
          'Ready to continue learning?',
          style: TextStyle(fontSize: 15, color: Colors.grey),
        ),
      ],
    );
  }
}
