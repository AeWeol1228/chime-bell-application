import 'dart:developer' as dev;
import 'package:audioplayers/audioplayers.dart';
import 'settings_service.dart';

@pragma('vm:entry-point')
class BackgroundService {
  @pragma('vm:entry-point')
  static Future<void> alarmCallback() async {
    dev.log('==== [NATIVE] Alarm callback started in Background Isolate ====', name: 'ChimeBell');
    print('[ChimeBell] Background Isolate Triggered');
    
    try {
      final settings = SettingsService();
      await settings.init();
      await settings.reload(); // Force reload to get latest values from disk
      
      if (!settings.chimeEnabled) {
        print('[ChimeBell] Chime is disabled. Skipping.');
        return;
      }

      final now = DateTime.now();
      print('[ChimeBell] Current Time: $now, Target Volume: ${settings.volume}');
      
      if (_shouldSkip(settings, now)) {
        print('[ChimeBell] Skipping chime based on settings.');
        return;
      }

      await _playChime(settings);
      print('[ChimeBell] Sound played successfully in background with volume: ${settings.volume}');
    } catch (e) {
      print('[ChimeBell] Error in background callback: $e');
    }
  }

  static bool _shouldSkip(SettingsService settings, DateTime now) {
    if (settings.excludeWeekends) {
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

    // Set Audio Context for "Ducking"
    await AudioPlayer.global.setAudioContext(const AudioContext(
      android: AudioContextAndroid(
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.alarm,
        audioFocus: AndroidAudioFocus.gainTransientMayDuck,
      ),
      iOS: AudioContextIOS(),
    ));

    await player.setVolume(settings.volume);
    await player.play(AssetSource('sounds/${settings.selectedSound}'));
  }
}
