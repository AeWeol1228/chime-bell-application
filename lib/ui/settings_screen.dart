import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/settings_service.dart';
import '../services/alarm_service.dart';
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
    },
    'ko': {
      'app_name': '정시의 울림',
      'active': '울릴 준비 중!',
      'disabled': '비활성 상태에요',
      'stop': '쉬게 하기',
      'start': '깨우기',
      'volume': '볼륨 조절',
    }
  };

  String _t(String key) {
    return _localizedValues[_language]?[key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
    
    _previewPlayer.setAudioContext(const AudioContext(
      android: AudioContextAndroid(
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
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

  @override
  Widget build(BuildContext context) {
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
                  _chimeEnabled ? Icons.notifications_active : Icons.notifications_off,
                  size: 100,
                  color: _chimeEnabled ? Colors.blue : Colors.grey,
                ),
                const SizedBox(height: 24),
                Text(
                  _chimeEnabled ? _t('active') : _t('disabled'),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: () {
                    final newVal = !_chimeEnabled;
                    setState(() => _chimeEnabled = newVal);
                    widget.settings.setChimeEnabled(newVal);
                    if (newVal) {
                      AlarmService.scheduleChime();
                    } else {
                      AlarmService.cancelChime();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 20),
                    backgroundColor: _chimeEnabled 
                        ? Colors.grey.shade300 // 쉬게 하기: 차분한 회색
                        : Colors.blue.shade400, // 깨우기: 밝은 파란색
                    foregroundColor: _chimeEnabled 
                        ? Colors.blueGrey.shade900 // 회색 버튼 위에는 진한 남색 글씨
                        : Colors.white, // 파란 버튼 위에는 흰색 글씨
                    elevation: 2, // 그림자 약간 낮춰서 차분하게
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(
                    _chimeEnabled ? _t('stop') : _t('start'),
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
