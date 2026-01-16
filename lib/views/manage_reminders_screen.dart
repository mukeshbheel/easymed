import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:medicine_app/views/widgets/manage_reminder_card.dart';

import '../models/medicine_model.dart';
import '../services/notification_service.dart';
import 'add_medicine_screen.dart';

class ManageRemindersScreen extends StatelessWidget {
  const ManageRemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Manage Reminders", style: TextStyle(color: Colors.black),),
      ),
      body: ValueListenableBuilder(
        valueListenable:
        Hive.box<MedicineModel>('medicines').listenable(),
        builder: (context, Box<MedicineModel> box, _) {
          final medicines = box.values.toList();

          if (medicines.isEmpty) {
            return const Center(
              child: Text("No medicines added"),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: medicines.length,
            itemBuilder: (_, index) {
              final medicine = medicines[index];

              return Stack(
                children: [
                  ManageReminderCard(medicine: medicine),

                  // ACTION MENU (TOP RIGHT)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: PopupMenuButton<String>(
                      color: Colors.white,
                      icon: const Icon(
                        Icons.more_vert,
                        color: Colors.black54,
                      ),
                      onSelected: (value) async {
                        if (value == 'edit') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddMedicineScreen(medicine: medicine),
                            ),
                          );
                        }
                        else if (value == 'delete') {
                          final confirmed = await _confirmDelete(context, medicine);
                          if (!confirmed) return;

                          // ✅ 1️⃣ Cancel all scheduled notifications
                          await NotificationService.cancelMedicineNotifications(medicine);

                          // ✅ 2️⃣ Delete medicine from Hive
                          await medicine.delete();
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text("Edit"),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            "Delete",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<bool> _confirmDelete(
      BuildContext context,
      MedicineModel medicine,
      ) async {
    return await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Delete medicine?"),
        content: Text(
          "Are you sure you want to delete '${medicine.name}'?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    ) ??
        false;
  }
}
