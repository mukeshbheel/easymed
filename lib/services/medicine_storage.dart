import 'package:hive/hive.dart';
import '../models/medicine_model.dart';

class MedicineStorage {
  static final Box<MedicineModel> _box =
  Hive.box<MedicineModel>('medicines');

  static List<MedicineModel> getAll() {
    return _box.values.toList();
  }

  static Future<void> add(MedicineModel medicine) async {
    await _box.put(medicine.id, medicine);
  }

  static Future<void> update(MedicineModel medicine) async {
    await medicine.save();
  }

  static Future<void> delete(String id) async {
    await _box.delete(id);
  }
}
