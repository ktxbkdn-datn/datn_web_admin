import 'package:datn_web_admin/feature/room/domain/usecases/room_image_usecase.dart';
import 'package:datn_web_admin/feature/room/domain/usecases/room_usecase.dart';
import 'package:get_it/get_it.dart';

import '../../../../feature/room/data/datasources/area_datasource.dart';
import '../../../../feature/room/data/datasources/room_datasource.dart';
import '../../../../feature/room/data/datasources/room_image_datasource.dart';
import '../../../../feature/room/data/repository/area_repository_impl.dart';
import '../../../../feature/room/data/repository/room_image_repository_impl.dart';
import '../../../../feature/room/data/repository/room_repository_impl.dart';
import '../../../../feature/room/domain/repositories/area_repository.dart';
import '../../../../feature/room/domain/repositories/room_image_repository.dart';
import '../../../../feature/room/domain/repositories/room_repository.dart';

import '../../../../feature/room/domain/usecases/area_usecase.dart';

import '../../../../feature/room/presentations/bloc/area_bloc/area_bloc.dart';
import '../../../../feature/room/presentations/bloc/room_bloc/room_bloc.dart';
import '../../../../feature/room/presentations/bloc/room_image_bloc/room_image_bloc.dart';
import '../../network/api_client.dart';

final getIt = GetIt.instance;

void registerRoomDependencies() {
  // Room
  getIt.registerSingleton<RoomDataSource>(RoomDataSource(getIt<ApiService>()));
  getIt.registerSingleton<RoomRepository>(RoomRepositoryImpl(getIt<RoomDataSource>()));
  getIt.registerSingleton<GetAllRooms>(GetAllRooms(getIt<RoomRepository>()));
  getIt.registerSingleton<GetRoomById>(GetRoomById(getIt<RoomRepository>()));
  getIt.registerSingleton<CreateRoom>(CreateRoom(getIt<RoomRepository>()));
  getIt.registerSingleton<UpdateRoom>(UpdateRoom(getIt<RoomRepository>()));
  getIt.registerSingleton<DeleteRoom>(DeleteRoom(getIt<RoomRepository>()));
  getIt.registerSingleton<GetUsersInRoom>(GetUsersInRoom(getIt<RoomRepository>()));
  getIt.registerSingleton<ExportUsersInRoom>(ExportUsersInRoom(getIt<RoomRepository>()));
  getIt.registerFactory<RoomBloc>(() => RoomBloc(
    getAllRooms: getIt<GetAllRooms>(),
    getRoomById: getIt<GetRoomById>(),
    createRoom: getIt<CreateRoom>(),
    updateRoom: getIt<UpdateRoom>(),
    deleteRoom: getIt<DeleteRoom>(),
    getUsersInRoom: getIt<GetUsersInRoom>(),
    exportUsersInRoom: getIt<ExportUsersInRoom>(),
  ));

  // Room Image
  getIt.registerSingleton<RoomImageDataSource>(RoomImageDataSource(getIt<ApiService>()));
  getIt.registerSingleton<RoomImageRepository>(RoomImageRepositoryImpl(getIt<RoomImageDataSource>()));
  getIt.registerSingleton<GetRoomImages>(GetRoomImages(getIt<RoomImageRepository>()));
  getIt.registerSingleton<UploadRoomImages>(UploadRoomImages(getIt<RoomImageRepository>()));
  getIt.registerSingleton<DeleteRoomImage>(DeleteRoomImage(getIt<RoomImageRepository>()));
  getIt.registerSingleton<ReorderRoomImages>(ReorderRoomImages(getIt<RoomImageRepository>()));
  getIt.registerSingleton<DeleteMoreRoomImage>(DeleteMoreRoomImage(getIt<RoomImageRepository>()));
  getIt.registerFactory<RoomImageBloc>(() => RoomImageBloc(
    getRoomImages: getIt<GetRoomImages>(),
    uploadRoomImages: getIt<UploadRoomImages>(),
    deleteRoomImage: getIt<DeleteRoomImage>(),
    reorderRoomImages: getIt<ReorderRoomImages>(),
    deleteMoreRoomImage: getIt<DeleteMoreRoomImage>(),
  ));

  // Area
  getIt.registerSingleton<AreaDataSource>(AreaDataSource(getIt<ApiService>()));
  getIt.registerSingleton<AreaRepository>(AreaRepositoryImpl(getIt<AreaDataSource>()));
  getIt.registerSingleton<GetAllAreas>(GetAllAreas(getIt<AreaRepository>()));
  getIt.registerSingleton<GetAreaById>(GetAreaById(getIt<AreaRepository>()));
  getIt.registerSingleton<CreateArea>(CreateArea(getIt<AreaRepository>()));
  getIt.registerSingleton<UpdateArea>(UpdateArea(getIt<AreaRepository>()));
  getIt.registerSingleton<DeleteArea>(DeleteArea(getIt<AreaRepository>()));
  getIt.registerSingleton<ExportUsersInArea>(ExportUsersInArea(getIt<AreaRepository>()));
  getIt.registerSingleton<GetAreasWithStudentCount>(GetAreasWithStudentCount(getIt<AreaRepository>()));
  getIt.registerSingleton<GetUsersInArea>(GetUsersInArea(getIt<AreaRepository>()));
  getIt.registerSingleton<GetAllUsersInAllAreas>(GetAllUsersInAllAreas(getIt<AreaRepository>()));
  getIt.registerSingleton<ExportAllUsersInAllAreas>(ExportAllUsersInAllAreas(getIt<AreaRepository>()));
  getIt.registerFactory<AreaBloc>(() => AreaBloc(
    getAllAreas: getIt<GetAllAreas>(),
    getAreaById: getIt<GetAreaById>(),
    createArea: getIt<CreateArea>(),
    updateArea: getIt<UpdateArea>(),
    deleteArea: getIt<DeleteArea>(),
    exportUsersInArea: getIt<ExportUsersInArea>(),
    getAreasWithStudentCount: getIt<GetAreasWithStudentCount>(),
    getUsersInArea: getIt<GetUsersInArea>(),
    getAllUsersInAllAreas: getIt<GetAllUsersInAllAreas>(),
    exportAllUsersInAllAreas: getIt<ExportAllUsersInAllAreas>(),
  ));
}