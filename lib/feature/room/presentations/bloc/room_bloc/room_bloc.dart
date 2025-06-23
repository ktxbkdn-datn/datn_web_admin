import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:datn_web_admin/feature/room/domain/usecases/room_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import '../../../domain/entities/room_entity.dart';


part 'room_event.dart';
part 'room_state.dart';

class RoomBloc extends Bloc<RoomEvent, RoomState> {
  final GetAllRooms getAllRooms;
  final GetRoomById getRoomById;
  final CreateRoom createRoom;
  final UpdateRoom updateRoom;
  final DeleteRoom deleteRoom;
  final GetUsersInRoom getUsersInRoom; // thêm
  final ExportUsersInRoom exportUsersInRoom; // thêm

  RoomBloc({
    required this.getAllRooms,
    required this.getRoomById,
    required this.createRoom,
    required this.updateRoom,
    required this.deleteRoom,
    required this.getUsersInRoom, // thêm
    required this.exportUsersInRoom, // thêm
  }) : super(RoomInitial()) {
    on<GetAllRoomsEvent>(_onGetAllRooms);
    on<GetRoomByIdEvent>(_onGetRoomById);
    on<CreateRoomEvent>(_onCreateRoom);
    on<UpdateRoomEvent>(_onUpdateRoom);
    on<DeleteRoomEvent>(_onDeleteRoom);
    on<GetUsersInRoomEvent>(_onGetUsersInRoom); // thêm
    on<ExportUsersInRoomEvent>(_onExportUsersInRoom); // thêm
  }

  // Cập nhật phương thức _onGetAllRooms
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
      searchUser: event.searchUser,
    );
    
    emit(result.fold(
      (failure) => RoomError(message: failure.message),
      (data) => RoomLoaded(
        rooms: data['rooms'], 
        totalItems: data['totalItems']
      ),
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

  // Thêm handler cho lấy danh sách người dùng trong phòng
  Future<void> _onGetUsersInRoom(GetUsersInRoomEvent event, Emitter<RoomState> emit) async {
    emit(RoomLoading());
    try {
      final users = await getUsersInRoom(event.roomId);
      emit(UsersInRoomLoaded(users: users, roomId: event.roomId));
    } catch (e) {
      emit(RoomError(message: e.toString()));
    }
  }

  // Thêm handler cho export danh sách người dùng trong phòng
  Future<void> _onExportUsersInRoom(ExportUsersInRoomEvent event, Emitter<RoomState> emit) async {
    emit(RoomLoading());
    try {
      final fileBytes = await exportUsersInRoom(event.roomId);
      emit(ExportFileReady(
        fileBytes: fileBytes,
        filename: 'users_in_room_${event.roomId}.xlsx'
      ));
    } catch (e) {
      emit(RoomError(message: e.toString()));
    }
  }
}