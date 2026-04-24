import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/settings_service.dart';
import '../services/alarm_service.dart';

class SettingsPage extends StatefulWidget {
  final SettingsService settings;

  const SettingsPage({super.key, required this.settings});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late String _language;
  late bool _dndEnabled;
  late int _dndStart;
  late int _dndEnd;
  late bool _excludeWeekends;
  late bool _allowWhileIdle;
  bool _isBatteryOptimized = true;

  // Localization Data
  final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title': 'Settings',
      'lang_section': 'Language',
      'lang_title': 'App Language',
      'lang_sub': 'Select Korean or English',
      'dnd_section': 'Do Not Disturb',
      'dnd_title': 'DND Mode',
      'dnd_sub': 'Silence chime during specific hours',
      'start_hour': 'Start Hour',
      'end_hour': 'End Hour',
      'sch_section': 'Schedule',
      'sch_weekend': 'Exclude Weekends',
      'sch_weekend_sub': 'Disable chime on Sat and Sun',
      'batt_section': 'Battery & Performance',
      'batt_idle': 'Exact Alarms in Doze Mode',
      'batt_idle_sub': 'Ensure chime fires even when idle',
      'batt_opt': 'Battery Optimization',
      'batt_opt_on': 'Currently Optimized (May delay chimes)',
      'batt_opt_off': 'Exempt from Optimization (Recommended)',
      'btn_disable': 'DISABLE',
      'btn_settings': 'SETTINGS',
    },
    'ko': {
      'title': '설정',
      'lang_section': '언어',
      'lang_title': '앱 언어',
      'lang_sub': '한국어 또는 English 선택',
      'dnd_section': '방해 금지 모드 (DND)',
      'dnd_title': 'DND 모드 활성화',
      'dnd_sub': '지정한 시간 동안 종소리 끄기',
      'start_hour': '시작 시간',
      'end_hour': '종료 시간',
      'sch_section': '스케줄',
      'sch_weekend': '주말 제외',
      'sch_weekend_sub': '주말엔 쉬어가기',
      'batt_section': '알람이 울리지 않을 때',
      'batt_idle': 'DOZE 모드에서 정시 알람',
      'batt_idle_sub': '화면이 꺼져 있을 때도 정시 실행 보장',
      'batt_opt': '배터리 최적화 상태',
      'batt_opt_on': '최적화 중 (알람이 지연될 수 있음)',
      'batt_opt_off': '최적화 예외 (권장 설정)',
      'btn_disable': '최적화 끄기',
      'btn_settings': '설정 열기',
    }
  };

  String _t(String key) {
    return _localizedValues[_language]?[key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _checkBatteryOptimization();
  }

  void _loadSettings() {
    _language = widget.settings.language;
    _dndEnabled = widget.settings.dndEnabled;
    _dndStart = widget.settings.dndStartHour;
    _dndEnd = widget.settings.dndEndHour;
    _excludeWeekends = widget.settings.excludeWeekends;
    _allowWhileIdle = widget.settings.allowWhileIdle;
  }

  Future<void> _checkBatteryOptimization() async {
    final status = await Permission.ignoreBatteryOptimizations.status;
    setState(() {
      _isBatteryOptimized = !status.isGranted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_t('title')),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          // 0. Language 설정
          _buildSectionHeader(_t('lang_section')),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              title: Text(_t('lang_title')),
              subtitle: Text(_t('lang_sub')),
              leading: const Icon(Icons.language),
              trailing: DropdownButton<String>(
                value: _language,
                underline: const SizedBox(), // 밑줄 제거로 깔끔하게
                items: const [
                  DropdownMenuItem(value: 'ko', child: Text('한국어')),
                  DropdownMenuItem(value: 'en', child: Text('English')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _language = val);
                    widget.settings.setLanguage(val);
                  }
                },
              ),
            ),
          ),
          const Divider(height: 32, thickness: 1),

          // 1. DND 설정
          _buildSectionHeader(_t('dnd_section')),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text(_t('dnd_title')),
            subtitle: Text(_t('dnd_sub')),
            secondary: const Icon(Icons.do_not_disturb_on),
            value: _dndEnabled,
            onChanged: (val) {
              setState(() => _dndEnabled = val);
              widget.settings.setDndEnabled(val);
            },
          ),
          if (_dndEnabled) ...[
            _buildTimePicker(_t('start_hour'), _dndStart, (val) {
              setState(() => _dndStart = val);
              widget.settings.setDndStartHour(val);
            }),
            _buildTimePicker(_t('end_hour'), _dndEnd, (val) {
              setState(() => _dndEnd = val);
              widget.settings.setDndEndHour(val);
            }),
          ],
          const SizedBox(height: 16),
          const Divider(height: 32, thickness: 1),

          // 2. Exclude Weekends (Schedule)
          _buildSectionHeader(_t('sch_section')),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text(_t('sch_weekend')),
            subtitle: Text(_t('sch_weekend_sub')),
            secondary: const Icon(Icons.calendar_month),
            value: _excludeWeekends,
            onChanged: (val) {
              setState(() => _excludeWeekends = val);
              widget.settings.setExcludeWeekends(val);
            },
          ),
          const SizedBox(height: 16),
          const Divider(height: 32, thickness: 1),

          // 3. Battery 관련 설정
          _buildSectionHeader(_t('batt_section')),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text(_t('batt_idle')),
            subtitle: Text(_t('batt_idle_sub')),
            secondary: const Icon(Icons.bolt),
            value: _allowWhileIdle,
            onChanged: (val) {
              setState(() => _allowWhileIdle = val);
              widget.settings.setAllowWhileIdle(val);
              if (widget.settings.chimeEnabled) {
                AlarmService.scheduleChime();
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(_t('batt_opt')),
              subtitle: Text(_isBatteryOptimized 
                  ? _t('batt_opt_on') 
                  : _t('batt_opt_off')),
              leading: Icon(
                _isBatteryOptimized ? Icons.battery_saver : Icons.battery_full,
                color: _isBatteryOptimized ? Colors.orange : Colors.green,
              ),
              trailing: TextButton(
                onPressed: () async {
                  if (_isBatteryOptimized) {
                    await Permission.ignoreBatteryOptimizations.request();
                  } else {
                    await openAppSettings();
                  }
                  _checkBatteryOptimization();
                },
                child: Text(_isBatteryOptimized ? _t('btn_disable') : _t('btn_settings')),
              ),
            ),
          ),
          const SizedBox(height: 40), // 마지막 여백 추가
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12), // 상단 여백 대폭 증가
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 15, // 폰트 크기 약간 키움
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTimePicker(String label, int currentHour, ValueChanged<int> onChanged) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 2), // 들여쓰기 강화
      title: Text(label),
      trailing: DropdownButton<int>(
        value: currentHour,
        underline: const SizedBox(), // 밑줄 제거
        items: List.generate(24, (i) => DropdownMenuItem(
          value: i, 
          child: Text('${i.toString().padLeft(2, '0')}:00')
        )),
        onChanged: (val) {
          if (val != null) onChanged(val);
        },
      ),
    );
  }
}
