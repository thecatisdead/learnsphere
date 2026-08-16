import 'package:flutter/material.dart';
import 'app/main_navigation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import 'providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      themeMode: themeMode,

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
      ),

      home: const MainNavigation(),
    );
  }
}