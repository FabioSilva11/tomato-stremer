import 'package:flutter/material.dart';

class ThemeController extends ChangeNotifier {
  ThemeMode mode = ThemeMode.dark;

  bool get darkSelected => mode == ThemeMode.dark;

  void toggle() {
    mode = darkSelected ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}
