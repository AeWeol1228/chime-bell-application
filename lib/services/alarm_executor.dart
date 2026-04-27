import 'dart:developer' as dev;
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'settings_service.dart';
import 'alarm_scheduler.dart';

@pragma('vm:entry-point')
class AlarmExecutor {
  @pragma('vm:entry-point')
  static Future<void> alarmCallback() async {
    try {
      // 1. Reschedule for next hour immediately to maintain the chain.
      // We do this first so that even if SettingsService fails, the alarm chain continues.
      try {
        await AlarmScheduler.scheduleChime();
      } catch (e) {
        print('[ChimeBell] Critical Error during rescheduling: $e');
      }

      final settings = SettingsService();
      await settings.init();
      await settings.reload();
      
      final now = DateTime.now();
      await settings.log('>>> [EXECUTOR] Isolate Triggered at $now');
      await settings.log('    - Next chime rescheduled.');

      if (!settings.chimeEnabled) {
        await settings.log('    - SKIP: Chime disabled');
        return;
      }

      if (_shouldSkip(settings, now)) {
        await settings.log('    - SKIP: Weekend/DND condition met');
        return;
      }

      await settings.log('    - Preparing player context...');
      await _playChime(settings);
      await settings.log('>>> [EXECUTOR] Audio play completed and focus released.');
    } catch (e) {
      print('[ChimeBell] Error in background callback: $e');
    }
  }

  static bool _shouldSkip(SettingsService settings, DateTime now) {
    if (settings.excludeWeekends && !settings.weekendOverride) {
      if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
        return true;
      }
    }

    if (settings.dndEnabled) {
      final start = settings.dndStartHour;
      final end = settings.dndEndHour;
      final current = now.hour;
      bool isDnd = (start <= end) 
          ? (current >= start && current < end) 
          : (current >= start || current < end);
      if (isDnd) return true;
    }

    return false;
  }
static Future<void> _playChime(SettingsService settings) async {
  final player = AudioPlayer();
  final now = DateTime.now();
  
  // Use testHourOverride if set, otherwise use actual hour
  final testHour = settings.testHourOverride;
  final effectiveHour = (testHour != -1) ? testHour : now.hour;
  
  if (testHour != -1) {
    await settings.log('    - TEST MODE: Using virtual hour $testHour');
    // Clear the override so it doesn't affect the next real alarm
    await settings.setTestHourOverride(-1);
  }

  final chimePath = 'sounds/${settings.selectedSound}';
  String? voicePath = await settings.getVoiceFilePath(effectiveHour);

  // usageType: alarm provides high priority for Doze mode.
  // audioFocus: gainTransientMayDuck tells Android to lower other audio (duck) instead of pausing.
  final audioContext = AudioContext(
    android: AudioContextAndroid(
      contentType: AndroidContentType.sonification,
      usageType: AndroidUsageType.alarm,
      audioFocus: AndroidAudioFocus.gainTransientMayDuck,
    ),
    iOS: AudioContextIOS(
      category: AVAudioSessionCategory.ambient,
    ),
  );

  try {
    await player.setAudioContext(audioContext);
    await player.setVolume(settings.volume);

    // 1. Play Default Chime
    await settings.log('    - Playing Chime: $chimePath');
    await player.setSource(AssetSource(chimePath));
    await player.resume();
    // Wait for chime to finish (max 10s)
    await player.onPlayerComplete.first.timeout(const Duration(seconds: 10));

    // 2. Play Voice if available
    if (voicePath != null) {
      final fullVoicePath = 'sounds/$voicePath';
      await settings.log('    - Playing Voice: $fullVoicePath');
      // A small delay between chime and voice for better transition
      await Future.delayed(const Duration(milliseconds: 500));
      
      await player.setSource(AssetSource(fullVoicePath));
      await player.resume();
      // Wait for voice to finish (max 15s)
      await player.onPlayerComplete.first.timeout(const Duration(seconds: 15));
    }

  } catch (e) {
    await settings.log('    - Playback Error: $e');
  } finally {
    await player.dispose();
  }
}
}
