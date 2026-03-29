import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_config.dart';

class UpdateService {
  static final UpdateService _instance = UpdateService._internal();
  factory UpdateService() => _instance;
  UpdateService._internal();

  // Simulated update endpoint — in production, point to your server
  static const String _updateEndpoint = 'https://api.jsonbin.io/v3/b';
  static const String _localUpdateKey = 'pending_updates';

  Future<void> checkForUpdates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingJson = prefs.getString(_localUpdateKey);
      if (pendingJson != null) {
        await _applyUpdate(json.decode(pendingJson));
        await prefs.remove(_localUpdateKey);
      }
    } catch (e) {
      // Silently fail — updates are non-critical
    }
  }

  Future<void> applyRemoteUpdate(Map<String, dynamic> updateData) async {
    final prefs = await SharedPreferences.getInstance();

    // Validate the update has the correct admin key
    final adminKey = updateData['adminKey'] as String?;
    if (adminKey == null || !ApiConfig.validateAdminKey(adminKey)) {
      throw Exception('Invalid admin key');
    }

    await prefs.setString(_localUpdateKey, json.encode(updateData));
    await _applyUpdate(updateData);
  }

  Future<void> _applyUpdate(Map<String, dynamic> data) async {
    // Apply feature flags
    final features = data['features'] as Map<String, dynamic>?;
    if (features != null) {
      final flags = features.map((k, v) => MapEntry(k, v as bool));
      await ApiConfig.updateFeatureFlags(flags);
    }

    // Apply new API key
    final newApiKey = data['apiKey'] as String?;
    if (newApiKey != null && newApiKey.isNotEmpty) {
      await ApiConfig.updateApiKey(newApiKey);
    }

    // Apply app enabled state
    final appEnabled = data['appEnabled'] as bool?;
    if (appEnabled != null) {
      await ApiConfig.setAppEnabled(appEnabled);
    }
  }

  // Called by admin app via shared storage (for local admin scenario)
  Future<void> pushUpdateFromAdmin({
    required String adminKey,
    Map<String, bool>? featureFlags,
    String? newApiKey,
    bool? appEnabled,
  }) async {
    if (!ApiConfig.validateAdminKey(adminKey)) {
      throw Exception('Invalid developer code');
    }

    final updateData = <String, dynamic>{
      'adminKey': adminKey,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    if (featureFlags != null) updateData['features'] = featureFlags;
    if (newApiKey != null) updateData['apiKey'] = newApiKey;
    if (appEnabled != null) updateData['appEnabled'] = appEnabled;

    await applyRemoteUpdate(updateData);
  }
}
