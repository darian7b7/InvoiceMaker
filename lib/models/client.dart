class Client {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String country;
  final String? company;
  final String? taxId;
  final List<Project> projects;
  final DateTime createdAt;
  final DateTime updatedAt;

  Client({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.country,
    this.company,
    this.taxId,
    this.projects = const [],
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
      'company': company,
      'taxId': taxId,
      'projects': projects.map((p) => p.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      city: json['city'],
      country: json['country'],
      company: json['company'],
      taxId: json['taxId'],
      projects: (json['projects'] as List<dynamic>?)
          ?.map((p) => Project.fromJson(p))
          .toList() ?? [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Client copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? country,
    String? company,
    String? taxId,
    List<Project>? projects,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      company: company ?? this.company,
      taxId: taxId ?? this.taxId,
      projects: projects ?? this.projects,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class Project {
  final String id;
  final String clientId;
  final String name;
  final String description;
  final String address;
  final String city;
  final ProjectStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final double? budget;
  final DateTime createdAt;
  final DateTime updatedAt;

  Project({
    required this.id,
    required this.clientId,
    required this.name,
    required this.description,
    required this.address,
    required this.city,
    required this.status,
    required this.startDate,
    this.endDate,
    this.budget,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'name': name,
      'description': description,
      'address': address,
      'city': city,
      'status': status.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'budget': budget,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      clientId: json['clientId'],
      name: json['name'],
      description: json['description'],
      address: json['address'],
      city: json['city'],
      status: ProjectStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => ProjectStatus.planning,
      ),
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      budget: json['budget']?.toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Project copyWith({
    String? id,
    String? clientId,
    String? name,
    String? description,
    String? address,
    String? city,
    ProjectStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    double? budget,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      city: city ?? this.city,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      budget: budget ?? this.budget,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum ProjectStatus {
  planning,
  active,
  onHold,
  completed,
  cancelled,
}

extension ProjectStatusExtension on ProjectStatus {
  String get displayName {
    switch (this) {
      case ProjectStatus.planning:
        return 'Planning';
      case ProjectStatus.active:
        return 'Active';
      case ProjectStatus.onHold:
        return 'On Hold';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get emoji {
    switch (this) {
      case ProjectStatus.planning:
        return '📋';
      case ProjectStatus.active:
        return '🚧';
      case ProjectStatus.onHold:
        return '⏸️';
      case ProjectStatus.completed:
        return '✅';
      case ProjectStatus.cancelled:
        return '❌';
    }
  }
}
