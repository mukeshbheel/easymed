import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'app_colors.dart';

class AppToast {
  AppToast._();

  /// Success Toast
  static void showSuccess(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: AppColors.success,
      textColor: Colors.white,
      fontSize: 14,
    );
  }

  /// Error Toast
  static void showError(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: AppColors.error,
      textColor: Colors.white,
      fontSize: 14,
    );
  }

  /// Info Toast (Optional)
  static void showInfo(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 14,
    );
  }
}
