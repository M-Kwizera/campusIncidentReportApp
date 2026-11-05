class Incident {
  final String id;
  final String title;
  final String description;
  final String category;
  final DateTime createdAt;
  final String? submittedBy;
  final String? submittedByEmail;
  final List<String> images;
  final String status;
  final int priority;
  
  Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.createdAt,
    this.submittedBy,
    this.submittedByEmail,
    this.images = const [],
    this.status = 'pending',
    this.priority = 1,
  });
  
  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? ''),
      submittedBy: json['submittedBy'],
      submittedByEmail: json['submittedByEmail'],
      images: List<String>.from(json['images'] ?? []),
      status: json['status'] ?? 'pending',
      priority: json['priority'] ?? 1,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'submittedBy': submittedBy,
      'submittedByEmail': submittedByEmail,
      'images': images,
      'status': status,
      'priority': priority,
    };
  }
  
  @override
  String toString() {
    return 'Incident(id: $id, title: $title, category: $category, status: $status)';
  }
}

class User {
  final String id;
  final String email;
  final String? displayName;
  final String role; // 'student' or 'staff'
  
  User({
    required this.id,
    required this.email,
    this.displayName,
    required this.role,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'],
      role: json['role'] ?? 'student',
    );
  }
}