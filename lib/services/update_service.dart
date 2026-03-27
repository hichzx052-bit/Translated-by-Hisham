import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateService {
  static const String _repoOwner = 'hichzx052-bit';
  static const String _repoName = 'Translated-by-Hisham';
  static const String _currentVersion = '1.0.0';
  
  String? _latestVersion;
  String? _downloadUrl;
  String? _releaseNotes;
  
  String? get latestVersion => _latestVersion;
  String? get downloadUrl => _downloadUrl;
  String? get releaseNotes => _releaseNotes;
  
  Future<bool> checkForUpdates() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.github.com/repos/$_repoOwner/$_repoName/releases/latest'),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _latestVersion = data['tag_name']?.toString().replaceAll('v', '') ?? '';
        _releaseNotes = data['body'] ?? '';
        
        final assets = data['assets'] as List? ?? [];
        for (var asset in assets) {
          if (asset['name'].toString().endsWith('.apk')) {
            _downloadUrl = asset['browser_download_url'];
            break;
          }
        }
        
        return _isNewerVersion(_latestVersion!, _currentVersion);
      }
      return false;
    } catch (e) {
      print('Update check failed: $e');
      return false;
    }
  }
  
  bool _isNewerVersion(String latest, String current) {
    final latestParts = latest.split('.').map(int.parse).toList();
    final currentParts = current.split('.').map(int.parse).toList();
    
    for (int i = 0; i < 3; i++) {
      final l = i < latestParts.length ? latestParts[i] : 0;
      final c = i < currentParts.length ? currentParts[i] : 0;
      if (l > c) return true;
      if (l < c) return false;
    }
    return false;
  }
  
  Future<void> downloadAndInstallUpdate() async {
    if (_downloadUrl == null) return;
    
    try {
      final response = await http.get(Uri.parse(_downloadUrl!));
      
      if (response.statusCode == 200) {
        final dir = await getExternalStorageDirectory();
        final file = File('${dir!.path}/update.apk');
        await file.writeAsBytes(response.bodyBytes);
        
        // Save update path for installation
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('pending_update_path', file.path);
      }
    } catch (e) {
      print('Download failed: $e');
    }
  }
  
  // Check for updates from companion updater app
  Future<bool> checkCompanionUpdates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingUpdate = prefs.getString('companion_update_version');
      
      if (pendingUpdate != null && _isNewerVersion(pendingUpdate, _currentVersion)) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  // Accept update from companion app via shared preferences/intent
  Future<void> acceptCompanionUpdate(String apkPath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pending_update_path', apkPath);
  }
}
