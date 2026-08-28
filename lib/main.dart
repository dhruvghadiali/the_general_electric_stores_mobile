import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:the_general_electric_stores_mobile/app/app.dart';
import 'package:the_general_electric_stores_mobile/app/bindings/initial_binding.dart';
import 'package:the_general_electric_stores_mobile/core/config/env.dart';
import 'package:the_general_electric_stores_mobile/core/utils/logger.dart';

Future<void> main() async {
  // runZonedGuarded so an async error thrown outside the widget tree still
  // reaches the logger instead of vanishing into the console.
  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (FlutterErrorDetails details) {
        AppLogger.e(
          details.exceptionAsString(),
          details.exception,
          details.stack,
        );
      };

      await Env.load();
      await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      await InitialBinding.init();

      runApp(const GeneralElectricStoresApp());
    },
    (Object error, StackTrace stackTrace) =>
        AppLogger.e('Uncaught error', error, stackTrace),
  );
}
