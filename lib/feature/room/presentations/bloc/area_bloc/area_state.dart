// lib/src/features/room/presentation/bloc/area_state.dart
import '../../../domain/entities/area_entity.dart';

class AreaState {
  final bool isLoading;
  final List<AreaEntity> areas;
  final AreaEntity? selectedArea;
  final String? error;
  final String? successMessage;

  AreaState({
    this.isLoading = false,
    this.areas = const [],
    this.selectedArea,
    this.error,
    this.successMessage,
  });

  AreaState copyWith({
    bool? isLoading,
    List<AreaEntity>? areas,
    AreaEntity? selectedArea,
    String? error,
    String? successMessage,
  }) {
    return AreaState(
      isLoading: isLoading ?? this.isLoading,
      areas: areas ?? this.areas,
      selectedArea: selectedArea ?? this.selectedArea,
      error: error,
      successMessage: successMessage,
    );
  }
}

class AreaCreated extends AreaState {
  final AreaEntity area;

  AreaCreated({
    required this.area,
    required bool isLoading,
    required List<AreaEntity> areas,
    AreaEntity? selectedArea,
    String? error,
    String? successMessage,
  }) : super(
    isLoading: isLoading,
    areas: areas,
    selectedArea: selectedArea,
    error: error,
    successMessage: successMessage,
  );
}

class AreaDeleted extends AreaState {
  final int areaId;

  AreaDeleted({
    required this.areaId,
    required bool isLoading,
    required List<AreaEntity> areas,
    AreaEntity? selectedArea,
    String? error,
    String? successMessage,
  }) : super(
    isLoading: isLoading,
    areas: areas,
    selectedArea: selectedArea,
    error: error,
    successMessage: successMessage,
  );
}

class AreaUpdated extends AreaState {
  final AreaEntity area;

  AreaUpdated({
    required this.area,
    required bool isLoading,
    required List<AreaEntity> areas,
    AreaEntity? selectedArea,
    String? error,
    String? successMessage,
  }) : super(
    isLoading: isLoading,
    areas: areas,
    selectedArea: selectedArea,
    error: error,
    successMessage: successMessage,
  );
}