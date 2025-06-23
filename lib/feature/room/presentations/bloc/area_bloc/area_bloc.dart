// lib/src/features/room/presentation/bloc/area_bloc.dart
import 'dart:typed_data';
import 'package:datn_web_admin/feature/room/domain/usecases/area_usecase.dart';
import 'package:datn_web_admin/feature/room/presentations/bloc/area_bloc/area_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/area_entity.dart';

import 'area_state.dart';

class AreaBloc extends Bloc<AreaEvent, AreaState> {
  final GetAllAreas getAllAreas;
  final GetAreaById getAreaById;
  final CreateArea createArea;
  final UpdateArea updateArea;
  final DeleteArea deleteArea;
  final ExportUsersInArea exportUsersInArea; // Thêm
  final GetAreasWithStudentCount getAreasWithStudentCount; // Thêm
  final GetUsersInArea getUsersInArea; // Thêm
  // Thêm 2 usecase mới
  final GetAllUsersInAllAreas getAllUsersInAllAreas;
  final ExportAllUsersInAllAreas exportAllUsersInAllAreas;

  AreaBloc({
    required this.getAllAreas,
    required this.getAreaById,
    required this.createArea,
    required this.updateArea,
    required this.deleteArea,
    required this.exportUsersInArea, // Thêm
    required this.getAreasWithStudentCount, // Thêm
    required this.getUsersInArea, // Thêm
    required this.getAllUsersInAllAreas, // Thêm
    required this.exportAllUsersInAllAreas, // Thêm
  }) : super(AreaState()) {
    on<FetchAreasEvent>(_onFetchAreas);
    on<GetAreaByIdEvent>(_onGetAreaById);
    on<CreateAreaEvent>(_onCreateArea);
    on<UpdateAreaEvent>(_onUpdateArea);
    on<DeleteAreaEvent>(_onDeleteArea);
    on<ExportUsersInRoomEvent>(_onExportUsersInRoom);
    on<ExportUsersInAreaEvent>(_onExportUsersInArea); // Thêm
    on<GetAreasWithStudentCountEvent>(_onGetAreasWithStudentCount); // Thêm
    on<GetUsersInAreaEvent>(_onGetUsersInArea); // Thêm
    on<GetAllUsersInAllAreasEvent>(_onGetAllUsersInAllAreas); // Thêm
    on<ExportAllUsersInAllAreasEvent>(_onExportAllUsersInAllAreas); // Thêm
  }

  Future<void> _onFetchAreas(FetchAreasEvent event, Emitter<AreaState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    final result = await getAllAreas(page: event.page, limit: event.limit);
    result.fold(
          (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
          (areas) => emit(state.copyWith(isLoading: false, areas: areas)),
    );
  }

  Future<void> _onGetAreaById(GetAreaByIdEvent event, Emitter<AreaState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    final result = await getAreaById(event.areaId);
    result.fold(
          (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
          (area) => emit(state.copyWith(isLoading: false, selectedArea: area)),
    );
  }

  Future<void> _onCreateArea(CreateAreaEvent event, Emitter<AreaState> emit) async {
    emit(state.copyWith(isLoading: true, error: null, successMessage: null));
    final result = await createArea(name: event.name);
    result.fold(
          (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
          (area) {
        final updatedAreas = List<AreaEntity>.from(state.areas)..add(area);
        emit(AreaCreated(
          area: area,
          isLoading: false,
          areas: updatedAreas,
          selectedArea: state.selectedArea,
          successMessage: 'Tạo khu vực thành công',
        ));
      },
    );
  }

  Future<void> _onUpdateArea(UpdateAreaEvent event, Emitter<AreaState> emit) async {
    emit(state.copyWith(isLoading: true, error: null, successMessage: null));
    final result = await updateArea(areaId: event.areaId, name: event.name);
    result.fold(
          (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
          (area) {
        final updatedAreas = state.areas.map((a) => a.areaId == area.areaId ? area : a).toList();
        emit(AreaUpdated(
          area: area,
          isLoading: false,
          areas: updatedAreas,
          selectedArea: state.selectedArea,
          successMessage: 'Cập nhật khu vực thành công',
        ));
      },
    );
  }

  Future<void> _onDeleteArea(DeleteAreaEvent event, Emitter<AreaState> emit) async {
    emit(state.copyWith(isLoading: true, error: null, successMessage: null));
    final result = await deleteArea(event.areaId);
    result.fold(
          (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
          (_) {
        final updatedAreas = state.areas.where((a) => a.areaId != event.areaId).toList();
        emit(AreaDeleted(
          areaId: event.areaId,
          isLoading: false,
          areas: updatedAreas,
          selectedArea: state.selectedArea,
          successMessage: 'Xóa khu vực thành công',
        ));
      },
    );
  }

  // Thêm hàm xử lý export users trong khu vực
  Future<void> _onExportUsersInArea(ExportUsersInAreaEvent event, Emitter<AreaState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final fileBytes = await exportUsersInArea(event.areaId);
      emit(state.copyWith(
        isLoading: false,
        exportFile: fileBytes,
        successMessage: 'Đã tạo file Excel thành công',
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  // Thêm hàm lấy danh sách khu vực kèm số lượng sinh viên
  Future<void> _onGetAreasWithStudentCount(GetAreasWithStudentCountEvent event, Emitter<AreaState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final areasWithCount = await getAreasWithStudentCount();
      emit(state.copyWith(
        isLoading: false,
        areasWithStudentCount: areasWithCount,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  // Thêm hàm lấy danh sách sinh viên trong khu vực
  Future<void> _onGetUsersInArea(GetUsersInAreaEvent event, Emitter<AreaState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final users = await getUsersInArea(event.areaId);
      emit(state.copyWith(
        isLoading: false,
        usersInArea: users,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  // Thêm handler cho lấy tất cả sinh viên
  Future<void> _onGetAllUsersInAllAreas(GetAllUsersInAllAreasEvent event, Emitter<AreaState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final users = await getAllUsersInAllAreas();
      emit(state.copyWith(
        isLoading: false,
        allUsersInAllAreas: users,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  // Thêm handler cho export tất cả sinh viên
  Future<void> _onExportAllUsersInAllAreas(ExportAllUsersInAllAreasEvent event, Emitter<AreaState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final fileBytes = await exportAllUsersInAllAreas();
      emit(state.copyWith(
        isLoading: false,
        exportFile: fileBytes,
        successMessage: 'Đã tạo file Excel danh sách tất cả sinh viên thành công',
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  // Còn thiếu phương thức này:
  Future<void> _onExportUsersInRoom(ExportUsersInRoomEvent event, Emitter<AreaState> emit) async {
    // Implement this method
  }
}