import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyVoiceHistory = 'voice_history';
  static const String _keyTransHistory = 'trans_history';
  static const String _keyLangSource = 'lang_source';
  static const String _keyLangTarget = 'lang_target';

  // Singleton
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- LANGUAGE PREFERENCES ---
  Future<void> saveLanguages(String source, String target) async {
    await _prefs?.setString(_keyLangSource, source);
    await _prefs?.setString(_keyLangTarget, target);
  }

  Map<String, String> getLanguages() {
    return {
      'source': _prefs?.getString(_keyLangSource) ?? 'English',
      'target': _prefs?.getString(_keyLangTarget) ?? 'Tamil',
    };
  }

  // --- VOICE HISTORY ---
  Future<void> saveVoiceHistory(List<Map<String, dynamic>> items) async {
    // Convert list of maps to JSON string
    final String jsonString = jsonEncode(items);
    await _prefs?.setString(_keyVoiceHistory, jsonString);
  }

  List<Map<String, dynamic>> getVoiceHistory() {
    final String? jsonString = _prefs?.getString(_keyVoiceHistory);
    if (jsonString == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> clearVoiceHistory() async {
    await _prefs?.remove(_keyVoiceHistory);
  }

  // --- TRANSLATION HISTORY ---
  // Simple list of strings for now, or maps if we want more detail
  Future<void> saveTranslation(String source, String target, String sourceText,
      String targetText) async {
    List<String> history = _prefs?.getStringList(_keyTransHistory) ?? [];

    final newItem = jsonEncode({
      'source_lang': source,
      'target_lang': target,
      'source_text': sourceText,
      'target_text': targetText,
      'timestamp': DateTime.now().toIso8601String(),
    });

    history.insert(0, newItem); // Add to top
    if (history.length > 50) history = history.sublist(0, 50); // Limit to 50

    await _prefs?.setStringList(_keyTransHistory, history);
  }

  List<Map<String, dynamic>> getTranslationHistory() {
    List<String> history = _prefs?.getStringList(_keyTransHistory) ?? [];
    return history.map((e) {
      try {
        return Map<String, dynamic>.from(jsonDecode(e));
      } catch (e) {
        return <String, dynamic>{};
      }
    }).toList();
  }
}
