class Invoice {
  final String id;
  final String clientId;
  final String? projectId;
  final String invoiceNumber;
  final DateTime issueDate;
  final DateTime dueDate;

  /// Leistungsdatum (date of delivery/service). Null means same as issue date.
  final DateTime? serviceDate;
  final InvoiceStatus status;
  final List<InvoiceItem> items;
  final double subtotal;
  final double taxRate;
  final double taxAmount;
  final double total;
  final String? notes;
  final String? terms;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? paidAt;

  Invoice({
    required this.id,
    required this.clientId,
    this.projectId,
    required this.invoiceNumber,
    required this.issueDate,
    required this.dueDate,
    this.serviceDate,
    required this.status,
    required this.items,
    required this.subtotal,
    required this.taxRate,
    required this.taxAmount,
    required this.total,
    this.notes,
    this.terms,
    required this.createdAt,
    required this.updatedAt,
    this.paidAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'projectId': projectId,
      'invoiceNumber': invoiceNumber,
      'issueDate': issueDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'serviceDate': serviceDate?.toIso8601String(),
      'status': status.name,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'taxRate': taxRate,
      'taxAmount': taxAmount,
      'total': total,
      'notes': notes,
      'terms': terms,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
    };
  }

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      clientId: json['clientId'],
      projectId: json['projectId'],
      invoiceNumber: json['invoiceNumber'],
      issueDate: DateTime.parse(json['issueDate']),
      dueDate: DateTime.parse(json['dueDate']),
      serviceDate: json['serviceDate'] != null
          ? DateTime.parse(json['serviceDate'])
          : null,
      status: InvoiceStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => InvoiceStatus.draft,
      ),
      items: (json['items'] as List<dynamic>)
          .map((item) => InvoiceItem.fromJson(item))
          .toList(),
      subtotal: json['subtotal'].toDouble(),
      taxRate: json['taxRate'].toDouble(),
      taxAmount: json['taxAmount'].toDouble(),
      total: json['total'].toDouble(),
      notes: json['notes'],
      terms: json['terms'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
    );
  }

  Invoice copyWith({
    String? id,
    String? clientId,
    String? projectId,
    String? invoiceNumber,
    DateTime? issueDate,
    DateTime? dueDate,
    DateTime? serviceDate,
    InvoiceStatus? status,
    List<InvoiceItem>? items,
    double? subtotal,
    double? taxRate,
    double? taxAmount,
    double? total,
    String? notes,
    String? terms,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? paidAt,
  }) {
    return Invoice(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      projectId: projectId ?? this.projectId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      serviceDate: serviceDate ?? this.serviceDate,
      status: status ?? this.status,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      taxRate: taxRate ?? this.taxRate,
      taxAmount: taxAmount ?? this.taxAmount,
      total: total ?? this.total,
      notes: notes ?? this.notes,
      terms: terms ?? this.terms,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      paidAt: paidAt ?? this.paidAt,
    );
  }
}

class InvoiceItem {
  final String id;
  final String description;
  final double quantity;
  final double unitPrice;
  final double total;
  final String unit;
  final DiscountType discountType;
  final double discountValue;

  InvoiceItem({
    required this.id,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.total,
    this.unit = 'no_unit',
    this.discountType = DiscountType.none,
    this.discountValue = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'total': total,
      'unit': unit,
      'discountType': discountType.name,
      'discountValue': discountValue,
    };
  }

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id'],
      description: json['description'],
      quantity: (json['quantity'] as num).toDouble(),
      unitPrice: json['unitPrice'].toDouble(),
      total: json['total'].toDouble(),
      unit: json['unit'] ?? 'no_unit',
      discountType: DiscountType.values.firstWhere(
        (d) => d.name == json['discountType'],
        orElse: () => DiscountType.none,
      ),
      discountValue: json['discountValue']?.toDouble() ?? 0.0,
    );
  }

  InvoiceItem copyWith({
    String? id,
    String? description,
    double? quantity,
    double? unitPrice,
    double? total,
    String? unit,
    DiscountType? discountType,
    double? discountValue,
  }) {
    return InvoiceItem(
      id: id ?? this.id,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      total: total ?? this.total,
      unit: unit ?? this.unit,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
    );
  }
}

enum InvoiceStatus {
  draft,
  sent,
  paid,
  overdue,
  cancelled,
}

extension InvoiceStatusExtension on InvoiceStatus {
  String get displayName {
    switch (this) {
      case InvoiceStatus.draft:
        return 'Draft';
      case InvoiceStatus.sent:
        return 'Sent';
      case InvoiceStatus.paid:
        return 'Paid';
      case InvoiceStatus.overdue:
        return 'Overdue';
      case InvoiceStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get emoji {
    switch (this) {
      case InvoiceStatus.draft:
        return '📝';
      case InvoiceStatus.sent:
        return '📤';
      case InvoiceStatus.paid:
        return '✅';
      case InvoiceStatus.overdue:
        return '⚠️';
      case InvoiceStatus.cancelled:
        return '❌';
    }
  }
}

enum DiscountType {
  none,
  percentage,
  fixedDiscount,
  fixedPerItem,
}

extension DiscountTypeExtension on DiscountType {
  String get displayName {
    switch (this) {
      case DiscountType.none:
        return 'No Discount';
      case DiscountType.percentage:
        return 'Percentage';
      case DiscountType.fixedDiscount:
        return 'Fixed discount';
      case DiscountType.fixedPerItem:
        return 'Fixed per Item';
    }
  }
}
