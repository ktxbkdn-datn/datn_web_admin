import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import '../../../domain/entities/room_entity.dart';
import '../../../domain/usecases/create_room.dart';
import '../../../domain/usecases/delete_room.dart';
import '../../../domain/usecases/get_all_rooms.dart';
import '../../../domain/usecases/get_room_by_id.dart';
import '../../../domain/usecases/update_room.dart';

part 'room_event.dart';
part 'room_state.dart';

class RoomBloc extends Bloc<RoomEvent, RoomState> {
  final GetAllRooms getAllRooms;
  final GetRoomById getRoomById;
  final CreateRoom createRoom;
  final UpdateRoom updateRoom;
  final DeleteRoom deleteRoom;

  RoomBloc({
    required this.getAllRooms,
    required this.getRoomById,
    required this.createRoom,
    required this.updateRoom,
    required this.deleteRoom,
  }) : super(RoomInitial()) {
    on<GetAllRoomsEvent>(_onGetAllRooms);
    on<GetRoomByIdEvent>(_onGetRoomById);
    on<CreateRoomEvent>(_onCreateRoom);
    on<UpdateRoomEvent>(_onUpdateRoom);
    on<DeleteRoomEvent>(_onDeleteRoom);
  }

  Future<void> _onGetAllRooms(GetAllRoomsEvent event, Emitter<RoomState> emit) async {
    emit(RoomLoading());
    final result = await getAllRooms(
      page: event.page,
      limit: event.limit,
      minCapacity: event.minCapacity,
      maxCapacity: event.maxCapacity,
      minPrice: event.minPrice,
      maxPrice: event.maxPrice,
      available: event.available,
      search: event.search,
      areaId: event.areaId,
    );
    emit(result.fold(
          (failure) => RoomError(message: failure.message),
          (rooms) => RoomLoaded(rooms: rooms),
    ));
  }

  Future<void> _onGetRoomById(GetRoomByIdEvent event, Emitter<RoomState> emit) async {
    emit(RoomLoading());
    final result = await getRoomById(event.roomId);
    emit(result.fold(
          (failure) => RoomError(message: failure.message),
          (room) => RoomDetailLoaded(room: room),
    ));
  }

  Future<void> _onCreateRoom(CreateRoomEvent event, Emitter<RoomState> emit) async {
    emit(RoomLoading());
    final result = await createRoom(
      name: event.name,
      capacity: event.capacity,
      price: event.price,
      areaId: event.areaId,
      description: event.description,
      images: event.images,
    );
    emit(result.fold(
          (failure) => RoomError(message: failure.message),
          (room) => RoomCreated(room: room),
    ));
  }

  Future<void> _onUpdateRoom(UpdateRoomEvent event, Emitter<RoomState> emit) async {
    emit(RoomLoading());
    final result = await updateRoom(
      roomId: event.roomId,
      name: event.name,
      capacity: event.capacity,
      price: event.price,
      description: event.description,
      status: event.status,
      areaId: event.areaId,
      imageIdsToDelete: event.imageIdsToDelete,
      newImages: event.newImages,
    );
    emit(result.fold(
          (failure) => RoomError(message: failure.message),
          (room) => RoomUpdated(room: room),
    ));
  }

  Future<void> _onDeleteRoom(DeleteRoomEvent event, Emitter<RoomState> emit) async {
    emit(RoomLoading());
    final result = await deleteRoom(event.roomId);
    emit(result.fold(
          (failure) => RoomError(message: failure.message),
          (_) => RoomDeleted(roomId: event.roomId), // Truyền roomId vào RoomDeleted
    ));
  }
}