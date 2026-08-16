import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    return ThemeMode.light;
  }

  void toggleTheme() {
    state =
        state == ThemeMode.light
            ? ThemeMode.dark
            : ThemeMode.light;
  }

  void setTheme(ThemeMode themeMode) {
    state = themeMode;
  }
}

final themeModeProvider =
    NotifierProvider<ThemeNotifier, ThemeMode>(
      ThemeNotifier.new,
    );