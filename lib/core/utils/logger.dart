import 'package:logger/logger.dart';

import 'package:the_general_electric_stores_mobile/core/config/env.dart';

/// App-wide logger. `avoid_print` is on, so this is the only way anything is
/// written to the console — and in a production build nothing is.
class AppLogger {
  const AppLogger._();

  static final Logger _logger = Logger(
    filter: _EnvFilter(),
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 100,
      colors: true,
      printEmojis: false,
    ),
  );

  static void d(Object? message) => _logger.d(message);

  static void i(Object? message) => _logger.i(message);

  static void w(Object? message) => _logger.w(message);

  static void e(Object? message, [Object? error, StackTrace? stackTrace]) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
}

class _EnvFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) =>
      !Env.isProduction || event.level.index >= Level.warning.index;
}
