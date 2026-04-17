import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../services/alarm_service.dart';

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

  // Manual Build ID for user verification
  final String _buildID = "Build: 2026-04-15 21:30 (Final Fixed)";

  @override
  void initState() {
    super.initState();
    _chimeEnabled = widget.settings.chimeEnabled;
    _dndEnabled = widget.settings.dndEnabled;
    _dndStart = widget.settings.dndStartHour;
    _dndEnd = widget.settings.dndEndHour;
    _excludeWeekends = widget.settings.excludeWeekends;

    // Show visual confirmation that the update was applied
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Update Applied: $_buildID'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    });
  }

  void _updateAlarm() {
    if (_chimeEnabled) {
      AlarmService.scheduleChime();
    } else {
      AlarmService.cancelChime();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chime Bell Settings')),
      body: ListView(
        children: [
          Container(
            color: Colors.green.shade50,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              '$_buildID - OK',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold),
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () async {
                await AlarmService.scheduleTestChime();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Test alarm scheduled for 1 minute from now.')),
                  );
                }
              },
              icon: const Icon(Icons.timer),
              label: const Text('Test 1 Minute Alarm (Debug)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade100,
                foregroundColor: Colors.orange.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
