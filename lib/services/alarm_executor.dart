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
  final soundPath = 'sounds/${settings.selectedSound}';

  await settings.log('    - Playing: $soundPath, Vol: ${settings.volume}');

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
    await player.setSource(AssetSource(soundPath));
    await player.resume();

    await player.onPlayerComplete.first.timeout(const Duration(seconds: 10));
  } catch (e) {
    await settings.log('    - Playback Error: $e');
  } finally {
    await player.dispose();
  }
}
}
