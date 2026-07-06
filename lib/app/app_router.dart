import 'package:go_router/go_router.dart';

import '../screens/home/home_screen.dart';
import '../screens/ai/ai_screen.dart';
import '../screens/planner/planner_screen.dart';
import '../screens/profile/profile_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/ai',
      builder: (context, state) => const AiScreen(),
    ),
     
    GoRoute(
      path: '/planner',
      builder: (context, state) => const PlannerScreen(),
    ),
    
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);