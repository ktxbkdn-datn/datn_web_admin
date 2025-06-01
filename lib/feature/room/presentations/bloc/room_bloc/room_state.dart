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

  const RoomLoaded({required this.rooms});

  @override
  List<Object?> get props => [rooms];
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