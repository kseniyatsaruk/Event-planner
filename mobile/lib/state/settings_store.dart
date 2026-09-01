import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const supportedLanguageCodes = ['en', 'ru'];

/// Persists the local-network address (host:port) of the Go backend, since a
/// home router's assigned IP for the dev machine isn't stable enough to
/// hardcode into the app. Also persists the user's explicit UI language
/// choice, mirroring the web app's `eventplanner_lang` localStorage key.
///
/// [languageCode] is null until the user explicitly picks a language — while
/// null, MaterialApp's own locale resolution is left to fall back to the
/// device's language (matching the web app's "detect from navigator.language
/// on first load" behavior), so there is nothing to detect here.
class SettingsStore extends ChangeNotifier {
  static const _baseUrlKey = 'eventplanner_server_base_url';
  static const _langKey = 'eventplanner_lang';

  String baseUrl = '';
  String? languageCode;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    baseUrl = prefs.getString(_baseUrlKey) ?? '';
    final storedLang = prefs.getString(_langKey);
    languageCode =
        supportedLanguageCodes.contains(storedLang) ? storedLang : null;
    notifyListeners();
  }

  Future<void> setBaseUrl(String value) async {
    baseUrl = value.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_baseUrlKey, baseUrl);
    notifyListeners();
  }

  Future<void> setLanguage(String? code) async {
    languageCode = code;
    final prefs = await SharedPreferences.getInstance();
    if (code == null) {
      await prefs.remove(_langKey);
    } else {
      await prefs.setString(_langKey, code);
    }
    notifyListeners();
  }
}
