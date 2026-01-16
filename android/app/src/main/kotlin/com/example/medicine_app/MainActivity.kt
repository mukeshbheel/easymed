package com.example.medicine_app

import android.content.Intent
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "system_settings"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {

                // 🔋 Battery optimization settings
                "openBatterySettings" -> {
                    try {
                        val intent =
                            Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
                        startActivity(intent)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("ERROR", "Cannot open battery settings", null)
                    }
                }

                // 🔔 Notification settings (Android 13+ correct way)
                "openNotificationSettings" -> {
                    try {
                        val intent = Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                        intent.putExtra(
                            Settings.EXTRA_APP_PACKAGE,
                            packageName
                        )
                        startActivity(intent)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("ERROR", "Cannot open notification settings", null)
                    }
                }

                // ⏰ Exact alarms / alarms & reminders
                "openExactAlarmSettings" -> {
                    try {
                        val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM)
                        startActivity(intent)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("ERROR", "Cannot open exact alarm settings", null)
                    }
                }

                "isBatteryOptimizationDisabled" -> {
                    val powerManager = getSystemService(POWER_SERVICE) as android.os.PowerManager
                    val isIgnoring =
                        powerManager.isIgnoringBatteryOptimizations(packageName)
                    result.success(isIgnoring)
                }


                else -> result.notImplemented()
            }
        }
    }
}
