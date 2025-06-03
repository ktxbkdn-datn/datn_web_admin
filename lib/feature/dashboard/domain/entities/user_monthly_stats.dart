import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class UserMonthlyStats extends Equatable {
  const UserMonthlyStats({
    required this.areaId,
    required this.areaName,
    required this.months,
    required this.totalUsers,
  });

  final int areaId;
  final String areaName;
  final Map<int, int> months;
  final int totalUsers;

  UserMonthlyStats toEntity() {
    return UserMonthlyStats(
      areaId: areaId,
      areaName: areaName,
      months: Map<int, int>.from(months),
      totalUsers: totalUsers,
    );
  }

  @override
  List<Object?> get props => [areaId, areaName, months, totalUsers];
}

@immutable
class UserRoomDetail extends Equatable {
  const UserRoomDetail({
    required this.roomName,
    required this.userCount,
    this.id,
    this.areaId,
    this.areaName,
    this.roomId,
    this.year,
    this.month,
    this.createdAt,
  });

  final int? id;
  final int? areaId;
  final String? areaName;
  final int? roomId;
  final String roomName;
  final int userCount;
  final int? year;
  final int? month;
  final String? createdAt;

  // Added toEntity() method to return a deep copy of UserRoomDetail
  UserRoomDetail toEntity() {
    return UserRoomDetail(
      id: id,
      areaId: areaId,
      areaName: areaName,
      roomId: roomId,
      roomName: roomName,
      userCount: userCount,
      year: year,
      month: month,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        areaId,
        areaName,
        roomId,
        roomName,
        userCount,
        year,
        month,
        createdAt,
      ];
}