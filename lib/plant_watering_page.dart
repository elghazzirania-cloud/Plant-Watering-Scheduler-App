import 'package:flutter/material.dart';
import 'plant.dart';
import 'empty_state.dart';//when there are no plants
import 'summary_card.dart';//summary of all plants
import 'plant_card.dart';
import 'add_plant_dialog.dart';

class PlantWateringPage extends StatefulWidget {
  const PlantWateringPage({super.key});

  @override
  State<PlantWateringPage> createState() => _PlantWateringPageState();
}

class _PlantWateringPageState extends State<PlantWateringPage> {
  final List<Plant> _plants = [//some default plants that can be deleted
    Plant(
      name: 'Monstera',
      type: 'Indoor Plant',
      lastWatered: DateTime.now().subtract(const Duration(days: 3)),
      wateringIntervalDays: 7,
      notes: 'Likes indirect sunlight',
      color: Colors.green,
    ),
    Plant(
      name: 'Snake Plant',
      type: 'Succulent',
      lastWatered: DateTime.now().subtract(const Duration(days: 10)),
      wateringIntervalDays: 14,
      notes: 'Very low maintenance',
      color: Colors.teal,
    ),
    Plant(
      name: 'Peace Lily',
      type: 'Flowering Plant',
      lastWatered: DateTime.now().subtract(const Duration(days: 2)),
      wateringIntervalDays: 5,
      notes: 'Keep soil moist',
      color: Colors.lightGreen,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Check for overdue plants after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOverduePlants();
    });
  }

  void _checkOverduePlants() {
    final overduePlants = _plants.where((plant) => plant.needsWatering).toList();
    if (overduePlants.isNotEmpty 
        && mounted) {
        
      final plantNames = overduePlants.map((p) => p.name).join(', ');
      final count = overduePlants.length;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            count == 1
                ? '⚠️ $plantNames needs watering!'
                : '⚠️ $count plants need watering: $plantNames',
          ),
          backgroundColor: Colors.red[600],
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  void _addPlant() {
    showDialog(
      context: context,
      builder: (context) => AddPlantDialog(//call to add plant
        onAdd: (plant) {
          setState(() {
            _plants.add(plant);
          });
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _waterPlant(int index) {
    setState(() {
      _plants[index].lastWatered = DateTime.now();//Updates the lastWatered date of the plant.
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_plants[index].name} has been watered!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _deletePlant(int index) {
    setState(() {
      _plants.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Plant Watering Scheduler',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: _plants.isEmpty
            ? const EmptyState()
            : Column(
          children: [
            SummaryCard(plants: _plants),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _plants.length,
                itemBuilder: (context, index) {
                  return PlantCard(
                    plant: _plants[index],
                    onWater: () => _waterPlant(index),
                    onDelete: () => _deletePlant(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(//Button to add a new plant.
        onPressed: _addPlant,
        icon: const Icon(Icons.add),
        label: const Text('Add Plant'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}


