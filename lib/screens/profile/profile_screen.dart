import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/providers/theme_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("Dark Mode"),
            secondary: const Icon(Icons.dark_mode),
            value: themeMode == ThemeMode.dark,
            onChanged: (isDark) {
              ref
                  .read(themeModeProvider.notifier)
                  .setTheme(isDark ? ThemeMode.dark : ThemeMode.light);
            },
          ),
        ],
      ),
    );
  }
}
