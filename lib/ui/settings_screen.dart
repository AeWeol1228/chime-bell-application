import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart'; // Add this
import '../services/settings_service.dart';
import '../services/alarm_service.dart';
import '../build_info.dart';
import 'debug_screen.dart';

class SettingsScreen extends StatefulWidget {
  final SettingsService settings;

  const SettingsScreen({super.key, required this.settings});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _chimeEnabled;
  late bool _dndEnabled;
  late int _dndStart;
  late int _dndEnd;
  late bool _excludeWeekends;
  late double _volume;
  int _debugTapCount = 0;
  final AudioPlayer _previewPlayer = AudioPlayer(); // For volume preview

  // Manual Build ID for user verification
  final String _buildID = "Build: ${BuildInfo.buildTime} (Final Fixed)";

  @override
  void initState() {
    super.initState();
    _chimeEnabled = widget.settings.chimeEnabled;
    _dndEnabled = widget.settings.dndEnabled;
    _dndStart = widget.settings.dndStartHour;
    _dndEnd = widget.settings.dndEndHour;
    _excludeWeekends = widget.settings.excludeWeekends;
    _volume = widget.settings.volume;
    
    // Set preview player context to match alarm type
    _previewPlayer.setAudioContext(const AudioContext(
      android: AudioContextAndroid(
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.alarm,
        audioFocus: AndroidAudioFocus.gainTransientMayDuck,
      ),
    ));
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

  void _updateAlarm() {
    if (_chimeEnabled) {
      AlarmService.scheduleChime();
    } else {
      AlarmService.cancelChime();
    }
  }

  void _handleDebugTap() {
    setState(() {
      _debugTapCount++;
      if (_debugTapCount >= 7) {
        _debugTapCount = 0;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DebugScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chime Bell Settings')),
      body: ListView(
        children: [
          GestureDetector(
            onTap: _handleDebugTap,
            child: Container(
              color: Colors.green.shade50,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                '$_buildID - OK',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Enable Hourly Chime'),
            value: _chimeEnabled,
            onChanged: (val) {
              setState(() => _chimeEnabled = val);
              widget.settings.setChimeEnabled(val);
              _updateAlarm();
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Do Not Disturb (DND)'),
            value: _dndEnabled,
            onChanged: (val) {
              setState(() => _dndEnabled = val);
              widget.settings.setDndEnabled(val);
            },
          ),
          if (_dndEnabled) ...[
            ListTile(
              title: const Text('DND Start Hour'),
              trailing: DropdownButton<int>(
                value: _dndStart,
                items: List.generate(24, (i) => DropdownMenuItem(value: i, child: Text('$i:00'))),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _dndStart = val);
                    widget.settings.setDndStartHour(val);
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('DND End Hour'),
              trailing: DropdownButton<int>(
                value: _dndEnd,
                items: List.generate(24, (i) => DropdownMenuItem(value: i, child: Text('$i:00'))),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _dndEnd = val);
                    widget.settings.setDndEndHour(val);
                  }
                },
              ),
            ),
          ],
          const Divider(),
          SwitchListTile(
            title: const Text('Exclude Weekends'),
            value: _excludeWeekends,
            onChanged: (val) {
              setState(() => _excludeWeekends = val);
              widget.settings.setExcludeWeekends(val);
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Chime Volume'),
            subtitle: Slider(
              value: _volume,
              min: 0.0,
              max: 1.0,
              divisions: 20, // More granular
              label: '${(_volume * 100).round()}%',
              onChanged: (val) {
                setState(() => _volume = val);
              },
              onChangeEnd: (val) { // Play sound only when user stops dragging
                widget.settings.setVolume(val);
                _playPreview(val);
              },
            ),
            trailing: Text('${(_volume * 100).round()}%'),
          ),
          const Divider(),
        ],
      ),
    );
  }
}

