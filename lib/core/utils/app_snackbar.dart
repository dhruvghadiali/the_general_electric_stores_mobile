import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/app/theme/app_colors.dart';
import 'package:the_general_electric_stores_mobile/app/theme/app_dimens.dart';
import 'package:the_general_electric_stores_mobile/core/constants/app_constants.dart';

/// The app's one way of saying something went right or wrong.
///
/// Controllers call these with the message the API returned; they never build
/// a `SnackBar` themselves, so tone and placement stay the same everywhere.
class AppSnackbar {
  const AppSnackbar._();

  static void success(String message, {String title = 'Done'}) =>
      _show(title, message, AppColors.success, Icons.check_circle_outline);

  static void error(String message, {String title = 'Something went wrong'}) =>
      _show(title, message, AppColors.error, Icons.error_outline);

  static void info(String message, {String title = 'Heads up'}) =>
      _show(title, message, AppColors.info, Icons.info_outline);

  static void warning(String message, {String title = 'Careful'}) =>
      _show(title, message, AppColors.warning, Icons.warning_amber_outlined);

  static void _show(
    String title,
    String message,
    Color color,
    IconData icon,
  ) {
    if (message.trim().isEmpty) return;
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: AppConstants.snackBarDuration,
      margin: const EdgeInsets.all(AppDimens.lg),
      borderRadius: AppDimens.radiusMd,
      backgroundColor: color,
      colorText: Colors.white,
      icon: Icon(icon, color: Colors.white),
      shouldIconPulse: false,
      isDismissible: true,
    );
  }
}
