part of 'room_bloc.dart';

abstract class RoomState extends Equatable {
  const RoomState();

  @override
  List<Object?> get props => [];
}

class RoomInitial extends RoomState {}

class RoomLoading extends RoomState {}

class RoomLoaded extends RoomState {
  final List<RoomEntity> rooms;
  final int totalItems; // Thêm totalItems

  const RoomLoaded({
    required this.rooms,
    required this.totalItems,
  });

  @override
  List<Object?> get props => [rooms, totalItems];
}

class RoomDetailLoaded extends RoomState {
  final RoomEntity room;

  const RoomDetailLoaded({required this.room});

  @override
  List<Object?> get props => [room];
}

class RoomCreated extends RoomState {
  final RoomEntity room;

  const RoomCreated({required this.room});

  @override
  List<Object?> get props => [room];
}

class RoomUpdated extends RoomState {
  final RoomEntity room;

  const RoomUpdated({required this.room});

  @override
  List<Object?> get props => [room];
}

class RoomDeleted extends RoomState {
  final int roomId; // Thêm thuộc tính roomId

  const RoomDeleted({required this.roomId});

  @override
  List<Object?> get props => [roomId];
}

class RoomError extends RoomState {
  final String message;

  const RoomError({required this.message});

  @override
  List<Object?> get props => [message];
}

class UsersInRoomLoaded extends RoomState {
  final List<Map<String, dynamic>> users;
  final int roomId;

  const UsersInRoomLoaded({required this.users, required this.roomId});

  @override
  List<Object?> get props => [users, roomId];
}

class ExportFileReady extends RoomState {
  final Uint8List fileBytes;
  final String filename;

  const ExportFileReady({required this.fileBytes, required this.filename});

  @override
  List<Object?> get props => [fileBytes, filename];
}