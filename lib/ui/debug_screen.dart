import 'package:flutter/material.dart';
import '../services/alarm_service.dart';
import '../build_info.dart';

class DebugScreen extends StatelessWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Menu'),
        backgroundColor: Colors.red.shade100,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Developer & Debugging Tools',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              title: const Text('Build Version'),
              subtitle: Text(BuildInfo.buildTime),
              leading: const Icon(Icons.info_outline),
            ),
          ),
          const Divider(),
          const ListTile(
            title: Text('Alarm Tests'),
            subtitle: Text('Test alarm scheduling and notifications'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              await AlarmService.scheduleTestChime();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Test alarm scheduled for 1 minute from now.')),
                );
              }
            },
            icon: const Icon(Icons.timer),
            label: const Text('Schedule 1-Min Test Alarm'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade100,
              foregroundColor: Colors.orange.shade900,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'More debugging features can be added here.',
            style: TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
