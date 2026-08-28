import 'package:the_general_electric_stores_mobile/core/utils/formatters.dart';

/// A contact as the API returns it — a customer, supplier or dealer.
///
/// Every field is read defensively: a directory must not blow up because one
/// row is missing a phone number.
class ContactModel {
  const ContactModel({
    required this.id,
    required this.name,
    this.company,
    this.type,
    this.email,
    this.phone,
    this.city,
    this.state,
    this.isActive = true,
    this.createdAt,
  });

  final String id;
  final String name;
  final String? company;

  /// `customer`, `supplier`, `dealer` — whatever the API's enum holds.
  final String? type;

  final String? email;
  final String? phone;
  final String? city;
  final String? state;
  final bool isActive;
  final DateTime? createdAt;

  String get initials => Formatters.initials(name);

  String get location =>
      <String?>[city, state].whereType<String>().join(', ');

  String get subtitle {
    final List<String> parts = <String>[
      if (company != null && company!.isNotEmpty) company!,
      if (phone != null && phone!.isNotEmpty) phone!,
    ];
    return parts.isEmpty ? (email ?? '—') : parts.join(' · ');
  }

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    final String first = '${json['first_name'] ?? ''}'.trim();
    final String last = '${json['last_name'] ?? ''}'.trim();
    final String composed = '$first $last'.trim();

    return ContactModel(
      id: '${json['_id'] ?? json['id'] ?? ''}',
      name: composed.isNotEmpty
          ? composed
          : '${json['name'] ?? json['contact_name'] ?? ''}',
      company: json['company']?.toString() ?? json['company_name']?.toString(),
      type: json['type']?.toString() ?? json['contact_type']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString() ?? json['mobile']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: Formatters.parseDate(json['created_at'] ?? json['createdAt']),
    );
  }

  @override
  String toString() => 'ContactModel($id, $name)';
}
