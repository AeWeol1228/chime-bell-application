import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _keyChimeEnabled = 'chime_enabled';
  static const String _keyDndEnabled = 'dnd_enabled';
  static const String _keyDndStartHour = 'dnd_start_hour';
  static const String _keyDndEndHour = 'dnd_end_hour';
  static const String _keyExcludeWeekends = 'exclude_weekends';
  static const String _keySelectedSound = 'selected_sound';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  bool get chimeEnabled => _prefs.getBool(_keyChimeEnabled) ?? true;
  Future<void> setChimeEnabled(bool value) => _prefs.setBool(_keyChimeEnabled, value);

  bool get dndEnabled => _prefs.getBool(_keyDndEnabled) ?? false;
  Future<void> setDndEnabled(bool value) => _prefs.setBool(_keyDndEnabled, value);

  int get dndStartHour => _prefs.getInt(_keyDndStartHour) ?? 22; // Default 10 PM
  Future<void> setDndStartHour(int value) => _prefs.setInt(_keyDndStartHour, value);

  int get dndEndHour => _prefs.getInt(_keyDndEndHour) ?? 7; // Default 7 AM
  Future<void> setDndEndHour(int value) => _prefs.setInt(_keyDndEndHour, value);

  bool get excludeWeekends => _prefs.getBool(_keyExcludeWeekends) ?? false;
  Future<void> setExcludeWeekends(bool value) => _prefs.setBool(_keyExcludeWeekends, value);

  String get selectedSound => _prefs.getString(_keySelectedSound) ?? 'default_chime.mp3';
  Future<void> setSelectedSound(String value) => _prefs.setString(_keySelectedSound, value);
}
