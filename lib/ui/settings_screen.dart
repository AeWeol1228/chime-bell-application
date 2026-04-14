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

  @override
  void initState() {
    super.initState();
    _chimeEnabled = widget.settings.chimeEnabled;
    _dndEnabled = widget.settings.dndEnabled;
    _dndStart = widget.settings.dndStartHour;
    _dndEnd = widget.settings.dndEndHour;
    _excludeWeekends = widget.settings.excludeWeekends;
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
        ],
      ),
    );
  }
}
