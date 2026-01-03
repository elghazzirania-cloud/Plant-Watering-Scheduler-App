import 'package:flutter/material.dart';




class Plant {
  int? id;
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


  factory Plant.fromJson(Map<String, dynamic> json) {
    
    Color plantColor = Colors.green; 
    if (json['color'] != null) {
      final colorStr = json['color'].toString();
      if (colorStr.startsWith('#')) {
        
        plantColor = Color(int.parse(colorStr.substring(1), radix: 16) + 0xFF000000);
      } else {
       
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
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final nextDate = DateTime(nextWateringDate.year, nextWateringDate.month, nextWateringDate.day);
    return !nextDate.isAfter(today); 
  }

  
  int get daysUntilWatering {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final nextDate = DateTime(nextWateringDate.year, nextWateringDate.month, nextWateringDate.day);
    final difference = nextDate.difference(today);
    final days = difference.inDays;
    return days < 0 ? 0 : days;
  }
}


