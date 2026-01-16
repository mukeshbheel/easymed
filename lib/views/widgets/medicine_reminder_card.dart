import 'package:flutter/material.dart';
import 'package:medicine_app/utils/global_functions.dart';
import '../../models/medicine_model.dart';

class MedicineReminderCard extends StatelessWidget {
  final MedicineModel medicine;
  final String time; // 🔑 specific reminder time

  const MedicineReminderCard({
    super.key,
    required this.medicine,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final timeText = _formatTime(time);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: getPastelColorFromId(medicine.id),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// LEFT CONTENT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timeText,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  medicine.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  GlobalFunctions.getMedicineInstruction(type: medicine.type, dosage: medicine.dosage),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          /// RIGHT ILLUSTRATION
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              // color: Colors.white.withOpacity(0.65),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Image.asset(
                GlobalFunctions.getMedicineTypeAsset(medicine.type),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- HELPERS ----------------

  Color getPastelColorFromId(String id) {
    final colors = PastelColors.lightColors;
    final index = id.hashCode.abs() % colors.length;
    return colors[index];
  }

  /// Converts "08:00" → "8:00 AM"
  String _formatTime(String time) {
    final parts = time.split(":");
    if (parts.length != 2) return time;

    int hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts[1];

    final period = hour >= 12 ? "PM" : "AM";
    hour = hour % 12 == 0 ? 12 : hour % 12;

    return "$hour:$minute $period";
  }
}

class PastelColors {
  static const List<Color> lightColors = [
    Color(0xFFE9EDFA), // very light blue
    Color(0xFFF9ECE6), // soft peach
    Color(0xFFF6E6F1), // light pink
    Color(0xFFF0F1F6), // pale lavender / grey
  ];
}
