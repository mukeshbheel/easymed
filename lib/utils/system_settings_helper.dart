import 'package:flutter/services.dart';

class SystemSettingsHelper {
  static const _channel = MethodChannel('system_settings');

  static Future<void> openBatteryOptimizationSettings() async {
    await _channel.invokeMethod('openBatterySettings');
  }

  static Future<void> openNotificationSettings() async {
    await _channel.invokeMethod('openNotificationSettings');
  }

  static Future<void> openExactAlarmSettings() async {
    await _channel.invokeMethod('openExactAlarmSettings');
  }

  static Future<bool> isBatteryOptimizationDisabled() async {
    final bool? result =
    await _channel.invokeMethod('isBatteryOptimizationDisabled');
    return result ?? false;
  }
}
