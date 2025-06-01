part of 'room_bloc.dart';

abstract class RoomEvent extends Equatable {
  const RoomEvent();

  @override
  List<Object?> get props => [];
}

class GetAllRoomsEvent extends RoomEvent {
  final int page;
  final int limit;
  final int? minCapacity;
  final int? maxCapacity;
  final double? minPrice;
  final double? maxPrice;
  final bool? available;
  final String? search;
  final int? areaId;

  const GetAllRoomsEvent({
    required this.page,
    required this.limit,
    this.minCapacity,
    this.maxCapacity,
    this.minPrice,
    this.maxPrice,
    this.available,
    this.search,
    this.areaId,
  });

  @override
  List<Object?> get props => [page, limit, minCapacity, maxCapacity, minPrice, maxPrice, available, search, areaId];
}

class GetRoomByIdEvent extends RoomEvent {
  final int roomId;

  const GetRoomByIdEvent(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

class CreateRoomEvent extends RoomEvent {
  final String name;
  final int capacity;
  final double price;
  final int areaId;
  final String? description;
  final List<Map<String, dynamic>> images;

  const CreateRoomEvent({
    required this.name,
    required this.capacity,
    required this.price,
    required this.areaId,
    this.description,
    this.images = const [],
  });

  @override
  List<Object?> get props => [name, capacity, price, areaId, description, images];
}

class UpdateRoomEvent extends RoomEvent {
  final int roomId;
  final String? name;
  final int? capacity;
  final double? price;
  final String? description;
  final String? status;
  final int? areaId;
  final List<int>? imageIdsToDelete;
  final List<Map<String, dynamic>>? newImages;

  const UpdateRoomEvent({
    required this.roomId,
    this.name,
    this.capacity,
    this.price,
    this.description,
    this.status,
    this.areaId,
    this.imageIdsToDelete,
    this.newImages,
  });

  @override
  List<Object?> get props => [
    roomId,
    name,
    capacity,
    price,
    description,
    status,
    areaId,
    imageIdsToDelete,
    newImages,
  ];
}

class DeleteRoomEvent extends RoomEvent {
  final int roomId;

  const DeleteRoomEvent(this.roomId);

  @override
  List<Object?> get props => [roomId];
}