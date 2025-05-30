// lib/src/features/room/data/models/area_model.dart
import '../../domain/entities/area_entity.dart';

class AreaModel extends AreaEntity {
  AreaModel({
    required int areaId,
    required String name,
    String? description,
    String? createdAt,
    String? updatedAt,
  }) : super(
    areaId: areaId,
    name: name,
    description: description,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  factory AreaModel.fromJson(Map<String, dynamic> json) {
    return AreaModel(
      areaId: json['area_id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}