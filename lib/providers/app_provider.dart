import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider extends ChangeNotifier {
  String _selectedLanguage = 'de';

  String get selectedLanguage => _selectedLanguage;

  AppProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedLanguage = prefs.getString('selected_language') ?? 'de';
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    _selectedLanguage = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', language);
    Get.updateLocale(
        language == 'de' ? const Locale('de', 'DE') : const Locale('en', 'US'));
    notifyListeners();
  }
}
