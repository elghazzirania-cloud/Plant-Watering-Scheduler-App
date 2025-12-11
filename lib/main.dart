import 'package:flutter/material.dart';
import 'main_navigation.dart';
import 'notification_service.dart'; // NEW IMPORT

final NotificationService notificationService = NotificationService();

void main() async {
  // Main must be async now
  WidgetsFlutterBinding.ensureInitialized();
  await notificationService.init(); // Initialize the service
  runApp(const PlantWateringApp());
}

class PlantWateringApp extends StatelessWidget {
  const PlantWateringApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plant Watering Scheduler',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
      ),
      home: const MainNavigation(),
      debugShowCheckedModeBanner: false,
    );
  }
}
