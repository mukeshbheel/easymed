import 'dart:io';
import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../utils/system_settings_helper.dart';

class PermissionGuideScreen extends StatefulWidget {
  const PermissionGuideScreen({super.key});

  @override
  State<PermissionGuideScreen> createState() =>
      _PermissionGuideScreenState();
}

class _PermissionGuideScreenState extends State<PermissionGuideScreen> {
  bool notificationsEnabled = false;
  bool exactAlarmsEnabled = false;
  bool batteryOptimizationDisabled = false;

  @override
  void initState() {
    super.initState();
    _loadStatuses();
  }

  Future<void> _loadStatuses() async {
    final notif =
    await NotificationService.isNotificationPermissionGranted();
    final exact =
    await NotificationService.isExactAlarmPermissionGranted();
    final battery = Platform.isAndroid
        ? await SystemSettingsHelper
        .isBatteryOptimizationDisabled()
        : true;

    setState(() {
      notificationsEnabled = notif;
      exactAlarmsEnabled = exact;
      batteryOptimizationDisabled = battery;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _PermissionHeader(),

              const SizedBox(height: 24),

              Text(
                "For reliable medicine reminders, please ensure the following settings are enabled.",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                ),
              ),

              const SizedBox(height: 20),

              _PermissionCard(
                title: "Notifications",
                subtitle: "Required to show reminders",
                enabled: notificationsEnabled,
                onTap: () async {
                  await SystemSettingsHelper
                      .openNotificationSettings();
                  _loadStatuses();
                },
              ),

              _PermissionCard(
                title: "Exact alarms",
                subtitle: "Ensures reminders trigger on time",
                enabled: exactAlarmsEnabled,
                onTap: () async {
                  await SystemSettingsHelper
                      .openExactAlarmSettings();
                  _loadStatuses();
                },
              ),

              if (Platform.isAndroid)
                _PermissionCard(
                  title: "Battery optimization",
                  subtitle: "Disable to prevent missed reminders",
                  enabled: batteryOptimizationDisabled,
                  warning: true,
                  onTap: () async {
                    await SystemSettingsHelper
                        .openBatteryOptimizationSettings();
                    _loadStatuses();
                  },
                ),

              const Spacer(),

              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          primary,
                          primary.withOpacity(0.85),
                        ],
                      ),
                    ),
                    child: const Text(
                      "Done",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ---------- UI Components ---------- */

class _PermissionHeader extends StatelessWidget {
  const _PermissionHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6A5AE0), Color(0xFF8E7BFF)],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.security_outlined,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Important setup",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "One-time configuration",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PermissionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool enabled;
  final bool warning;
  final VoidCallback onTap;

  const _PermissionCard({
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.onTap,
    this.warning = false,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (enabled) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = "Enabled";
    } else if (warning) {
      statusColor = Colors.orange;
      statusIcon = Icons.info;
      statusText = "Recommended";
    } else {
      statusColor = Colors.red;
      statusIcon = Icons.error;
      statusText = "Required";
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(statusIcon, color: statusColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
