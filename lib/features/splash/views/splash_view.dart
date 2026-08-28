import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/app/theme/app_dimens.dart';
import 'package:the_general_electric_stores_mobile/core/widgets/brand_logo.dart';
import 'package:the_general_electric_stores_mobile/features/splash/controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    // White, to match `launch_background` on Android and the iOS launch
    // storyboard — the native splash hands over to this one with no flash.
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const BrandLogo(
              maxWidth: 200,
              widthFactor: 0.55,
              heightFactor: 0.12,
            ),
            const SizedBox(height: AppDimens.xxl),
            SizedBox(
              height: AppDimens.iconMd,
              width: AppDimens.iconMd,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
