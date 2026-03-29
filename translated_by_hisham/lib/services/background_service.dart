import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'translation_service.dart';
import 'speech_service.dart';
import 'tts_service.dart';

class BackgroundServiceManager {
  static final BackgroundServiceManager _instance = BackgroundServiceManager._internal();
  factory BackgroundServiceManager() => _instance;
  BackgroundServiceManager._internal();

  static const String _channelId = 'translated_by_hisham_service';

  Future<void> initialize() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: _onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: _channelId,
        initialNotificationTitle: 'Translated by Hisham',
        initialNotificationContent: 'Translation service is running...',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: _onStart,
        onBackground: _onIosBackground,
      ),
    );
  }

  Future<void> startService() async {
    final service = FlutterBackgroundService();
    await service.startService();
  }

  Future<void> stopService() async {
    final service = FlutterBackgroundService();
    service.invoke('stop');
  }

  Future<bool> isRunning() async {
    final service = FlutterBackgroundService();
    return await service.isRunning();
  }

  void sendToService(String method, Map<String, dynamic>? args) {
    final service = FlutterBackgroundService();
    service.invoke(method, args);
  }

  @pragma('vm:entry-point')
  static Future<bool> _onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    return true;
  }

  @pragma('vm:entry-point')
  static void _onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();

    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }

    service.on('stop').listen((event) {
      service.stopSelf();
    });

    service.on('translate').listen((event) async {
      if (event == null) return;
      final text = event['text'] as String? ?? '';
      final targetLang = event['targetLang'] as String? ?? 'ar';
      final sourceLang = event['sourceLang'] as String? ?? 'auto';

      if (text.isNotEmpty) {
        final translationService = TranslationService();
        final result = await translationService.translate(
          text: text,
          targetLang: targetLang,
          sourceLang: sourceLang,
        );

        service.invoke('translationResult', {
          'original': text,
          'translated': result.translatedText,
          'success': result.success,
        });
      }
    });

    // Keep service alive with periodic updates
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (service is AndroidServiceInstance) {
        if (await service.isForegroundService()) {
          service.setForegroundNotificationInfo(
            title: 'Translated by Hisham',
            content: 'Listening for translations...',
          );
        }
      }
      service.invoke('update', {'timestamp': DateTime.now().millisecondsSinceEpoch});
    });
  }
}
