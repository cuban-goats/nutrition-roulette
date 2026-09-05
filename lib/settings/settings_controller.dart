import 'package:flutter/material.dart';

const _defaultSeed = Color(0xFF4CAF50);

const availableSeeds = <SeedOption>[
  SeedOption(label: 'Green', color: Color(0xFF4CAF50)),
  SeedOption(label: 'Red', color: Color(0xFFE53935)),
  SeedOption(label: 'Orange', color: Color(0xFFFB8C00)),
  SeedOption(label: 'Yellow', color: Color(0xFFFDD835)),
  SeedOption(label: 'Blue', color: Color(0xFF1E88E5)),
  SeedOption(label: 'Cyan', color: Color(0xFF00ACC1)),
  SeedOption(label: 'Indigo', color: Color(0xFF3949AB)),
  SeedOption(label: 'Purple', color: Color(0xFF8E24AA)),
  SeedOption(label: 'Pink', color: Color(0xFFD81B60)),
  SeedOption(label: 'Teal', color: Color(0xFF00897B)),
];

class SeedOption {
  const SeedOption({required this.label, required this.color});

  final String label;
  final Color color;
}

class SettingsController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  Color _seedColor = _defaultSeed;

  ThemeMode get themeMode => _themeMode;
  Color get seedColor => _seedColor;

  List<SeedOption> get seeds => availableSeeds;

  void setThemeMode(ThemeMode mode) {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
  }

  void setSeedColor(Color color) {
    if (color == _seedColor) return;
    _seedColor = color;
    notifyListeners();
  }
}