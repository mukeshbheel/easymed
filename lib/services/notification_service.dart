import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/medicine_model.dart';
import '../utils/global_functions.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.local);

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Android 13+ notification permission (one-time)
    await _requestNotificationPermission();

    // Android 12+ exact alarm permission
    await _requestExactAlarmPermission();
  }

  // ======================
  // PERMISSION REQUESTS
  // ======================

  static Future<void> _requestNotificationPermission() async {
    final androidPlugin =
    _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

    final bool? granted =
    await androidPlugin.requestNotificationsPermission();

    debugPrint("Notification permission granted: $granted");
  }

  static Future<void> _requestExactAlarmPermission() async {
    final androidPlugin =
    _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

    final bool? canSchedule =
    await androidPlugin.canScheduleExactNotifications();

    if (canSchedule != true) {
      await androidPlugin.requestExactAlarmsPermission();
    }
  }

  // ======================
  // STATUS CHECKS (UX2)
  // ======================

  /// Android 13+ notification permission
  static Future<bool> isNotificationPermissionGranted() async {
    if (!Platform.isAndroid) return true;

    final androidPlugin =
    _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return false;

    final bool? enabled =
    await androidPlugin.areNotificationsEnabled();

    return enabled ?? false;
  }

  /// Android 12+ exact alarm permission
  static Future<bool> isExactAlarmPermissionGranted() async {
    if (!Platform.isAndroid) return true;

    final androidPlugin =
    _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return false;

    final bool? canSchedule =
    await androidPlugin.canScheduleExactNotifications();

    return canSchedule == true;
  }

  // ======================
  // NOTIFICATION SCHEDULING
  // ======================

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
    required String medicineId,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(dateTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'medicine_channel',
          'Medicine Reminders',
          channelDescription: 'Medicine reminder notifications',
          importance: Importance.max,
          priority: Priority.high,
          actions: const [
            AndroidNotificationAction(
              'TAKEN',
              'Taken',
              showsUserInterface: true,
            ),
            AndroidNotificationAction(
              'SNOOZE',
              'Snooze 10 min',
              showsUserInterface: true,
            ),
          ],
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      payload: medicineId, // 🔴 important
    );
  }

  static Future<void> _onNotificationResponse(
      NotificationResponse response) async {
    debugPrint("Action tapped: ${response.actionId}");

    final actionId = response.actionId;
    final medicineId = response.payload;

    if (medicineId == null) return;

    if (actionId == 'TAKEN') {
      await _handleTaken(medicineId);
    } else if (actionId == 'SNOOZE') {
      await _handleSnooze(medicineId);
    }
  }

  static Future<void> _handleTaken(String medicineId) async {
    final box = Hive.box<MedicineModel>('medicines');
    final medicine = box.get(medicineId);

    if (medicine == null) return;

    medicine.lastTakenAt = DateTime.now();
    await medicine.save();

    debugPrint("Medicine marked as taken: ${medicine.name}");
  }

  static Future<void> _handleSnooze(String medicineId) async {
    final box = Hive.box<MedicineModel>('medicines');
    final medicine = box.get(medicineId);

    if (medicine == null) return;

    final snoozeTime = DateTime.now().add(const Duration(minutes: 10));

    await scheduleNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: "Medicine Reminder (Snoozed)",
      body: "${medicine.name} • ${medicine.dosage}",
      dateTime: snoozeTime,
      medicineId: medicine.id,
    );

    debugPrint("Medicine snoozed: ${medicine.name}");
  }

  static Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  static Future<void> cancelMedicineNotifications(
      MedicineModel medicine) async {

    for (final id in medicine.notificationIds) {
      await _plugin.cancel(id);
    }

    medicine.notificationIds.clear();
    await medicine.save();
  }
  static Future<void> autoRescheduleAll() async {
    final box = Hive.box<MedicineModel>('medicines');
    final medicines = box.values.where((m) => m.isActive).toList();

    debugPrint("Auto rescheduling ${medicines.length} medicines");

    for (final medicine in medicines) {

      await cancelMedicineNotifications(medicine);

      final reminderDates = GlobalFunctions.generateReminderDates(
        start: medicine.startDate,
        end: medicine.endDate,
        intervalDays: medicine.repeatIntervalDays,
        maxDaysAhead: 30,
      );

      medicine.notificationIds.clear();

      for (final date in reminderDates) {
        for (final timeStr in medicine.times) {

          final parsed = GlobalFunctions.parseTimeString(timeStr);

          final scheduledDate = DateTime(
            date.year,
            date.month,
            date.day,
            parsed.hour,
            parsed.minute,
          );

          if (scheduledDate.isBefore(DateTime.now())) continue;

          final notificationId =
              '${medicine.id}_${scheduledDate.millisecondsSinceEpoch}'.hashCode;

          await scheduleNotification(
            id: notificationId,
            title: "Medicine Reminder",
            body: "${medicine.name} • ${medicine.dosage}",
            dateTime: scheduledDate,
            medicineId: medicine.id,
          );

          medicine.notificationIds.add(notificationId);
        }
      }

      await medicine.save();
    }
  }


}
