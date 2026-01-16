import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/medicine_model.dart';

class NextMedicineCard extends StatelessWidget {
  final MedicineModel medicine;
  final DateTime reminderTime;

  const NextMedicineCard({
    super.key,
    required this.medicine,
    required this.reminderTime,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream: _minuteTicker(),
      builder: (context, snapshot) {
        final now = snapshot.data ?? DateTime.now();
        final diff = reminderTime.difference(now);

        final minutesLeft = diff.inMinutes.clamp(0, 9999);
        final timeLabel = _formatTime(reminderTime);
        final countdownLabel = _formatCountdown(minutesLeft);

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF5B4B8A),
                Color(0xFF6E5AAE),
              ],
            ),
          ),
          child: Row(
            children: [
              /// LEFT CONTENT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      timeLabel,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Next medicine in\n$countdownLabel",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Take ${medicine.name}\n${medicine.dosage}",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              /// RIGHT PILL
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 🔁 Emits current time every minute
  Stream<DateTime> _minuteTicker() async* {
    while (true) {
      yield DateTime.now();
      await Future.delayed(const Duration(minutes: 1));
    }
  }

  // ---------------- HELPERS ----------------

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _formatCountdown(int minutes) {
    if (minutes <= 0) return 'now';
    if (minutes == 1) return '1 min';
    if (minutes < 60) return '$minutes mins';

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (remainingMinutes == 0) {
      return '$hours hr';
    }
    return '$hours hr $remainingMinutes min';
  }
}
