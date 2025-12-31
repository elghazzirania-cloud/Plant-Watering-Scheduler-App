import 'package:flutter/material.dart';
import 'main_navigation.dart';

void main() async {
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
      routes: {'/home': (context) => const MainNavigation()},
      debugShowCheckedModeBanner: false,
    );
  }
}
