import 'package:flutter/material.dart';

import 'medicine_type.dart';

class GlobalFunctions {
  static String getMedicineTypeAsset(MedicineType type) {
    switch (type) {
      case MedicineType.tablet:
        return 'assets/images/medicine_tablet.png';
      case MedicineType.injection:
        return 'assets/images/medicine_injection.png';
      case MedicineType.capsule:
        return 'assets/images/medicine_capsule.png';
      case MedicineType.spray:
        return 'assets/images/medicine_spray.png';
      }
  }

  static String getMedicineInstruction({
    required MedicineType type,
    required String dosage,
  }) {
    switch (type) {
      case MedicineType.tablet:
      case MedicineType.capsule:
        return "Take $dosage with water";

      case MedicineType.injection:
        return "Use $dosage as prescribed";

      case MedicineType.spray:
        return "Use $dosage as directed";
    }
  }

  static List<DateTime> generateReminderDates({
    required DateTime start,
    required DateTime? end,
    required int intervalDays,
    int maxDaysAhead = 30, // default safety window
  }) {
    final List<DateTime> dates = [];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Normalize start
    DateTime current = DateTime(
      start.year,
      start.month,
      start.day,
    );

    // Determine effective end date
    final DateTime lastDate = end != null
        ? DateTime(end.year, end.month, end.day)
        : today.add(Duration(days: maxDaysAhead));

    // Safety guard
    if (intervalDays < 1) intervalDays = 1;

    while (!current.isAfter(lastDate)) {
      // Only future & today
      if (!current.isBefore(today)) {
        dates.add(current);
      }

      current = current.add(Duration(days: intervalDays));
    }

    return dates;
  }

  static TimeOfDay parseTimeString(String time) {
    // Case 1: 24-hour format → 20:30
    if (!time.contains('AM') && !time.contains('PM')) {
      final parts = time.split(':');

      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }

    // Case 2: 12-hour format → 8:30 PM
    final regExp = RegExp(r'(\d+):(\d+)\s*(AM|PM)');
    final match = regExp.firstMatch(time);

    if (match == null) {
      throw FormatException("Invalid time format: $time");
    }

    int hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final period = match.group(3)!;

    if (period == 'PM' && hour != 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;

    return TimeOfDay(hour: hour, minute: minute);
  }

}