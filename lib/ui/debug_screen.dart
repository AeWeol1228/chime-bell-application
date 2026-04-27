import 'dart:io';
import 'package:flutter/material.dart';
import '../services/alarm_scheduler.dart';
import '../services/settings_service.dart';
import '../build_info.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  final SettingsService _settings = SettingsService();
  late bool _loggingEnabled;
  int _selectedTestHour = DateTime.now().hour;

  @override
  void initState() {
    super.initState();
    _loggingEnabled = _settings.debugLoggingEnabled;
  }

  Future<void> _showLogDialog() async {
    String logContent = 'Log file not found.';
    try {
      final file = File('${Directory.systemTemp.path}/execution_log.txt');
      if (await file.exists()) {
        logContent = await file.readAsString();
      }
    } catch (e) {
      logContent = 'Error reading log: $e';
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Execution Log'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Text(
              logContent.isEmpty ? 'Log is empty.' : logContent,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearLog() async {
    try {
      final file = File('${Directory.systemTemp.path}/execution_log.txt');
      if (await file.exists()) {
        await file.delete();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Log cleared.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to clear log: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Menu'),
        backgroundColor: Colors.orange.shade50,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildDebugHeader(),
          const SizedBox(height: 24),
          _buildInfoCard('Build Version', BuildInfo.buildTime, Icons.info_outline),
          const Divider(height: 32),
          
          const Text(
            'Diagnostics & Logging',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Enable Execution Logging'),
            subtitle: const Text('Logs the exact time the alarm fires to a file'),
            value: _loggingEnabled,
            onChanged: (val) {
              setState(() => _loggingEnabled = val);
              _settings.setDebugLoggingEnabled(val);
            },
          ),
          Wrap(
            spacing: 8,
            children: [
              ActionChip(
                avatar: const Icon(Icons.list_alt, size: 18),
                label: const Text('View Log'),
                onPressed: _showLogDialog,
              ),
              ActionChip(
                avatar: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Clear Log'),
                onPressed: _clearLog,
              ),
            ],
          ),
          
          const Divider(height: 32),
          const Text(
            'Manual Test Tools',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Virtual Hour for Test'),
            subtitle: const Text('Simulate specific hour for voice logic'),
            trailing: DropdownButton<int>(
              value: _selectedTestHour,
              items: List.generate(24, (i) => DropdownMenuItem(
                value: i,
                child: Text('${i.toString().padLeft(2, '0')}:00'),
              )),
              onChanged: (val) {
                if (val != null) setState(() => _selectedTestHour = val);
              },
            ),
          ),
          const SizedBox(height: 8),
          _buildTestButton(
            context,
            'Schedule 30-Sec Test Alarm',
            Icons.timer,
            () async {
              await _settings.setTestHourOverride(_selectedTestHour);
              await AlarmScheduler.scheduleTestChime();
              return 'Test alarm scheduled for 30 seconds from now (Virtual Hour: $_selectedTestHour:00).';
            },
          ),
          const SizedBox(height: 16),
          _buildTestButton(
            context,
            'Cancel Current Alarm',
            Icons.cancel,
            () async {
              await AlarmScheduler.cancelChime();
              return 'All hourly alarms cancelled.';
            },
          ),
          const SizedBox(height: 40),
          const Center(
            child: Text(
              'Use these tools only for development purposes.',
              style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebugHeader() {
    return Column(
      children: [
        const Icon(Icons.bug_report, size: 48, color: Colors.orange),
        const SizedBox(height: 8),
        const Text(
          'Debugging & Diagnostics',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Card(
      elevation: 0,
      color: Colors.blueGrey.shade50,
      child: ListTile(
        leading: Icon(icon, color: Colors.blueGrey),
        title: Text(title, style: const TextStyle(fontSize: 14)),
        subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildTestButton(BuildContext context, String label, IconData icon, Future<String> Function() action) {
    return ElevatedButton.icon(
      onPressed: () async {
        final message = await action();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
          );
        }
      },
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    );
  }
}
