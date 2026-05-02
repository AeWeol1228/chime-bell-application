import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  // Singleton pattern
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  static const String _keyChimeEnabled = 'chime_enabled';
  static const String _keyVoiceOptionEnabled = 'voice_option_enabled';
  static const String _keyDailyRandomVoiceHour = 'daily_random_voice_hour';
  static const String _keyLastRandomDate = 'last_random_date';
  static const String _keyTestHourOverride = 'test_hour_override';
  static const String _keyDndEnabled = 'dnd_enabled';
  static const String _keyDndStartHour = 'dnd_start_hour';
  static const String _keyDndEndHour = 'dnd_end_hour';
  static const String _keyExcludeWeekends = 'exclude_weekends';
  static const String _keyWeekendOverride = 'weekend_override';
  static const String _keyAllowWhileIdle = 'allow_while_idle';
  static const String _keySelectedSound = 'selected_sound';
  static const String _keyVolume = 'volume';
  static const String _keyDebugLoggingEnabled = 'debug_logging_enabled';
  static const String _keyLanguage = 'language';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> reload() async {
    await _prefs.reload();
  }

  // Helper for generic preference setting
  Future<bool> _setBool(String key, bool value) => _prefs.setBool(key, value);
  Future<bool> _setInt(String key, int value) => _prefs.setInt(key, value);
  Future<bool> _setDouble(String key, double value) => _prefs.setDouble(key, value);
  Future<bool> _setString(String key, String value) => _prefs.setString(key, value);

  bool get chimeEnabled => _prefs.getBool(_keyChimeEnabled) ?? true;
  Future<void> setChimeEnabled(bool value) => _setBool(_keyChimeEnabled, value);

  bool get voiceOptionEnabled => _prefs.getBool(_keyVoiceOptionEnabled) ?? false;
  Future<void> setVoiceOptionEnabled(bool value) => _setBool(_keyVoiceOptionEnabled, value);

  int get dailyRandomVoiceHour => _prefs.getInt(_keyDailyRandomVoiceHour) ?? -1;
  Future<void> setDailyRandomVoiceHour(int value) => _setInt(_keyDailyRandomVoiceHour, value);

  String get lastRandomDate => _prefs.getString(_keyLastRandomDate) ?? '';
  Future<void> setLastRandomDate(String value) => _setString(_keyLastRandomDate, value);

  bool get dndEnabled => _prefs.getBool(_keyDndEnabled) ?? false;
  Future<void> setDndEnabled(bool value) => _setBool(_keyDndEnabled, value);

  int get dndStartHour => _prefs.getInt(_keyDndStartHour) ?? 22;
  Future<void> setDndStartHour(int value) => _setInt(_keyDndStartHour, value);

  int get dndEndHour => _prefs.getInt(_keyDndEndHour) ?? 7;
  Future<void> setDndEndHour(int value) => _setInt(_keyDndEndHour, value);

  bool get excludeWeekends => _prefs.getBool(_keyExcludeWeekends) ?? false;
  Future<void> setExcludeWeekends(bool value) => _setBool(_keyExcludeWeekends, value);

  bool get weekendOverride => _prefs.getBool(_keyWeekendOverride) ?? false;
  Future<void> setWeekendOverride(bool value) => _setBool(_keyWeekendOverride, value);

  bool get allowWhileIdle => _prefs.getBool(_keyAllowWhileIdle) ?? false;
  Future<void> setAllowWhileIdle(bool value) => _setBool(_keyAllowWhileIdle, value);

  String get selectedSound => _prefs.getString(_keySelectedSound) ?? 'default_chime.m4a';
  Future<void> setSelectedSound(String value) => _setString(_keySelectedSound, value);

  double get volume => _prefs.getDouble(_keyVolume) ?? 1.0;
  Future<void> setVolume(double value) => _setDouble(_keyVolume, value);

  String get language => _prefs.getString(_keyLanguage) ?? 'ko';
  Future<void> setLanguage(String value) => _setString(_keyLanguage, value);

  bool get debugLoggingEnabled => _prefs.getBool(_keyDebugLoggingEnabled) ?? false;
  Future<void> setDebugLoggingEnabled(bool value) => _setBool(_keyDebugLoggingEnabled, value);

  int get testHourOverride => _prefs.getInt(_keyTestHourOverride) ?? -1;
  Future<void> setTestHourOverride(int value) => _setInt(_keyTestHourOverride, value);

  // Status Helpers
  bool isWeekend() {
    final now = DateTime.now();
    return now.weekday == DateTime.saturday || now.weekday == DateTime.sunday;
  }

  bool isDndTime() {
    if (!dndEnabled) return false;
    final now = DateTime.now();
    return _isHourInDnd(now.hour);
  }

  bool _isHourInDnd(int hour) {
    if (!dndEnabled) return false;
    return (dndStartHour <= dndEndHour) 
        ? (hour >= dndStartHour && hour < dndEndHour) 
        : (hour >= dndStartHour || hour < dndEndHour);
  }

  bool isEffectiveDisabled() {
    if (!chimeEnabled) return true;
    if (excludeWeekends && isWeekend() && !weekendOverride) return true;
    if (isDndTime()) return true;
    return false;
  }

  /// Returns the random voice hour for today.
  /// It picks one from [1, 2, 7, 15, 16, 18], excluding hours in DND range.
  Future<int> getOrUpdateDailyRandomVoiceHour() async {
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month}-${now.day}';
    
    if (lastRandomDate == todayStr && dailyRandomVoiceHour != -1) {
      return dailyRandomVoiceHour;
    }

    // Pick new random hour
    final randomPool = [1, 2, 7, 15, 16, 18];
    
    // Filter out hours that are currently in DND
    final availableHours = randomPool.where((h) => !_isHourInDnd(h)).toList();
    
    // Fallback to full pool if all candidates are filtered out (safety)
    final poolToUse = availableHours.isNotEmpty ? availableHours : randomPool;
    
    poolToUse.shuffle();
    final chosenHour = poolToUse.first;

    await setLastRandomDate(todayStr);
    await setDailyRandomVoiceHour(chosenHour);
    
    return chosenHour;
  }

  /// Returns a specific voice file path for the current hour if applicable.
  /// Returns null if it's not a voice hour.
  Future<String?> getVoiceFilePath(int hour) async {
    if (!voiceOptionEnabled) return null;

    final fixedHours = [9, 10, 20, 21];
    final randomHour = await getOrUpdateDailyRandomVoiceHour();
    
    bool isVoiceHour = fixedHours.contains(hour) || hour == randomHour;
    if (!isVoiceHour) return null;

    final Map<int, List<String>> voiceFiles = {
      1: ['01.mp3'],
      2: ['02.mp3'],
      7: ['07.mp3'],
      9: ['09.mp3'],
      10: ['10_1.mp3', '10_2.mp3'],
      15: ['15_1.mp3', '15_2.mp3'],
      16: ['16.mp3'],
      18: ['18.mp3'],
      20: ['20.mp3'],
      21: ['21_1.mp3', '21_2.mp3', '21_3.mp3'],
    };

    final options = voiceFiles[hour];
    if (options == null || options.isEmpty) return null;

    if (options.length == 1) {
      return 'voices/${options[0]}';
    } else {
      options.shuffle();
      return 'voices/${options[0]}';
    }
  }

  Future<void> log(String message) async {
    if (!debugLoggingEnabled) return;
    try {
      final directory = Directory.systemTemp;
      final file = File('${directory.path}/execution_log.txt');
      final now = DateTime.now();
      final ts = '${now.month}/${now.day} ${now.hour}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}.${now.millisecond}';
      await file.writeAsString('[$ts] $message\n', mode: FileMode.append, flush: true);
      print('[ChimeBell Log] $message');
    } catch (e) {
      print('[ChimeBell] Log Error: $e');
    }
  }
}
