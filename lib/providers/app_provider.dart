import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  
  // Getter for dark mode state
  bool get isDarkMode => _isDarkMode;
  
  AppProvider() {
    _loadThemePreference();
  }
  
  // Load theme preference from SharedPreferences
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading theme preference: $e');
      }
    }
  }
  
  // Toggle between light and dark mode
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _saveThemePreference();
    notifyListeners();
  }
  
  // Set specific theme mode
  Future<void> setTheme(bool isDarkMode) async {
    _isDarkMode = isDarkMode;
    await _saveThemePreference();
    notifyListeners();
  }
  
  // Save theme preference to SharedPreferences
  Future<void> _saveThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', _isDarkMode);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving theme preference: $e');
      }
    }
  }
}