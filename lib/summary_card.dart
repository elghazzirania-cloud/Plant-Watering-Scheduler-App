import 'package:flutter/material.dart';
import 'plant.dart';

class SummaryCard extends StatelessWidget {
  final List<Plant> plants;

  const SummaryCard({super.key, required this.plants});

  @override
  Widget build(BuildContext context) {
    final needsWatering = plants.where((p) => p.needsWatering).length;
    final totalPlants = plants.length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem(
            icon: Icons.local_florist,
            label: 'Total Plants',
            value: totalPlants.toString(),
            color: Colors.green,
          ),
          Container(
            width: 1,
            height: 50,
            color: Colors.grey[300],
          ),
          _SummaryItem(
            icon: Icons.water_drop,
            label: 'Need Watering',
            value: needsWatering.toString(),
            color: needsWatering > 0 ? Colors.orange : Colors.blue,
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}


