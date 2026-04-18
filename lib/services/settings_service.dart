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
  static const String _keySelectedSound = 'selected_sound';
  static const String _keyVolume = 'volume';

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

  String get selectedSound => _prefs.getString(_keySelectedSound) ?? 'default_chime.mp3';
  Future<void> setSelectedSound(String value) => _setString(_keySelectedSound, value);

  double get volume => _prefs.getDouble(_keyVolume) ?? 1.0;
  Future<void> setVolume(double value) => _setDouble(_keyVolume, value);
}
