// lib/utils/medicine_type.dart

import 'package:hive/hive.dart';

part 'medicine_type.g.dart';

@HiveType(typeId: 1)
enum MedicineType {
  @HiveField(0)
  tablet,

  @HiveField(1)
  injection,

  @HiveField(2)
  capsule,

  @HiveField(3)
  spray,
}
