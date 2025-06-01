import '../../domain/entities/user_stats.dart';

class UserStatsModel extends UserStats {
  const UserStatsModel({
    required int areaId,
    required String areaName,
    required int userCount,
  }) : super(areaId: areaId, areaName: areaName, userCount: userCount);

  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      areaId: json['area_id'] as int,
      areaName: json['area_name'] as String,
      userCount: json['user_count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'area_id': areaId,
      'area_name': areaName,
      'user_count': userCount,
    };
  }

  UserStats toEntity() {
    return UserStats(
      areaId: areaId,
      areaName: areaName,
      userCount: userCount,
    );
  }
}