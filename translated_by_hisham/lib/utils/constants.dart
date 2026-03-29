import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'Translated by Hisham';
  static const String appNameAr = 'ترجمة هشام';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // API Endpoints
  static const String myMemoryApiBase = 'https://api.mymemory.translated.net';
  static const String libreTranslateBase = 'https://libretranslate.com';
  static const String lingvaApiBase = 'https://lingva.ml/api/v1';

  // SharedPreferences Keys
  static const String keyOnboardingDone = 'onboarding_done';
  static const String keySourceLang = 'source_lang';
  static const String keyTargetLang = 'target_lang';
  static const String keySelectedVoice = 'selected_voice';
  static const String keyDarkMode = 'dark_mode';
  static const String keyApiKey = 'api_key';
  static const String keyAppEnabled = 'app_enabled';
  static const String keyFeatureFlags = 'feature_flags';
  static const String keyVoiceGender = 'voice_gender';
  static const String keyAutoDetect = 'auto_detect';
  static const String keyBubbleEnabled = 'bubble_enabled';
  static const String keyTranslationHistory = 'translation_history';

  // Colors
  static const Color primaryIndigo = Color(0xFF4F46E5);
  static const Color primaryPurple = Color(0xFF7C3AED);
  static const Color primaryViolet = Color(0xFF8B5CF6);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color accentPink = Color(0xFFEC4899);
  static const Color darkBg = Color(0xFF0A0A1A);
  static const Color darkSurface = Color(0xFF111128);
  static const Color darkCard = Color(0xFF1A1A35);
  static const Color glassWhite = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryIndigo, primaryPurple, primaryViolet],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0D0D2B), Color(0xFF0A0A1A), Color(0xFF0F0F25)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x331A1A3A), Color(0x1A0A0A2A)],
  );

  // Animation Durations
  static const Duration splashDuration = Duration(milliseconds: 3000);
  static const Duration pageTransition = Duration(milliseconds: 400);
  static const Duration cardAnimation = Duration(milliseconds: 600);
  static const Duration pulseAnimation = Duration(milliseconds: 1500);

  // Supported Languages
  static const Map<String, String> supportedLanguages = {
    'auto': 'Auto Detect',
    'ar': 'العربية',
    'en': 'English',
    'fr': 'Français',
    'es': 'Español',
    'de': 'Deutsch',
    'it': 'Italiano',
    'pt': 'Português',
    'ru': 'Русский',
    'ja': '日本語',
    'ko': '한국어',
    'zh': '中文',
    'tr': 'Türkçe',
    'nl': 'Nederlands',
    'pl': 'Polski',
    'sv': 'Svenska',
    'da': 'Dansk',
    'fi': 'Suomi',
    'no': 'Norsk',
    'cs': 'Čeština',
    'hu': 'Magyar',
    'ro': 'Română',
    'el': 'Ελληνικά',
    'he': 'עברית',
    'fa': 'فارسی',
    'ur': 'اردو',
    'hi': 'हिन्दी',
    'bn': 'বাংলা',
    'th': 'ไทย',
    'vi': 'Tiếng Việt',
    'id': 'Bahasa Indonesia',
    'ms': 'Bahasa Melayu',
    'sw': 'Kiswahili',
    'uk': 'Українська',
    'ca': 'Català',
  };

  static const Map<String, String> languageFlags = {
    'ar': '🇸🇦',
    'en': '🇺🇸',
    'fr': '🇫🇷',
    'es': '🇪🇸',
    'de': '🇩🇪',
    'it': '🇮🇹',
    'pt': '🇵🇹',
    'ru': '🇷🇺',
    'ja': '🇯🇵',
    'ko': '🇰🇷',
    'zh': '🇨🇳',
    'tr': '🇹🇷',
    'nl': '🇳🇱',
    'pl': '🇵🇱',
    'sv': '🇸🇪',
    'da': '🇩🇰',
    'fi': '🇫🇮',
    'no': '🇳🇴',
    'cs': '🇨🇿',
    'hu': '🇭🇺',
    'ro': '🇷🇴',
    'el': '🇬🇷',
    'he': '🇮🇱',
    'fa': '🇮🇷',
    'ur': '🇵🇰',
    'hi': '🇮🇳',
    'bn': '🇧🇩',
    'th': '🇹🇭',
    'vi': '🇻🇳',
    'id': '🇮🇩',
    'ms': '🇲🇾',
    'sw': '🇰🇪',
    'uk': '🇺🇦',
    'auto': '🌍',
  };

  // RTL Languages
  static const List<String> rtlLanguages = ['ar', 'he', 'fa', 'ur'];

  static bool isRtl(String langCode) => rtlLanguages.contains(langCode);
}
