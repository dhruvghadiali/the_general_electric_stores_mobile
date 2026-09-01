import 'package:the_general_electric_stores_mobile/core/utils/formatters.dart';

/// A company as `GET /{role}/companies` returns it — a manufacturer, dealer or
/// customer the business buys from or sells to.
///
/// Addresses come nested, and each address carries its own contacts. That
/// shape is kept rather than flattened: a purchase order goes to one *address*
/// of a company, not to the company in the abstract.
class CompanyModel {
  const CompanyModel({
    required this.id,
    required this.name,
    this.type,
    this.email,
    this.phone,
    this.gstNumber,
    this.panNumber,
    this.website,
    this.isActive = true,
    this.addresses = const <CompanyAddress>[],
    this.createdAt,
  });

  final String id;
  final String name;

  /// `manufacturer`, `dealer`, `customer` — whatever the API's enum holds.
  final String? type;

  final String? email;
  final String? phone;
  final String? gstNumber;
  final String? panNumber;
  final String? website;
  final bool isActive;
  final List<CompanyAddress> addresses;
  final DateTime? createdAt;

  String get initials => Formatters.initials(name);

  /// What the dropdown shows under the name.
  String get subtitle {
    final List<String> parts = <String>[
      if (type != null && type!.isNotEmpty) type!,
      if (addresses.isNotEmpty) '${addresses.length} address'
          '${addresses.length == 1 ? '' : 'es'}',
    ];
    return parts.join(' · ');
  }

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    final Object? addresses = json['addresses'];

    return CompanyModel(
      id: '${json['_id'] ?? json['id'] ?? ''}',
      name: '${json['company_name'] ?? json['name'] ?? ''}',
      type: json['company_type']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone_number']?.toString() ?? json['phone']?.toString(),
      gstNumber: json['gst_number']?.toString(),
      panNumber: json['pan_number']?.toString(),
      website: json['website']?.toString(),
      isActive: json['is_active'] as bool? ?? true,
      addresses: addresses is List
          ? addresses
              .whereType<Map<String, dynamic>>()
              .map(CompanyAddress.fromJson)
              .toList(growable: false)
          : const <CompanyAddress>[],
      createdAt: Formatters.parseDate(json['created_at']),
    );
  }

  @override
  String toString() => 'CompanyModel($id, $name)';
}

class CompanyAddress {
  const CompanyAddress({
    required this.id,
    required this.address,
    this.pincode,
    this.isActive = true,
    this.contacts = const <CompanyContact>[],
  });

  final String id;
  final String address;

  /// Sent as a number in the payload, kept as a string: a pincode is an
  /// identifier, not a quantity, and leading zeroes matter in some regions.
  final String? pincode;

  final bool isActive;
  final List<CompanyContact> contacts;

  String get fullAddress =>
      pincode == null ? address : '$address — $pincode';

  factory CompanyAddress.fromJson(Map<String, dynamic> json) {
    final Object? contacts = json['contacts'];
    final Object? pincode = json['pincode'];

    return CompanyAddress(
      id: '${json['_id'] ?? json['id'] ?? ''}',
      address: '${json['address'] ?? ''}',
      pincode: pincode == null ? null : '$pincode',
      isActive: json['is_active'] as bool? ?? true,
      contacts: contacts is List
          ? contacts
              .whereType<Map<String, dynamic>>()
              .map(CompanyContact.fromJson)
              .toList(growable: false)
          : const <CompanyContact>[],
    );
  }
}

class CompanyContact {
  const CompanyContact({
    required this.id,
    required this.name,
    this.mobile,
    this.position,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String? mobile;

  /// `owner`, `manager`, `accounts` — the API's own enum.
  final String? position;

  final bool isActive;

  factory CompanyContact.fromJson(Map<String, dynamic> json) {
    return CompanyContact(
      id: '${json['_id'] ?? json['id'] ?? ''}',
      name: '${json['contact_person_name'] ?? ''}',
      mobile: json['contact_person_mobile_number']?.toString(),
      position: json['contact_person_position']?.toString(),
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}
