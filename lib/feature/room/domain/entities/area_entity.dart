// lib/src/features/room/domain/entities/area_entity.dart
class AreaEntity {
  final int areaId;
  final String name;
  final String? description;
  final String? createdAt;
  final String? updatedAt;

  const AreaEntity({
    required this.areaId,
    required this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  // Chuyển đổi thành JSON
  Map<String, dynamic> toJson() {
    return {
      'areaId': areaId,
      'name': name,
      'description': description,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Tạo đối tượng từ JSON
  factory AreaEntity.fromJson(Map<String, dynamic> json) {
    return AreaEntity(
      areaId: json['areaId'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }
}