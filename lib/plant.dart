import 'package:flutter/material.dart';




class Plant {
  int? id; // ID from database (null for new plants)
  String name;
  String type;
  DateTime lastWatered;
  int wateringIntervalDays;
  String notes;
  Color color;

  Plant({
    this.id,
    required this.name,
    required this.type,
    required this.lastWatered,
    required this.wateringIntervalDays,
    this.notes = '',
    required this.color,
  });

  // Convert from JSON (API response)
  factory Plant.fromJson(Map<String, dynamic> json) {
    // Parse color from string (e.g., "#4CAF50" or color name)
    Color plantColor = Colors.green; // default
    if (json['color'] != null) {
      final colorStr = json['color'].toString();
      if (colorStr.startsWith('#')) {
        // Hex color
        plantColor = Color(int.parse(colorStr.substring(1), radix: 16) + 0xFF000000);
      } else {
        // Try to match color name
        switch (colorStr.toLowerCase()) {
          case 'green':
            plantColor = Colors.green;
            break;
          case 'teal':
            plantColor = Colors.teal;
            break;
          case 'lightgreen':
            plantColor = Colors.lightGreen;
            break;
          case 'blue':
            plantColor = Colors.blue;
            break;
          case 'purple':
            plantColor = Colors.purple;
            break;
          case 'pink':
            plantColor = Colors.pink;
            break;
          case 'orange':
            plantColor = Colors.orange;
            break;
          case 'amber':
            plantColor = Colors.amber;
            break;
        }
      }
    }

    // Parse last_watered date
    DateTime lastWateredDate;
    if (json['last_watered'] != null) {
      try {
        lastWateredDate = DateTime.parse(json['last_watered']);
      } catch (e) {
        lastWateredDate = DateTime.now();
      }
    } else {
      lastWateredDate = DateTime.now();
    }

    return Plant(
      id: json['id'] != null ? int.parse(json['id'].toString()) : null,
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      lastWatered: lastWateredDate,
      wateringIntervalDays: int.parse(json['watering_interval_days'].toString()),
      notes: json['notes'] ?? '',
      color: plantColor,
    );
  }

  DateTime get nextWateringDate {
    return lastWatered.add(Duration(days: wateringIntervalDays));
  }

  bool get needsWatering {
    return DateTime.now().isAfter(nextWateringDate) ||
        DateTime.now().isAtSameMomentAs(nextWateringDate);
  }

  int get daysUntilWatering {
    final difference = nextWateringDate.difference(DateTime.now());
    return difference.inDays;
  }
}


