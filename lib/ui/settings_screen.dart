import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
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
  final AudioPlayer _previewPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadSettings();
    
    _previewPlayer.setAudioContext(const AudioContext(
      android: AudioContextAndroid(
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.alarm,
        audioFocus: AndroidAudioFocus.gainTransientMayDuck,
      ),
    ));
  }

  void _loadSettings() {
    _chimeEnabled = widget.settings.chimeEnabled;
    _dndEnabled = widget.settings.dndEnabled;
    _dndStart = widget.settings.dndStartHour;
    _dndEnd = widget.settings.dndEndHour;
    _excludeWeekends = widget.settings.excludeWeekends;
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

  void _updateAlarm(bool enabled) {
    if (enabled) {
      AlarmService.scheduleChime();
    } else {
      AlarmService.cancelChime();
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
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chime Bell'),
        centerTitle: true,
        elevation: 2,
      ),
      body: ListView(
        children: [
          _buildBuildInfo(),
          _buildSectionTitle('General Settings'),
          SwitchListTile(
            title: const Text('Enable Hourly Chime'),
            subtitle: const Text('Plays a sound every hour'),
            secondary: const Icon(Icons.notifications_active),
            value: _chimeEnabled,
            onChanged: (val) {
              setState(() => _chimeEnabled = val);
              widget.settings.setChimeEnabled(val);
              _updateAlarm(val);
            },
          ),
          const Divider(),
          _buildSectionTitle('Do Not Disturb'),
          SwitchListTile(
            title: const Text('DND Mode'),
            subtitle: const Text('Silence chime during specific hours'),
            secondary: const Icon(Icons.do_not_disturb_on),
            value: _dndEnabled,
            onChanged: (val) {
              setState(() => _dndEnabled = val);
              widget.settings.setDndEnabled(val);
            },
          ),
          if (_dndEnabled) ...[
            _buildTimePicker('Start Hour', _dndStart, (val) {
              setState(() => _dndStart = val);
              widget.settings.setDndStartHour(val);
            }),
            _buildTimePicker('End Hour', _dndEnd, (val) {
              setState(() => _dndEnd = val);
              widget.settings.setDndEndHour(val);
            }),
          ],
          const Divider(),
          _buildSectionTitle('Schedule'),
          SwitchListTile(
            title: const Text('Exclude Weekends'),
            subtitle: const Text('Disable chime on Sat and Sun'),
            secondary: const Icon(Icons.calendar_month),
            value: _excludeWeekends,
            onChanged: (val) {
              setState(() => _excludeWeekends = val);
              widget.settings.setExcludeWeekends(val);
            },
          ),
          const Divider(),
          _buildSectionTitle('Volume'),
          ListTile(
            leading: const Icon(Icons.volume_up),
            title: const Text('Chime Volume'),
            subtitle: Slider(
              value: _volume,
              min: 0.0,
              max: 1.0,
              divisions: 20,
              label: '${(_volume * 100).round()}%',
              onChanged: (val) => setState(() => _volume = val),
              onChangeEnd: (val) {
                widget.settings.setVolume(val);
                _playPreview(val);
              },
            ),
            trailing: Text(
              '${(_volume * 100).round()}%',
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildTimePicker(String label, int currentHour, ValueChanged<int> onChanged) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 32),
      title: Text(label),
      trailing: DropdownButton<int>(
        value: currentHour,
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

  Widget _buildBuildInfo() {
    return GestureDetector(
      onTap: _handleDebugTap,
      child: Container(
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
