// lib/src/features/room/presentation/bloc/area_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/area_entity.dart';
import '../../domain/usecases/area/create_area.dart';
import '../../domain/usecases/area/delete_area.dart';
import '../../domain/usecases/area/get_all_areas.dart';
import '../../domain/usecases/area/get_area_by_id.dart';
import '../../domain/usecases/area/update_area.dart';
import 'area_event.dart';
import 'area_state.dart';

class AreaBloc extends Bloc<AreaEvent, AreaState> {
  final GetAllAreas getAllAreas;
  final GetAreaById getAreaById;
  final CreateArea createArea;
  final UpdateArea updateArea;
  final DeleteArea deleteArea;

  AreaBloc({
    required this.getAllAreas,
    required this.getAreaById,
    required this.createArea,
    required this.updateArea,
    required this.deleteArea,
  }) : super(AreaState()) {
    on<FetchAreasEvent>(_onFetchAreas);
    on<GetAreaByIdEvent>(_onGetAreaById);
    on<CreateAreaEvent>(_onCreateArea);
    on<UpdateAreaEvent>(_onUpdateArea);
    on<DeleteAreaEvent>(_onDeleteArea);
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
}