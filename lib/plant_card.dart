import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'plant.dart';

class PlantCard extends StatelessWidget {
  final Plant plant;
  final VoidCallback onWater; //call when click Mark as Watered
  final VoidCallback onDelete;//call when click delete

  const PlantCard({
    super.key,
    required this.plant,
    required this.onWater,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final isOverdue = plant.needsWatering;//check if plant need water

    return Container(//card form
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: plant.color.withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: plant.color,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_florist,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plant.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        plant.type,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onDelete,
                  color: Colors.red[300],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(
                  icon: Icons.calendar_today,
                  label: 'Last Watered',
                  value: dateFormat.format(plant.lastWatered),
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.schedule,
                  label: 'Next Watering',
                  value: dateFormat.format(plant.nextWateringDate),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isOverdue
                        ? Colors.red[50]
                        : plant.daysUntilWatering <= 2
                        ? Colors.orange[50]
                        : Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isOverdue
                          ? Colors.red[300]!
                          : plant.daysUntilWatering <= 2
                          ? Colors.orange[300]!
                          : Colors.blue[300]!,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isOverdue
                            ? Icons.warning
                            : plant.daysUntilWatering <= 2
                            ? Icons.water_drop
                            : Icons.check_circle,
                        size: 16,
                        color: isOverdue
                            ? Colors.red[700]
                            : plant.daysUntilWatering <= 2
                            ? Colors.orange[700]
                            : Colors.blue[700],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isOverdue
                            ? 'Overdue by ${-plant.daysUntilWatering} day${-plant.daysUntilWatering != 1 ? 's' : ''}'
                            : 'Water in ${plant.daysUntilWatering} day${plant.daysUntilWatering != 1 ? 's' : ''}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isOverdue
                              ? Colors.red[700]
                              : plant.daysUntilWatering <= 2
                              ? Colors.orange[700]
                              : Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ),
                if (plant.notes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.note,
                    label: 'Notes',
                    value: plant.notes,
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onWater,
                    icon: const Icon(Icons.water_drop),
                    label: const Text('Mark as Watered'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}


