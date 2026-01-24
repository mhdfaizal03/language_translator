import 'package:flutter/material.dart';

class AppColors {
  static const Color scaffoldBackground =
      Color(0xFF0F1014); // Deep dark background
  static const Color cardBackground =
      Color(0xFF191B23); // Lighter dark for cards
  static const Color primary = Color(0xFF304FFE); // Bright Blue
  static const Color primaryVariant = Color(0xFF3D5AFE);
  static const Color white = Colors.white;
  static const Color textSecondary = Color(0xFF9CA3AF); // Grey text
  static const Color textInput = Color(0xFFE2E8F0);
  static const Color iconColor = Color(0xFF64748B);

  // Backward compatibility
  static const Color secondary = primary;
  static const Color surface = cardBackground;
  static const Color background = scaffoldBackground;
  static final Color glassWhite = cardBackground;
  static final Color glassBorder = Colors.transparent;
}

class LanguageData {
  final String name; // Display Name (e.g., 'English')
  final String code; // Translation Code (ISO 639-1, e.g., 'en')
  final String locale; // Speech/TTS Locale (BCP-47, e.g., 'en-US')

  const LanguageData(
      {required this.name, required this.code, required this.locale});
}

const List<LanguageData> kLanguageData = [
  LanguageData(name: 'Auto', code: 'auto', locale: 'auto'),
  LanguageData(name: 'Afrikaans', code: 'af', locale: 'af-ZA'),
  LanguageData(name: 'Arabic', code: 'ar', locale: 'ar-SA'),
  LanguageData(name: 'Bengali', code: 'bn', locale: 'bn-IN'),
  LanguageData(name: 'Chinese', code: 'zh', locale: 'zh-CN'),
  LanguageData(name: 'Czech', code: 'cs', locale: 'cs-CZ'),
  LanguageData(name: 'Danish', code: 'da', locale: 'da-DK'),
  LanguageData(name: 'Dutch', code: 'nl', locale: 'nl-NL'),
  LanguageData(name: 'English', code: 'en', locale: 'en-US'),
  LanguageData(name: 'Finnish', code: 'fi', locale: 'fi-FI'),
  LanguageData(name: 'French', code: 'fr', locale: 'fr-FR'),
  LanguageData(name: 'German', code: 'de', locale: 'de-DE'),
  LanguageData(name: 'Greek', code: 'el', locale: 'el-GR'),
  LanguageData(name: 'Gujarati', code: 'gu', locale: 'gu-IN'),
  LanguageData(name: 'Hindi', code: 'hi', locale: 'hi-IN'),
  LanguageData(name: 'Hungarian', code: 'hu', locale: 'hu-HU'),
  LanguageData(name: 'Indonesian', code: 'id', locale: 'id-ID'),
  LanguageData(name: 'Italian', code: 'it', locale: 'it-IT'),
  LanguageData(name: 'Japanese', code: 'ja', locale: 'ja-JP'),
  LanguageData(name: 'Kannada', code: 'kn', locale: 'kn-IN'),
  LanguageData(name: 'Korean', code: 'ko', locale: 'ko-KR'),
  LanguageData(name: 'Malayalam', code: 'ml', locale: 'ml-IN'),
  LanguageData(name: 'Marathi', code: 'mr', locale: 'mr-IN'),
  LanguageData(name: 'Polish', code: 'pl', locale: 'pl-PL'),
  LanguageData(name: 'Portuguese', code: 'pt', locale: 'pt-PT'),
  LanguageData(name: 'Punjabi', code: 'pa', locale: 'pa-IN'),
  LanguageData(name: 'Romanian', code: 'ro', locale: 'ro-RO'),
  LanguageData(name: 'Russian', code: 'ru', locale: 'ru-RU'),
  LanguageData(name: 'Spanish', code: 'es', locale: 'es-ES'),
  LanguageData(name: 'Swedish', code: 'sv', locale: 'sv-SE'),
  LanguageData(name: 'Tamil', code: 'ta', locale: 'ta-IN'),
  LanguageData(name: 'Telugu', code: 'te', locale: 'te-IN'),
  LanguageData(name: 'Thai', code: 'th', locale: 'th-TH'),
  LanguageData(name: 'Turkish', code: 'tr', locale: 'tr-TR'),
  LanguageData(name: 'Ukrainian', code: 'uk', locale: 'uk-UA'),
  LanguageData(name: 'Urdu', code: 'ur', locale: 'ur-PK'),
  LanguageData(name: 'Vietnamese', code: 'vi', locale: 'vi-VN'),
];

// Helper to get simple list of names for pickers
List<String> get kLanguages => kLanguageData.map((e) => e.name).toList();

// Helper to look up data by name
LanguageData getLanguageData(String name) {
  return kLanguageData.firstWhere((e) => e.name == name,
      orElse: () => kLanguageData[1]); // Default to English
}
