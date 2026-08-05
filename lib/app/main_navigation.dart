import 'package:flutter/material.dart';

import '../screens/home/home_screen.dart';
import '../screens/ai/ai_screen.dart';
import '../screens/planner/planner_screen.dart';
import '../screens/profile/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int currentIndex = 0;

  final pages = const [
    HomeScreen(),
    AiScreen(),
    PlannerScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],

      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          height: 72,

          backgroundColor: Theme.of(context).scaffoldBackgroundColor,

          elevation: 0,

          indicatorColor: Theme.of(
            context,
          ).colorScheme.primary.withOpacity(0.12),

          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),

          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(fontSize: 12, fontWeight: FontWeight.w600);
            }

            return const TextStyle(fontSize: 12, fontWeight: FontWeight.w500);
          }),

          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return IconThemeData(
                size: 23,
                color: Theme.of(context).colorScheme.primary,
              );
            }

            return IconThemeData(size: 22, color: Colors.grey.shade600);
          }),
        ),

        child: NavigationBar(
          selectedIndex: currentIndex,

          onDestinationSelected: (index) {
            setState(() {
              currentIndex = index;
            });
          },

          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: "Home",
            ),

            NavigationDestination(
              icon: Icon(Icons.auto_awesome_outlined),
              selectedIcon: Icon(Icons.auto_awesome_rounded),
              label: "AI",
            ),

            NavigationDestination(
              icon: Icon(Icons.calendar_today_outlined),
              selectedIcon: Icon(Icons.calendar_today_rounded),
              label: "Planner",
            ),

            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
