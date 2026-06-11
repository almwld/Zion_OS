import 'package:flutter/material.dart';

class AppModel extends ChangeNotifier {
  bool _isDarkMode = true;
  String _currentLanguage = 'ar';
  
  bool get isDarkMode => _isDarkMode;
  String get currentLanguage => _currentLanguage;
  
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
  
  void setLanguage(String lang) {
    _currentLanguage = lang;
    notifyListeners();
  }
}
