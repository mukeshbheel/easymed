import 'package:flutter/material.dart';
import '../../models/medicine_model.dart';

class ManageReminderCard extends StatelessWidget {
  final MedicineModel medicine;

  const ManageReminderCard({
    super.key,
    required this.medicine,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _getPastelColorFromId(medicine.id),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER ROW (TITLE + ICON)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  medicine.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              if(false)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.medication_outlined,
                  size: 20,
                  color: Colors.black54,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          /// DESCRIPTION
          Text(
            "Take ${medicine.dosage} with water",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              height: 1.45,
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 14),

          /// TIMES
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: medicine.times.map((t) {
              return _TimeChip(label: _formatTime(t));
            }).toList(),
          ),

          const SizedBox(height: 14),

          /// DATE RANGE
          Row(
            children: [
              _DateInfo(
                label: "Start",
                value: _formatDate(medicine.startDate),
              ),
              const SizedBox(width: 16),
              _DateInfo(
                label: "End",
                value: medicine.endDate != null
                    ? _formatDate(medicine.endDate!)
                    : "No end date",
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- HELPERS ----------------

  Color _getPastelColorFromId(String id) {
    final colors = PastelColors.lightColors;
    final index = id.hashCode.abs() % colors.length;
    return colors[index];
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
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

/// SMALL COMPONENTS (keep visual consistency)

class _TimeChip extends StatelessWidget {
  final String label;

  const _TimeChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.65),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }
}

class _DateInfo extends StatelessWidget {
  final String label;
  final String value;

  const _DateInfo({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.black45,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class PastelColors {
  static const List<Color> lightColors = [
    Color(0xFFE9EDFA),
    Color(0xFFF9ECE6),
    Color(0xFFF6E6F1),
    Color(0xFFF0F1F6),
  ];
}
