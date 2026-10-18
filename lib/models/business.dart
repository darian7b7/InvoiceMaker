class Business {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String country;
  final String? logoPath;
  final String? website;

  /// Steuernummer or USt-IdNr. — required on German invoices (§14 UStG).
  final String? taxId;

  /// Kleinunternehmer (§19 UStG): no VAT is charged or shown.
  final bool isKleinunternehmer;
  final String? bankName;
  final String? iban;
  final String? bic;
  final String invoicePrefix;
  final int invoiceCounter;
  final DateTime createdAt;
  final DateTime updatedAt;

  Business({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.country,
    this.logoPath,
    this.website,
    this.taxId,
    this.isKleinunternehmer = false,
    this.bankName,
    this.iban,
    this.bic,
    this.invoicePrefix = 'RE',
    this.invoiceCounter = 1000,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'country': country,
      'logoPath': logoPath,
      'website': website,
      'taxId': taxId,
      'isKleinunternehmer': isKleinunternehmer,
      'bankName': bankName,
      'iban': iban,
      'bic': bic,
      'invoicePrefix': invoicePrefix,
      'invoiceCounter': invoiceCounter,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      city: json['city'],
      country: json['country'],
      logoPath: json['logoPath'],
      website: json['website'],
      taxId: json['taxId'],
      isKleinunternehmer: json['isKleinunternehmer'] ?? false,
      bankName: json['bankName'],
      iban: json['iban'],
      bic: json['bic'],
      invoicePrefix: json['invoicePrefix'] ?? 'RE',
      invoiceCounter: json['invoiceCounter'] ?? 1000,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// Optional text fields are replaced as given (pass null to clear them),
  /// so edit forms can remove a value such as the logo or IBAN.
  Business copyWithDetails({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String city,
    required String country,
    required String? logoPath,
    required String? website,
    required String? taxId,
    required bool isKleinunternehmer,
    required String? bankName,
    required String? iban,
    required String? bic,
  }) {
    return Business(
      id: id,
      name: name,
      email: email,
      phone: phone,
      address: address,
      city: city,
      country: country,
      logoPath: logoPath,
      website: website,
      taxId: taxId,
      isKleinunternehmer: isKleinunternehmer,
      bankName: bankName,
      iban: iban,
      bic: bic,
      invoicePrefix: invoicePrefix,
      invoiceCounter: invoiceCounter,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Business copyWith({
    int? invoiceCounter,
    DateTime? updatedAt,
  }) {
    return Business(
      id: id,
      name: name,
      email: email,
      phone: phone,
      address: address,
      city: city,
      country: country,
      logoPath: logoPath,
      website: website,
      taxId: taxId,
      isKleinunternehmer: isKleinunternehmer,
      bankName: bankName,
      iban: iban,
      bic: bic,
      invoicePrefix: invoicePrefix,
      invoiceCounter: invoiceCounter ?? this.invoiceCounter,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
