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

const List<String> kLanguages = [
  'Auto',
  'English',
  'Hindi',
  'Marathi',
  'Spanish',
  'French',
  'German',
  'Chinese',
  'Japanese',
  'Korean',
  'Italian',
  'Malayalam',
  'Arabic',
  'Russian',
  'Portuguese',
  'Bengali',
  'Dutch',
  'Swedish',
  'Thai',
  'Turkish',
  'Vietnamese',
  'Greek',
  'Polish',
  'Romanian',
  'Hungarian',
];

const Map<String, String> kLanguageCodes = {
  'Auto': 'auto',
  'English': 'en',
  'Hindi': 'hi',
  'Marathi': 'mr',
  'Spanish': 'es',
  'French': 'fr',
  'German': 'de',
  'Chinese': 'zh',
  'Japanese': 'ja',
  'Korean': 'ko',
  'Italian': 'it',
  'Malayalam': 'ml',
  'Arabic': 'ar',
  'Russian': 'ru',
  'Portuguese': 'pt',
  'Bengali': 'bn',
  'Dutch': 'nl',
  'Swedish': 'sv',
  'Thai': 'th',
  'Turkish': 'tr',
  'Vietnamese': 'vi',
  'Greek': 'el',
  'Polish': 'pl',
  'Romanian': 'ro',
  'Hungarian': 'hu',
};
