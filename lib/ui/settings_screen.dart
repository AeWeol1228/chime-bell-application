import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/settings_service.dart';
import '../services/alarm_scheduler.dart';
import '../build_info.dart';
import 'debug_screen.dart';
import 'settings_page.dart';

class SettingsScreen extends StatefulWidget {
  final SettingsService settings;

  const SettingsScreen({super.key, required this.settings});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _language;
  late bool _chimeEnabled;
  late double _volume;
  int _debugTapCount = 0;
  final AudioPlayer _previewPlayer = AudioPlayer();

  // Localization Data for Main Dashboard
  final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_name': 'Time Chime',
      'active': 'Chime is Active',
      'disabled': 'Chime is Disabled',
      'stop': 'STOP CHIME',
      'start': 'START CHIME',
      'volume': 'Quick Volume Control',
      'weekend_title': 'Weekend Chime',
      'weekend_msg': 'Shall we keep the alarm on for this weekend?',
      'weekend_override_msg': 'Alarm will ring this weekend.',
      'dnd_title': 'DND Mode Active',
      'dnd_msg': 'DND mode is currently on. You can change this in settings.',
      'yes': 'Yes',
      'no': 'No',
      'ok': 'OK',
    },
    'ko': {
      'app_name': '정시의 울림',
      'active': '울릴 준비 중!',
      'disabled': '비활성 상태에요',
      'stop': '쉬게 하기',
      'start': '깨우기',
      'volume': '볼륨 조절',
      'weekend_title': '주말 알람',
      'weekend_msg': '이번 주는 주말에도 알람을 켜둘까요?',
      'weekend_override_msg': '이번 주말은 알람이 울려요.',
      'dnd_title': '방해 금지 모드',
      'dnd_msg': '지금은 방해 금지 시간입니다. 설정창에서 변경할 수 있습니다.',
      'yes': '네',
      'no': '아니오',
      'ok': '확인',
    }
  };

  String _t(String key) {
    return _localizedValues[_language]?[key] ?? key;
  }

  bool get _isEffectiveDisabled => widget.settings.isEffectiveDisabled();

  @override
  void initState() {
    super.initState();
    _loadSettings();
    
    _previewPlayer.setAudioContext(const AudioContext(
      android: AudioContextAndroid(
        contentType: AndroidContentType.sonification,
        usageType: AndroidUsageType.alarm,
        audioFocus: AndroidAudioFocus.gainTransientMayDuck,
      ),
    ));
  }

  void _loadSettings() {
    _language = widget.settings.language;
    _chimeEnabled = widget.settings.chimeEnabled;
    _volume = widget.settings.volume;
  }

  @override
  void dispose() {
    _previewPlayer.dispose();
    super.dispose();
  }

  void _playPreview(double vol) async {
    await _previewPlayer.setVolume(vol);
    if (_previewPlayer.state != PlayerState.playing) {
      await _previewPlayer.play(AssetSource('sounds/${widget.settings.selectedSound}'));
    }
  }

  void _handleDebugTap() {
    _debugTapCount++;
    if (_debugTapCount >= 7) {
      _debugTapCount = 0;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DebugScreen()),
      );
    }
  }

  void _showWeekendDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_t('weekend_title')),
        content: Text(_t('weekend_msg')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_t('no')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _chimeEnabled = true);
              await widget.settings.setChimeEnabled(true);
              await widget.settings.setWeekendOverride(true);
              AlarmScheduler.scheduleChime();
            },
            child: Text(_t('yes')),
          ),
        ],
      ),
    );
  }

  void _showDndDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_t('dnd_title')),
        content: Text(_t('dnd_msg')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_t('ok')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool effectiveDisabled = _isEffectiveDisabled;
    final bool showWeekendOverrideInfo = widget.settings.excludeWeekends && 
                                          widget.settings.isWeekend() && 
                                          widget.settings.weekendOverride;

    return Scaffold(
      appBar: AppBar(
        title: Text(_t('app_name')),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildBuildInfo(),
          const SizedBox(height: 16),
          // 커다란 설정 아이콘 버튼
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: IconButton(
                icon: const Icon(Icons.settings, size: 36), // 크기 키움
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsPage(settings: widget.settings),
                    ),
                  );
                  setState(() {
                    _loadSettings();
                  });
                },
                color: Colors.blueGrey,
              ),
            ),
          ),
          const Spacer(),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  !effectiveDisabled ? Icons.notifications_active : Icons.notifications_off,
                  size: 100,
                  color: !effectiveDisabled ? Colors.blue : Colors.grey,
                ),
                const SizedBox(height: 24),
                Text(
                  !effectiveDisabled ? _t('active') : _t('disabled'),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                if (showWeekendOverrideInfo && !effectiveDisabled)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _t('weekend_override_msg'),
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: () async {
                    if (!effectiveDisabled) {
                      // 현재 켜져 있는 상태 -> 끄기 (DND/주말 상관없이 강제 종료)
                      setState(() => _chimeEnabled = false);
                      await widget.settings.setChimeEnabled(false);
                      await widget.settings.setWeekendOverride(false); // 오버라이드 초기화
                      AlarmScheduler.cancelChime();
                    } else {
                      // 현재 꺼져 있는 상태 -> 켜기 시도
                      if (widget.settings.isDndTime()) {
                        _showDndDialog();
                        return;
                      }
                      
                      if (widget.settings.excludeWeekends && widget.settings.isWeekend()) {
                        _showWeekendDialog();
                        return;
                      }

                      // 일반적인 켜기
                      setState(() => _chimeEnabled = true);
                      await widget.settings.setChimeEnabled(true);
                      AlarmScheduler.scheduleChime();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 20),
                    backgroundColor: !effectiveDisabled 
                        ? Colors.grey.shade300 
                        : Colors.blue.shade400, 
                    foregroundColor: !effectiveDisabled 
                        ? Colors.blueGrey.shade900 
                        : Colors.white, 
                    elevation: 2, 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(
                    !effectiveDisabled ? _t('stop') : _t('start'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Text(_t('volume')),
                Slider(
                  value: _volume,
                  onChanged: (val) => setState(() => _volume = val),
                  onChangeEnd: (val) {
                    widget.settings.setVolume(val);
                    _playPreview(val);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuildInfo() {
    return GestureDetector(
      onTap: _handleDebugTap,
      child: Container(
        width: double.infinity,
        color: Colors.grey.withOpacity(0.05),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Build: ${BuildInfo.buildTime}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ),
    );
  }
}
