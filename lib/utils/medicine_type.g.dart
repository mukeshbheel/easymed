// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicine_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedicineTypeAdapter extends TypeAdapter<MedicineType> {
  @override
  final int typeId = 1;

  @override
  MedicineType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MedicineType.tablet;
      case 1:
        return MedicineType.injection;
      case 2:
        return MedicineType.capsule;
      case 3:
        return MedicineType.spray;
      default:
        return MedicineType.tablet;
    }
  }

  @override
  void write(BinaryWriter writer, MedicineType obj) {
    switch (obj) {
      case MedicineType.tablet:
        writer.writeByte(0);
        break;
      case MedicineType.injection:
        writer.writeByte(1);
        break;
      case MedicineType.capsule:
        writer.writeByte(2);
        break;
      case MedicineType.spray:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
