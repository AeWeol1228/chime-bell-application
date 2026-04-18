import 'package:flutter/material.dart';
import '../services/alarm_service.dart';
import '../build_info.dart';

class DebugScreen extends StatelessWidget {
  const DebugScreen({super.key});

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
            'Manual Test Tools',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildTestButton(
            context,
            'Schedule 1-Min Test Alarm',
            Icons.timer,
            () async {
              await AlarmService.scheduleTestChime();
              return 'Test alarm scheduled for 1 minute from now.';
            },
          ),
          const SizedBox(height: 16),
          _buildTestButton(
            context,
            'Cancel Current Alarm',
            Icons.cancel,
            () async {
              await AlarmService.cancelChime();
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
