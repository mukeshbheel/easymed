import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:medicine_app/utils/app_colors.dart';
import 'package:medicine_app/views/widgets/common_appbar.dart';
import 'package:medicine_app/views/widgets/manage_reminder_card.dart';

import '../models/medicine_model.dart';
import '../services/notification_service.dart';
import 'add_medicine_screen.dart';

class ManageRemindersScreen extends StatelessWidget {
  const ManageRemindersScreen({super.key});

  void _showActionSheet(BuildContext context, MedicineModel medicine) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // Small drag indicator
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                // EDIT
                ListTile(
                  title: Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                        color: Color(0xff32a7e1),
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Center(
                      child: const Text(
                        "Edit",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddMedicineScreen(
                          medicine: medicine,
                        ),
                      ),
                    );
                  },
                ),

                // DELETE
                ListTile(
                  title: Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Color(0xffe21c41),
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Center(
                      child: const Text(
                        "Delete",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);

                    final confirmed =
                    await _confirmDelete(context, medicine);

                    if (!confirmed) return;

                    // Cancel notifications
                    await NotificationService
                        .cancelMedicineNotifications(medicine);

                    // Delete from Hive
                    await medicine.delete();
                  },
                ),

                const SizedBox(height: 8),

                // CANCEL BUTTON (iOS style)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.black,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color(0xff7a71e5),
      body: Column(
        children: [
          CommonAppBar(
            title: "Manage Reminders",
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: AlignmentGeometry.topCenter, end: AlignmentGeometry.bottomCenter, colors: [Colors.white, AppColors.scaffoldBackground])
              ),
              child: ValueListenableBuilder(
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
                          GestureDetector(
                            onTap: () {
                              _showActionSheet(context, medicine);
                            },
                              child: ManageReminderCard(medicine: medicine),
                          ),

                          // ACTION MENU (TOP RIGHT)
                          if(false)
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
            ),
          ),
        ],
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
