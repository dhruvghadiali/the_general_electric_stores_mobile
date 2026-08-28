/// Whatever the role's `/dashboard` endpoint hands back, read as a bag of
/// counts.
///
/// Each role's dashboard shows different figures, and the API for them is not
/// confirmed yet, so this deliberately does not hard-code a field list: it
/// keeps the numeric members it was given and lets each role's controller ask
/// for the ones it cares about. A key the server stops sending shows as a dash
/// rather than a crash.
class DashboardSummary {
  const DashboardSummary(this.values);

  final Map<String, num> values;

  static const DashboardSummary empty = DashboardSummary(<String, num>{});

  bool get isEmpty => values.isEmpty;

  /// First matching key wins, so a controller can name the API's key and a
  /// fallback in one call.
  num? read(List<String> keys) {
    for (final String key in keys) {
      final num? value = values[key];
      if (value != null) return value;
    }
    return null;
  }

  factory DashboardSummary.fromData(Object? data) {
    final Map<String, num> flat = <String, num>{};

    void walk(Object? node, String prefix) {
      if (node is! Map) return;
      node.forEach((Object? key, Object? value) {
        final String name = prefix.isEmpty ? '$key' : '${prefix}_$key';
        if (value is num) {
          flat[name] = value;
        } else if (value is String) {
          final num? parsed = num.tryParse(value);
          if (parsed != null) flat[name] = parsed;
        } else if (value is Map) {
          // One level of nesting: { "products": { "total": 12 } }.
          walk(value, name);
        }
      });
    }

    if (data is List && data.isNotEmpty) {
      walk(data.first, '');
    } else {
      walk(data, '');
    }

    return DashboardSummary(flat);
  }
}
