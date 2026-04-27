import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'alarm_executor.dart';
import 'settings_service.dart';

class AlarmScheduler {
  static const int _alarmId = 0;
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = await AndroidAlarmManager.initialize();
    print('[ChimeBell] AlarmScheduler initialized: $_initialized');
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
      AlarmExecutor.alarmCallback,
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
    final testTime = DateTime.now().add(const Duration(seconds: 30));
    await settings.log('[SCHEDULER] Requesting 30-sec test alarm. Target=$testTime');
    
    await AndroidAlarmManager.oneShot(
      const Duration(seconds: 30),
      testId,
      AlarmExecutor.alarmCallback,
      exact: true,
      wakeup: true,
      allowWhileIdle: settings.allowWhileIdle,
    );
  }
}
