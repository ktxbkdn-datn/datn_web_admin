// lib/src/features/room/presentation/bloc/area_event.dart
abstract class AreaEvent {}

class FetchAreasEvent extends AreaEvent {
  final int page;
  final int limit;

  FetchAreasEvent({required this.page, required this.limit});
}

class GetAreaByIdEvent extends AreaEvent {
  final int areaId;

  GetAreaByIdEvent(this.areaId);
}

class CreateAreaEvent extends AreaEvent {
  final String name;

  CreateAreaEvent({required this.name});
}

class UpdateAreaEvent extends AreaEvent {
  final int areaId;
  final String? name;

  UpdateAreaEvent({required this.areaId, this.name});
}

class DeleteAreaEvent extends AreaEvent {
  final int areaId;

  DeleteAreaEvent(this.areaId);
}