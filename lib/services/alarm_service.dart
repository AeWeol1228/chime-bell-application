import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'background_service.dart';
import 'settings_service.dart';

class AlarmService {
  static const int _alarmId = 0;
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = await AndroidAlarmManager.initialize();
    print('[ChimeBell] AlarmService initialized: $_initialized');
  }

  static Future<void> scheduleChime() async {
    final settings = SettingsService();
    await settings.init();
    
    final now = DateTime.now();
    // Calculate the next full hour
    final nextHour = DateTime(now.year, now.month, now.day, now.hour + 1);

    await settings.log('[SCHEDULER] Requesting ONE-SHOT alarm. Current=$now, Target=$nextHour');

    await AndroidAlarmManager.oneShotAt(
      nextHour,
      _alarmId,
      BackgroundService.alarmCallback,
      exact: true,
      wakeup: true,
      allowWhileIdle: settings.allowWhileIdle,
      rescheduleOnReboot: true,
    );
  }

  static Future<void> cancelChime() async {
    final settings = SettingsService();
    await settings.init();
    await settings.log('[SCHEDULER] Cancelling all alarms');
    await AndroidAlarmManager.cancel(_alarmId);
  }

  static Future<void> scheduleTestChime() async {
    final settings = SettingsService();
    await settings.init();
    
    const int testId = 1;
    final testTime = DateTime.now().add(const Duration(minutes: 1));
    await settings.log('[SCHEDULER] Requesting 1-min test alarm. Target=$testTime');
    
    await AndroidAlarmManager.oneShot(
      const Duration(minutes: 1),
      testId,
      BackgroundService.alarmCallback,
      exact: true,
      wakeup: true,
      allowWhileIdle: settings.allowWhileIdle,
    );
  }
}
