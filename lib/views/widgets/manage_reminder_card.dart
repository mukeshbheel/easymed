import 'package:flutter/material.dart';
import 'package:medicine_app/utils/global_functions.dart';
import 'package:medicine_app/utils/string_extension.dart';
import '../../models/medicine_model.dart';

class ManageReminderCard extends StatelessWidget {
  final MedicineModel medicine;

  const ManageReminderCard({super.key, required this.medicine});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            offset: const Offset(0, 8),
            color: Colors.black.withOpacity(0.08),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// CHECK INDICATOR
          // Container(
          //   width: 44,
          //   height: 44,
          //   decoration: BoxDecoration(
          //     shape: BoxShape.circle,
          //     color: Colors.deepPurple.withOpacity(.12),
          //   ),
          //   child: const Icon(
          //     Icons.check_rounded,
          //     color: Colors.deepPurple,
          //     size: 22,
          //   ),
          // ),
          //
          // const SizedBox(width: 14),

          /// TEXT CONTENT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// MEDICINE NAME
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medicine.name.capitalizeFirst(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 4),

                        /// TIME + DOSAGE
                        Text(
                          "${GlobalFunctions.formatTime(medicine.times.first)} • ${medicine.dosage} ${GlobalFunctions.getMedicineTypeName(type: medicine.type)}"
                              .toLowerCase(),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),

                    /// CAPSULE UI
                    Image.asset(
                      GlobalFunctions.getMedicineTypeAsset(medicine.type),
                      width: 70,
                    ),
                    // Container(
                    //   width: 64,
                    //   height: 30,
                    //   decoration: BoxDecoration(
                    //     border: Border.all(color: Colors.grey),
                    //     borderRadius: BorderRadius.circular(20),
                    //     gradient: const LinearGradient(
                    //       colors: [
                    //         Colors.blue,
                    //         Color(0xFFC7C4FF),
                    //       ],
                    //     ),
                    //   ),
                    //   child: Row(
                    //     children: [
                    //       Expanded(
                    //         child: Container(
                    //           decoration: const BoxDecoration(
                    //             color: Colors.white,
                    //             borderRadius: BorderRadius.only(
                    //               topLeft: Radius.circular(20),
                    //               bottomLeft: Radius.circular(20),
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //       const Expanded(child: SizedBox()),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),

                const SizedBox(height: 10),

                Text(
                  medicine.endDate != null
                      ? "${_formatDateShort(medicine.startDate)} → ${_formatDateShort(medicine.endDate!)}"
                      : "From ${_formatDateShort(medicine.startDate)}",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  _getRepeatText(medicine.repeatIntervalDays),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 10),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: medicine.times
                      .map((time) => TimeCapsule(time: time))
                      .toList(),
                ),

                const SizedBox(height: 10),

                /// PROGRESS DOTS
                // Row(
                //   children: List.generate(
                //     7,
                //         (index) => Container(
                //       margin: const EdgeInsets.only(right: 6),
                //       width: 6,
                //       height: 6,
                //       decoration: BoxDecoration(
                //         shape: BoxShape.circle,
                //         color: index < 4
                //             ? Colors.deepPurple
                //             : Colors.deepPurple.withOpacity(.25),
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),

          const SizedBox(width: 12),
        ],
      ),
    );
  }

  // ---------------- HELPERS ----------------

  String _formatDateShort(DateTime date) {
    return "${date.day}/${date.month}";
  }

  String _getRepeatText(int days) {
    if (days == 1) return "Daily";
    return "Every $days days";
  }
}

class TimeCapsule extends StatelessWidget {
  final String time;

  const TimeCapsule({super.key, required this.time});

  @override
  Widget build(BuildContext context) {
    final hour = int.tryParse(time.split(":")[0]) ?? 0;

    late List<Color> gradient;
    late IconData icon;

    if (hour >= 5 && hour < 12) {
      gradient = [Color(0xFFFFD54F), Color(0xFFFFF3C2)];
      icon = Icons.wb_sunny_rounded;
    } else if (hour >= 12 && hour < 17) {
      gradient = [Color(0xFF42A5F5), Color(0xFFBBDEFB)];
      icon = Icons.light_mode_rounded;
    } else if (hour >= 17 && hour < 21) {
      gradient = [Color(0xFFFF8A65), Color(0xFFFFCCBC)];
      icon = Icons.wb_twilight_rounded;
    } else {
      gradient = [Color(0xFF5C6BC0), Color(0xFFC5CAE9)];
      icon = Icons.nights_stay_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            offset: const Offset(0, 3),
            color: Colors.black.withOpacity(.08),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            GlobalFunctions.formatTime(time),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
