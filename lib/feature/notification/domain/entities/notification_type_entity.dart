class NotificationType {
  final int? typeId;
  final String name;
  final String? description;
  final String? status;  // Thêm trường status
  final DateTime? createdAt;

  NotificationType({
    required this.typeId,
    required this.name,
    this.description,
    this.status,
    this.createdAt,
  });

  factory NotificationType.fromJson(Map<String, dynamic> json) {
    return NotificationType(
      typeId: json['id'] as int?,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      status: json['status'] as String?,  // Lấy status từ JSON
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': typeId,
      'name': name,
      'description': description,
      'status': status,  // Thêm status vào JSON
      'created_at': createdAt?.toIso8601String(),
    };
  }
}