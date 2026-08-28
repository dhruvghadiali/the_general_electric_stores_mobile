/// Client-side form validation.
///
/// These exist so a user is told about an empty field without a round trip —
/// they are not the source of truth. The API re-validates everything through
/// Joi and the Mongoose schema, and a server message always wins over one of
/// these when the two disagree.
class Validators {
  const Validators._();

  static String? required(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$field is required.';
    return null;
  }

  static String? username(String? value) {
    final String? empty = required(value, field: 'Username');
    if (empty != null) return empty;
    final String trimmed = value!.trim();
    if (trimmed.length < 3) {
      return 'Username must be at least 3 characters.';
    }
    if (trimmed.contains(RegExp(r'\s'))) {
      return 'Username cannot contain spaces.';
    }
    return null;
  }

}
