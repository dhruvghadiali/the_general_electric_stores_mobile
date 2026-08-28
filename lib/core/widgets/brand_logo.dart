import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:the_general_electric_stores_mobile/core/constants/app_assets.dart';
import 'package:the_general_electric_stores_mobile/core/constants/app_constants.dart';

/// The logo, sized to the space it is given.
///
/// The mark is wide (493×283, roughly 1.74:1), so a fixed width that looks
/// right on a 6.7" phone is overbearing on a 5.4" one and absurd in landscape.
/// Three limits apply and the smallest wins:
///
///  * a fraction of the width actually available to the widget,
///  * a fraction of the screen *height*, which is what saves landscape and
///    short screens — a wide logo eats vertical space fastest,
///  * a hard ceiling, so it never balloons on a tablet.
class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.maxWidth = 200,
    this.widthFactor = 0.5,
    this.heightFactor = 0.12,
  });

  /// Never wider than this, however much room there is.
  final double maxWidth;

  /// Share of the available width the logo may take.
  final double widthFactor;

  /// Share of the screen height the logo may take.
  final double heightFactor;

  /// Width ÷ height of `assets/images/logo.png`.
  static const double _aspect = 493 / 283;

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.sizeOf(context);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // An unbounded parent (a scrolling Column, say) reports infinity —
        // fall back to the screen rather than multiplying by it.
        final double available =
            constraints.maxWidth.isFinite && constraints.maxWidth > 0
                ? constraints.maxWidth
                : screen.width;

        final double width = math.min(
          math.min(available * widthFactor, maxWidth),
          screen.height * heightFactor * _aspect,
        );

        return Center(
          child: Image.asset(
            AppAssets.logo,
            width: width,
            fit: BoxFit.contain,
            semanticLabel: AppConstants.appName,
          ),
        );
      },
    );
  }
}
