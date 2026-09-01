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

    // Every part of this is given a size on purpose.
    //
    // GetX builds the snackbar's own `Row` and `Column` from the bare `title`
    // and `message` strings, and it does so inside an overlay whose
    // constraints are not the screen's. A `Text` that is free to be as wide as
    // it likes then reports an intrinsic width in the tens of thousands of
    // pixels, and the flex around it overflows by that much:
    //
    //     A RenderFlex overflowed by 99633 pixels on the right.
    //
    // Passing `titleText` and `messageText` means GetX uses these widgets
    // instead of building its own, so the line limits and ellipsis below are
    // what bound the layout. The icon is boxed for the same reason — an
    // unsized `Icon` in that row is the other half of the problem.
    Get.snackbar(
      '',
      '',
      titleText: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      messageText: Text(
        message,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      icon: SizedBox(
        width: AppDimens.xxl,
        height: AppDimens.xxl,
        child: Icon(icon, color: Colors.white, size: AppDimens.iconLg),
      ),
      snackPosition: SnackPosition.BOTTOM,
      duration: AppConstants.snackBarDuration,
      margin: const EdgeInsets.all(AppDimens.lg),
      padding: const EdgeInsets.all(AppDimens.lg),
      borderRadius: AppDimens.radiusMd,
      backgroundColor: color,
      colorText: Colors.white,
      shouldIconPulse: false,
      isDismissible: true,
      maxWidth: _maxWidth,
    );
  }

  /// The snackbar never grows past this, whatever the overlay offers it.
  ///
  /// A width rather than no width: without one the snackbar inherits whatever
  /// the overlay hands down, which during a route transition is not the screen.
  static double? get _maxWidth {
    final double screen = Get.width;
    if (screen <= 0 || !screen.isFinite) return 400;
    return screen < 600 ? screen : 600;
  }
}
