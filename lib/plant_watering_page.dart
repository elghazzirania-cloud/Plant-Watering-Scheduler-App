import 'package:flutter/material.dart';
import 'plant.dart';
import 'empty_state.dart';
import 'summary_card.dart';
import 'plant_card.dart';
import 'add_plant_dialog.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';

class PlantWateringPage extends StatefulWidget {
  const PlantWateringPage({super.key});

  @override
  State<PlantWateringPage> createState() => _PlantWateringPageState();
}

class _PlantWateringPageState extends State<PlantWateringPage> {
  List<Plant> _plants = [];
  bool _isLoading = true;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadPlants();
  }

  Future<void> _loadPlants() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _userId = await AuthService.getCurrentUserId();
      if (_userId != null) {
        final plants = await ApiService.getPlants(_userId!);
        setState(() {
          _plants = plants;
          _isLoading = false;
        });
       
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _checkOverduePlants();
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load plants: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

  void _addPlant() async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to add plants'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AddPlantDialog(
        onAdd: (plant) async {
          Navigator.of(context).pop(); 
          
          try {
            final plantId = await ApiService.addPlant(
              userId: _userId!,
              name: plant.name,
              type: plant.type,
              lastWatered: plant.lastWatered,
              wateringIntervalDays: plant.wateringIntervalDays,
              notes: plant.notes,
              color: _colorToString(plant.color),
            );
            
           
            plant.id = plantId;
            
            if (mounted) {
              setState(() {
                _plants.add(plant);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Plant added successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to add plant: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  String _colorToString(Color color) {
    
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  void _waterPlant(int index) async {
    if (_userId == null || _plants[index].id == null) return;

    try {
      await ApiService.waterPlant(_plants[index].id!, _userId!);
      
      setState(() {
        _plants[index].lastWatered = DateTime.now();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_plants[index].name} has been watered!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update plant: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _deletePlant(int index) async {
    if (_userId == null || _plants[index].id == null) return;

    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Plant'),
        content: Text('Are you sure you want to delete ${_plants[index].name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.deletePlant(_plants[index].id!, _userId!);
        
        setState(() {
          _plants.removeAt(index);
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Plant deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete plant: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _plants.isEmpty
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addPlant,
        icon: const Icon(Icons.add),
        label: const Text('Add Plant'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}