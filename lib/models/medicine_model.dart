import 'package:hive/hive.dart';

import '../utils/medicine_type.dart';

part 'medicine_model.g.dart';

@HiveType(typeId: 0)
class MedicineModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String dosage; // e.g. "1 tablet"

  @HiveField(3)
  List<String> times; // ["08:00", "20:00"]

  @HiveField(4)
  DateTime startDate;

  @HiveField(5)
  DateTime? endDate;

  @HiveField(6)
  bool isActive;

  @HiveField(7)
  DateTime? lastTakenAt;

  @HiveField(8)
  MedicineType type;

  @HiveField(9)
  int repeatIntervalDays;

  @HiveField(10)
  List<int> notificationIds;

  MedicineModel({
    required this.id,
    required this.name,
    required this.dosage,
    required this.times,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    this.lastTakenAt,
    this.type = MedicineType.tablet,
    this.repeatIntervalDays = 1,
    this.notificationIds = const [],
  });
}
