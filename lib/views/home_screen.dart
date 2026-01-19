import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:medicine_app/utils/app_colors.dart';
import 'package:medicine_app/views/permission_guide_screen.dart';
import 'package:medicine_app/views/widgets/greeting_header.dart';
import 'package:medicine_app/views/widgets/home_bottom_bar.dart';
import 'package:medicine_app/views/widgets/medicine_reminder_card.dart';
import 'package:medicine_app/views/widgets/medicine_tile.dart';
import 'package:medicine_app/views/widgets/next_medicine_card.dart';
import '../models/medicine_model.dart';
import '../services/notification_service.dart';
import 'add_medicine_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const PermissionGuideScreen(),
        ),
      );
    });
  }

  Future<void> goToAddMedicine() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddMedicineScreen()),
    );
    // ❌ no manual refresh needed
  }

  Future<void> deleteMedicine(MedicineModel medicine) async {
    // 1️⃣ Cancel notifications
    await NotificationService.cancelMedicineNotifications(medicine);

    // 2️⃣ Delete from Hive
    await medicine.delete();
    // ❌ no manual refresh needed
  }

  void _showBottomSheet(BuildContext context, MedicineModel medicine) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text("Edit"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AddMedicineScreen(medicine: medicine),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text("Delete"),
              onTap: () async {
                Navigator.pop(context);
                await deleteMedicine(medicine);
              },
            ),
          ],
        ),
      ),
    );
  }

  List<_ReminderInstance> _buildUpcomingReminders(
      List<MedicineModel> medicines,
      int daysAhead,
      ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final List<_ReminderInstance> reminders = [];

    for (final medicine in medicines) {
      final startDate = DateTime(
        medicine.startDate.year,
        medicine.startDate.month,
        medicine.startDate.day,
      );

      final endDate = medicine.endDate != null
          ? DateTime(
        medicine.endDate!.year,
        medicine.endDate!.month,
        medicine.endDate!.day,
      )
          : null;

      // SAFETY: prevent zero/invalid repeat interval
      final repeatDays =
      medicine.repeatIntervalDays < 1 ? 1 : medicine.repeatIntervalDays;

      for (final t in medicine.times) {
        final parts = t.split(':');
        if (parts.length != 2) continue;

        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour == null || minute == null) continue;

        for (int d = 0; d <= daysAhead; d++) {
          final date = today.add(Duration(days: d));

          // Date window filters
          if (date.isBefore(startDate)) continue;
          if (endDate != null && date.isAfter(endDate)) continue;

          // Repeat logic
          final daysFromStart =
              date.difference(startDate).inDays;

          if (daysFromStart % repeatDays != 0) continue;

          // SAFE DateTime creation
          final reminderTime = DateTime(
            date.year,
            date.month,
            date.day,
            hour,
            minute,
          );

          // Correct "today" comparison
          final isToday =
              date.year == today.year &&
                  date.month == today.month &&
                  date.day == today.day;

          // Skip only passed reminders of today
          if (isToday && reminderTime.isBefore(now)) continue;

          reminders.add(
            _ReminderInstance(
              medicine: medicine,
              dateTime: reminderTime,
              timeLabel: t,
            ),
          );
        }
      }
    }

    reminders.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return reminders;
  }

  Map<DateTime, List<_ReminderInstance>> _groupByDay(
      List<_ReminderInstance> reminders,
      ) {
    final Map<DateTime, List<_ReminderInstance>> grouped = {};

    for (final r in reminders) {
      final day =
      DateTime(r.dateTime.year, r.dateTime.month, r.dateTime.day);

      grouped.putIfAbsent(day, () => []).add(r);
    }

    return grouped;
  }

  String _dayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return "Today";
    }

    if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return "Tomorrow";
    }

    return "${_weekday(date.weekday)}, ${date.day} ${_month(date.month)}";
  }

  String _month(int m) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
    ];
    return months[m - 1];
  }

  String _weekday(int w) {
    const days = [
      "Mon",
      "Tue",
      "Wed",
      "Thu",
      "Fri",
      "Sat",
      "Sun"
    ];
    return days[w - 1];
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      // floatingActionButton: _PrimaryFab(onTap: goToAddMedicine),

      bottomNavigationBar: HomeBottomBar(
        onAddTap: goToAddMedicine,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: GreetingHeader(),
              ),
          
              ValueListenableBuilder(
                valueListenable:
                Hive.box<MedicineModel>('medicines').listenable(),
                builder: (context, Box<MedicineModel> box, _) {
                  final medicines =
                  box.values.where((m) => m.isActive).toList();

                  final now = DateTime.now();
                  final today = DateTime(now.year, now.month, now.day);

                  int daysAhead = 30; // default for no end date

                  final medicinesWithEndDate =
                  medicines.where((m) => m.endDate != null).toList();

                  if (medicinesWithEndDate.isNotEmpty) {
                    final latestEndDate = medicinesWithEndDate
                        .map((m) => m.endDate!)
                        .reduce((a, b) => a.isAfter(b) ? a : b);

                    final diff = latestEndDate
                        .difference(today)
                        .inDays;

                    daysAhead = diff.clamp(0, 30);
                  }

                  final reminders = _buildUpcomingReminders(medicines, daysAhead);

                  final grouped = _groupByDay(reminders);

                  if (reminders.isEmpty) {
                    return _EmptyState();
                  }

                  final nextReminder = reminders.first;
                  final otherReminders = reminders.skip(1).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔹 NEXT MEDICINE CARD (RESTORED)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: NextMedicineCard(
                          medicine: nextReminder.medicine,
                          reminderTime: nextReminder.dateTime,
                        ),
                      ),

                      // 🔹 GROUPED UPCOMING REMINDERS
                      ...grouped.entries.map((entry) {
                        final day = entry.key;
                        final items = entry.value;
                        final label = _dayLabel(day);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                              child: Text(
                                label,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            ...items.map(
                                  (r) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            AddMedicineScreen(medicine: r.medicine),
                                      ),
                                    );
                                  },
                                  child: MedicineReminderCardHome(
                                    medicine: r.medicine,
                                    time: r.timeLabel,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  );

                },
              ),
            ],
          ),
        ),
      ),

    );
  }

}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.medication_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "No medicines added",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Add your medicines to get timely reminders",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReminderInstance {
  final MedicineModel medicine;
  final DateTime dateTime;
  final String timeLabel;

  _ReminderInstance({
    required this.medicine,
    required this.dateTime,
    required this.timeLabel,
  });
}
