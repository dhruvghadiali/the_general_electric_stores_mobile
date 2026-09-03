/// One row of a company dropdown: the id to send back, and the name to show.
///
/// Deliberately not [CompanyModel]. A picker needs two fields; the list
/// endpoint returns the whole company — addresses, their contacts, GST and PAN,
/// timestamps — and parsing that tree per row builds an object graph whose only
/// destination is the garbage collector. Reading just what the control uses
/// also means a change to the address or contact shape cannot break a dropdown
/// that never looked at them.
///
/// `id` and `_id` are the same value in this API; `id` is preferred and `_id`
/// is the fallback, so a row that carries only one of them still resolves.
class CompanyOption {
  const CompanyOption({required this.id, required this.name});

  factory CompanyOption.fromJson(Map<String, dynamic> json) {
    return CompanyOption(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      name: json['company_name']?.toString() ?? '',
    );
  }

  final String id;
  final String name;

  /// A row with no id cannot be selected — nothing could be sent for it.
  bool get isSelectable => id.isNotEmpty;

  /// Identity is the id, not the object.
  ///
  /// `DropdownButtonFormField` asserts that its `value` matches exactly one
  /// item, and it compares with `==`. Reloading the list rebuilds every row, so
  /// without this a refresh with a selection already made would throw rather
  /// than keep the selection.
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is CompanyOption && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'CompanyOption($id, $name)';
}
