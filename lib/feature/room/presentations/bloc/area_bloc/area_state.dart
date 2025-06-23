// lib/src/features/room/presentation/bloc/area_state.dart
import 'dart:typed_data';

import '../../../domain/entities/area_entity.dart';

class AreaState {
  final bool isLoading;
  final List<AreaEntity> areas;
  final AreaEntity? selectedArea;
  final String? error;
  final String? successMessage;
  final Uint8List? exportFile;
  final List<Map<String, dynamic>>? areasWithStudentCount;
  final List<Map<String, dynamic>>? usersInArea;
  final List<Map<String, dynamic>>? allUsersInAllAreas; // Thêm trường mới

  AreaState({
    this.isLoading = false,
    this.areas = const [],
    this.selectedArea,
    this.error,
    this.successMessage,
    this.exportFile,
    this.areasWithStudentCount,
    this.usersInArea,
    this.allUsersInAllAreas, // Thêm trường mới
  });

  AreaState copyWith({
    bool? isLoading,
    List<AreaEntity>? areas,
    AreaEntity? selectedArea,
    String? error,
    String? successMessage,
    Uint8List? exportFile,
    List<Map<String, dynamic>>? areasWithStudentCount,
    List<Map<String, dynamic>>? usersInArea,
    List<Map<String, dynamic>>? allUsersInAllAreas, // Thêm trường mới
  }) {
    return AreaState(
      isLoading: isLoading ?? this.isLoading,
      areas: areas ?? this.areas,
      selectedArea: selectedArea ?? this.selectedArea,
      error: error,
      successMessage: successMessage,
      exportFile: exportFile ?? this.exportFile,
      areasWithStudentCount: areasWithStudentCount ?? this.areasWithStudentCount,
      usersInArea: usersInArea ?? this.usersInArea,
      allUsersInAllAreas: allUsersInAllAreas ?? this.allUsersInAllAreas, // Thêm trường mới
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
    String? successMessage,
  }) : super(
          isLoading: isLoading,
          areas: areas,
          selectedArea: selectedArea,
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

class ExportUsersInRoomSuccess extends AreaState {
  final Uint8List fileBytes;
  ExportUsersInRoomSuccess(this.fileBytes);
}

class ExportUsersInRoomFailure extends AreaState {
  final String error;
  ExportUsersInRoomFailure(this.error);
}