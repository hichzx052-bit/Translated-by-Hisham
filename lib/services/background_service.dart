import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const notificationChannelId = 'hisham_translator_channel';
const notificationId = 888;

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    notificationChannelId,
    'Translated by Hisham',
    description: 'خدمة الترجمة تعمل في الخلفية',
    importance: Importance.low,
  );
  
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: notificationChannelId,
      initialNotificationTitle: 'Translated by Hisham',
      initialNotificationContent: 'الترجمة جاهزة 🪶',
      foregroundServiceNotificationId: notificationId,
      foregroundServiceTypes: [AndroidForegroundType.microphone],
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
    ),
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }
  
  service.on('stopService').listen((event) {
    service.stopSelf();
  });
  
  service.on('updateNotification').listen((event) {
    if (service is AndroidServiceInstance) {
      final title = event?['title'] ?? 'Translated by Hisham';
      final content = event?['content'] ?? 'الترجمة جاهزة 🪶';
      
      service.setForegroundNotificationInfo(
        title: title,
        content: content,
      );
    }
  });
  
  // Periodic status update
  Timer.periodic(const Duration(seconds: 30), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        service.setForegroundNotificationInfo(
          title: 'Translated by Hisham 🪶',
          content: 'الترجمة تعمل في الخلفية...',
        );
      }
    }
    
    service.invoke('update', {
      'status': 'running',
      'timestamp': DateTime.now().toIso8601String(),
    });
  });
}

class BackgroundServiceManager {
  static final FlutterBackgroundService _service = FlutterBackgroundService();
  
  static Future<bool> isRunning() async {
    return await _service.isRunning();
  }
  
  static Future<void> startService() async {
    await _service.startService();
  }
  
  static Future<void> stopService() async {
    _service.invoke('stopService');
  }
  
  static void updateNotification(String title, String content) {
    _service.invoke('updateNotification', {
      'title': title,
      'content': content,
    });
  }
  
  static void setAsForeground() {
    _service.invoke('setAsForeground');
  }
  
  static void setAsBackground() {
    _service.invoke('setAsBackground');
  }
}
