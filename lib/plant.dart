import 'package:flutter/material.dart';




class Plant {
  String name;
  String type;
  DateTime lastWatered;
  int wateringIntervalDays;
  String notes;
  Color color;

  Plant({
    required this.name,
    required this.type,
    required this.lastWatered,
    required this.wateringIntervalDays,
    this.notes = '',
    required this.color,
  });

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


