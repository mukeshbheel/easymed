// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicine_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedicineModelAdapter extends TypeAdapter<MedicineModel> {
  @override
  final int typeId = 0;

  @override
  MedicineModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicineModel(
      id: fields[0] as String,
      name: fields[1] as String,
      dosage: fields[2] as String,
      times: (fields[3] as List).cast<String>(),
      startDate: fields[4] as DateTime,
      endDate: fields[5] as DateTime?,
      isActive: fields[6] as bool,
      lastTakenAt: fields[7] as DateTime?,
      type: fields[8] as MedicineType,
      repeatIntervalDays: fields[9] as int,
      notificationIds: (fields[10] as List).cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, MedicineModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.dosage)
      ..writeByte(3)
      ..write(obj.times)
      ..writeByte(4)
      ..write(obj.startDate)
      ..writeByte(5)
      ..write(obj.endDate)
      ..writeByte(6)
      ..write(obj.isActive)
      ..writeByte(7)
      ..write(obj.lastTakenAt)
      ..writeByte(8)
      ..write(obj.type)
      ..writeByte(9)
      ..write(obj.repeatIntervalDays)
      ..writeByte(10)
      ..write(obj.notificationIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
