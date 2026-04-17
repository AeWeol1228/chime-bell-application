import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import '../main.dart'; // Import to use alarmCallback from main.dart

class AlarmService {
  static const int _alarmId = 0;
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = await AndroidAlarmManager.initialize();
    print('[ChimeBell] AndroidAlarmManager initialized: $_initialized');
  }

  static Future<void> scheduleChime() async {
    final now = DateTime.now();
    final nextHour = DateTime(now.year, now.month, now.day, now.hour + 1);

    await AndroidAlarmManager.periodic(
      const Duration(hours: 1),
      _alarmId,
      alarmCallback, // References the top-level function in main.dart
      startAt: nextHour,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );
  }

  static Future<void> cancelChime() async {
    await AndroidAlarmManager.cancel(_alarmId);
  }

  static Future<void> scheduleTestChime() async {
    const int testId = 1;
    final testTime = DateTime.now().add(const Duration(minutes: 1));
    print('[ChimeBell] Scheduling test alarm for: $testTime');
    
    await AndroidAlarmManager.oneShot(
      const Duration(minutes: 1),
      testId,
      alarmCallback, // References the top-level function in main.dart
      exact: true,
      wakeup: true,
    );
  }
}
