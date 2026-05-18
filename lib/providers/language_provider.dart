import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  String _lang = 'TR';

  String get lang => _lang;

  LanguageProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _lang = prefs.getString('app_lang') ?? 'TR';
    notifyListeners();
  }

  Future<void> setLang(String lang) async {
    if (_lang == lang) return;
    _lang = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_lang', lang);
    notifyListeners();
  }
}
