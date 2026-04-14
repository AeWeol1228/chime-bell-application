import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'settings_service.dart';

class AlarmService {
  static const int _alarmId = 0;

  static Future<void> init() async {
    await AndroidAlarmManager.initialize();
  }

  static Future<void> scheduleChime() async {
    final now = DateTime.now();
    // Calculate the next full hour
    final nextHour = DateTime(now.year, now.month, now.day, now.hour + 1);

    await AndroidAlarmManager.periodic(
      const Duration(hours: 1),
      _alarmId,
      callback,
      startAt: nextHour,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );
  }

  static Future<void> cancelChime() async {
    await AndroidAlarmManager.cancel(_alarmId);
  }

  // This must be a top-level function or a static method
  @pragma('vm:entry-point')
  static Future<void> callback() async {
    final settings = SettingsService();
    await settings.init();

    if (!settings.chimeEnabled) return;

    final now = DateTime.now();

    // Weekend exclusion
    if (settings.excludeWeekends) {
      if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
        return;
      }
    }

    // Do Not Disturb (DND) logic
    if (settings.dndEnabled) {
      final start = settings.dndStartHour;
      final end = settings.dndEndHour;
      final current = now.hour;

      bool isDnd = false;
      if (start <= end) {
        // DND within the same day (e.g., 09:00 - 18:00)
        if (current >= start && current < end) isDnd = true;
      } else {
        // DND spanning midnight (e.g., 22:00 - 07:00)
        if (current >= start || current < end) isDnd = true;
      }

      if (isDnd) return;
    }

    // Play Chime Sound
    final player = AudioPlayer();
    try {
      await player.play(AssetSource('sounds/${settings.selectedSound}'));
    } catch (e) {
      // Fallback or log error
      print('Error playing chime: $e');
    }
  }
}
