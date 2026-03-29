import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

class ApiConfig {
  static const String _defaultApiKey = 'TBH-DEFAULT-2025-HICHAM';
  static const String _adminApiKeyPrefix = 'TBH-ADMIN-';

  static String _currentApiKey = _defaultApiKey;
  static bool _appEnabled = true;
  static Map<String, bool> _featureFlags = {
    'voice_translation': true,
    'live_mode': true,
    'video_translation': true,
    'floating_bubble': true,
    'bidirectional': true,
    'auto_detect': true,
  };

  static String get currentApiKey => _currentApiKey;
  static bool get appEnabled => _appEnabled;
  static Map<String, bool> get featureFlags => Map.unmodifiable(_featureFlags);

  static bool isFeatureEnabled(String feature) {
    return _featureFlags[feature] ?? false;
  }

  static Future<void> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    _currentApiKey = prefs.getString(AppConstants.keyApiKey) ?? _defaultApiKey;
    _appEnabled = prefs.getBool(AppConstants.keyAppEnabled) ?? true;

    final flagsJson = prefs.getStringList(AppConstants.keyFeatureFlags);
    if (flagsJson != null) {
      for (final flag in flagsJson) {
        final parts = flag.split(':');
        if (parts.length == 2) {
          _featureFlags[parts[0]] = parts[1] == 'true';
        }
      }
    }
  }

  static Future<void> updateApiKey(String newKey) async {
    if (newKey.startsWith(_adminApiKeyPrefix) || newKey == _defaultApiKey) {
      _currentApiKey = newKey;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyApiKey, newKey);
    }
  }

  static Future<void> setAppEnabled(bool enabled) async {
    _appEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyAppEnabled, enabled);
  }

  static Future<void> updateFeatureFlags(Map<String, bool> flags) async {
    _featureFlags.addAll(flags);
    final prefs = await SharedPreferences.getInstance();
    final flagsList = flags.entries.map((e) => '${e.key}:${e.value}').toList();
    await prefs.setStringList(AppConstants.keyFeatureFlags, flagsList);
  }

  static bool validateAdminKey(String key) {
    return key == 'Hichamdzz' || key.startsWith(_adminApiKeyPrefix);
  }
}
