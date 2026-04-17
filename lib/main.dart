import 'package:flutter/material.dart';
import 'services/settings_service.dart';
import 'services/alarm_service.dart';
import 'ui/settings_screen.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:developer' as dev;

// Move alarmCallback to the very top of main.dart for maximum visibility to Native
@pragma('vm:entry-point')
Future<void> alarmCallback() async {
  dev.log('==== [NATIVE] Alarm callback started in Background Isolate ====', name: 'ChimeBell');
  print('[ChimeBell] Background Isolate Triggered');
  
  try {
    final settings = SettingsService();
    await settings.init();

    if (!settings.chimeEnabled) return;

    final now = DateTime.now();
    if (settings.excludeWeekends) {
      if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) return;
    }

    if (settings.dndEnabled) {
      final start = settings.dndStartHour;
      final end = settings.dndEndHour;
      final current = now.hour;
      bool isDnd = (start <= end) ? (current >= start && current < end) : (current >= start || current < end);
      if (isDnd) return;
    }

    final player = AudioPlayer();
    await player.play(AssetSource('sounds/${settings.selectedSound}'));
    print('[ChimeBell] Sound played successfully in background');
  } catch (e) {
    print('[ChimeBell] Error in background callback: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Services
  final settingsService = SettingsService();
  await settingsService.init();
  
  // Important: Initialize Alarm Manager
  await AlarmService.init();

  if (settingsService.chimeEnabled) {
    AlarmService.scheduleChime();
  }

  runApp(MyApp(settings: settingsService));
}

class MyApp extends StatelessWidget {
  final SettingsService settings;

  const MyApp({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chime Bell',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: SettingsScreen(settings: settings),
    );
  }
}
