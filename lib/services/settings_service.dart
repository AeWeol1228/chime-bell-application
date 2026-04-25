import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  // Singleton pattern
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  static const String _keyChimeEnabled = 'chime_enabled';
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

  // Status Helpers
  bool isWeekend() {
    final now = DateTime.now();
    return now.weekday == DateTime.saturday || now.weekday == DateTime.sunday;
  }

  bool isDndTime() {
    if (!dndEnabled) return false;
    final now = DateTime.now();
    final current = now.hour;
    return (dndStartHour <= dndEndHour) 
        ? (current >= dndStartHour && current < dndEndHour) 
        : (current >= dndStartHour || current < dndEndHour);
  }

  bool isEffectiveDisabled() {
    if (!chimeEnabled) return true;
    if (excludeWeekends && isWeekend() && !weekendOverride) return true;
    if (isDndTime()) return true;
    return false;
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
