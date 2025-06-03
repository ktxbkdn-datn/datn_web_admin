import 'package:meta/meta.dart';
import '../../domain/entities/user_monthly_stats.dart';

// Model chính cho thống kê số người dùng theo khu vực
@immutable
class UserMonthlyStatsModel extends UserMonthlyStats {
  const UserMonthlyStatsModel({
    required int areaId,
    required String areaName,
    required Map<int, int> months,
    required int totalUsers,
  }) : super(areaId: areaId, areaName: areaName, months: months, totalUsers: totalUsers);

  factory UserMonthlyStatsModel.fromJson(Map<String, dynamic> json) {
    final monthsJson = json['months'] as Map<String, dynamic>? ?? {};
    final months = monthsJson.map(
      (key, value) {
        // Parse string key and value to int
        final monthKey = int.parse(key);
        final monthValue = value is String ? int.parse(value) : value as int;
        return MapEntry(monthKey, monthValue);
      },
    );

    // Parse total_users as string or int
    final totalUsers = json['total_users'] is String
        ? int.parse(json['total_users'] as String)
        : json['total_users'] as int? ?? 0;

    return UserMonthlyStatsModel(
      areaId: json['area_id'] as int? ?? 0,
      areaName: json['area_name'] as String? ?? '',
      months: months,
      totalUsers: totalUsers,
    );
  }

  Map<String, dynamic> toJson() {
    final monthsJson = months.map(
      (month, count) => MapEntry(month.toString(), count),
    );

    return {
      'area_id': areaId,
      'area_name': areaName,
      'months': monthsJson,
      'total_users': totalUsers,
    };
  }

  @override
  UserMonthlyStats toEntity() {
    return UserMonthlyStats(
      areaId: areaId,
      areaName: areaName,
      months: months,
      totalUsers: totalUsers,
    );
  }
}

// Model phụ cho số người dùng trong phòng chi tiết
@immutable
class UserRoomDetailModel extends UserRoomDetail {
  const UserRoomDetailModel({
    required String roomName,
    required int userCount,
    int? id,
    int? areaId,
    String? areaName,
    int? roomId,
    int? year,
    int? month,
    String? createdAt,
  }) : super(
          roomName: roomName,
          userCount: userCount,
          id: id,
          areaId: areaId,
          areaName: areaName,
          roomId: roomId,
          year: year,
          month: month,
          createdAt: createdAt,
        );

  factory UserRoomDetailModel.fromJson(Map<String, dynamic> json) {
    return UserRoomDetailModel(
      id: json['id'] as int?,
      areaId: json['area_id'] as int?,
      areaName: json['area_name'] as String?,
      roomId: json['room_id'] as int?,
      roomName: json['room_name'] as String? ?? '',
      year: json['year'] as int?,
      month: json['month'] as int?,
      userCount: json['user_count'] as int? ?? 0,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'area_id': areaId,
      'area_name': areaName,
      'room_id': roomId,
      'room_name': roomName,
      'year': year,
      'month': month,
      'user_count': userCount,
      'created_at': createdAt,
    };
  }

  @override
  UserRoomDetail toEntity() {
    return UserRoomDetail(
      roomName: roomName,
      userCount: userCount,
      id: id,
      areaId: areaId,
      areaName: areaName,
      roomId: roomId,
      year: year,
      month: month,
      createdAt: createdAt,
    );
  }
}