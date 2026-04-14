import 'package:flutter/material.dart';
import 'services/settings_service.dart';
import 'services/alarm_service.dart';
import 'ui/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Services
  final settingsService = SettingsService();
  await settingsService.init();
  await AlarmService.init();

  // If chime is enabled, make sure it is scheduled
  if (settingsService.chimeEnabled) {
    AlarmService.scheduleChime();
  }

  runApp(MyApp(settings: settingsService));
}

class MyApp extends StatelessWidget {
  final SettingsService settings;

  const MyApp({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chime Bell',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: SettingsScreen(settings: settings),
    );
  }
}
