import 'package:intl/intl.dart';

/// Display formatting. Everything the user reads as a number, a price or a
/// date goes through here so the app is consistent across screens.
class Formatters {
  const Formatters._();

  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final DateFormat _date = DateFormat('d MMM yyyy');
  static final DateFormat _dateTime = DateFormat('d MMM yyyy, h:mm a');

  static String currency(num? value) => _currency.format(value ?? 0);

  static String quantity(num? value) =>
      NumberFormat.decimalPattern('en_IN').format(value ?? 0);

  static String date(DateTime? value) =>
      value == null ? '—' : _date.format(value.toLocal());

  static String dateTime(DateTime? value) =>
      value == null ? '—' : _dateTime.format(value.toLocal());

  /// Parses the ISO strings Mongo hands back. Returns null rather than
  /// throwing, so one malformed field never takes down a list.
  static DateTime? parseDate(Object? value) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    return null;
  }

  static String initials(String? name) {
    final List<String> parts = (name ?? '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((String p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first._firstLetter().toUpperCase();
    return '${parts.first._firstLetter()}${parts.last._firstLetter()}'
        .toUpperCase();
  }
}

extension on String {
  String _firstLetter() => isEmpty ? '' : substring(0, 1);
}
