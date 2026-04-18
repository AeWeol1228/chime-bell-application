import 'package:flutter/material.dart';
import 'services/settings_service.dart';
import 'services/alarm_service.dart';
import 'ui/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Services (Singleton)
  final settingsService = SettingsService();
  await settingsService.init();
  
  // Initialize Alarm Service
  await AlarmService.init();

  if (settingsService.chimeEnabled) {
    AlarmService.scheduleChime();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chime Bell',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo, 
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo, 
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: SettingsScreen(settings: SettingsService()),
    );
  }
}
