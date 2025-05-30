import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_type_entity.dart';

class NotificationTypeModel extends Equatable {
  final int? typeId;
  final String name;
  final String? description;
  final String? status;  // Thêm trường status
  final String? createdAt;

  const NotificationTypeModel({
    required this.typeId,
    required this.name,
    this.description,
    this.status,
    this.createdAt,
  });

  factory NotificationTypeModel.fromJson(Map<String, dynamic> json) {
    print('Parsing NotificationTypeModel: $json');
    try {
      print('Parsing type_id: ${json['id']}');
      final typeId = json['id'] as int?;
      print('Parsing name: ${json['name']}');
      final name = json['name'] as String? ?? '';
      print('Parsing description: ${json['description']}');
      final description = json['description'] as String?;
      print('Parsing status: ${json['status']}');
      final status = json['status'] as String?;
      print('Parsing created_at: ${json['created_at']}');
      final createdAt = json['created_at'] as String?;

      return NotificationTypeModel(
        typeId: typeId,
        name: name,
        description: description,
        status: status,
        createdAt: createdAt,
      );
    } catch (e) {
      print('Error parsing NotificationTypeModel: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': typeId,
      'name': name,
      'description': description,
      'status': status,  // Thêm status vào JSON
      'created_at': createdAt,
    };
  }

  NotificationType toEntity() {
    return NotificationType(
      typeId: typeId,
      name: name,
      description: description,
      status: status,
      createdAt: createdAt != null ? DateTime.parse(createdAt!) : null,
    );
  }

  @override
  List<Object?> get props => [typeId, name, description, status, createdAt];
}