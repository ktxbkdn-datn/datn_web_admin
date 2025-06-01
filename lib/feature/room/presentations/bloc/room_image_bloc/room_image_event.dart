part of 'room_image_bloc.dart';

abstract class RoomImageEvent {
  const RoomImageEvent();
}

class GetRoomImagesEvent extends RoomImageEvent {
  final int roomId;

  const GetRoomImagesEvent(this.roomId);
}

class UploadRoomImagesEvent extends RoomImageEvent {
  final int roomId;
  final List<Map<String, dynamic>> images;

  const UploadRoomImagesEvent({required this.roomId, required this.images});
}

class DeleteRoomImageEvent extends RoomImageEvent {
  final int roomId;
  final int imageId;

  const DeleteRoomImageEvent({required this.roomId, required this.imageId});
}

class DeleteRoomImagesBatchEvent extends RoomImageEvent {
  final int roomId;
  final List<int> imageIds;

  const DeleteRoomImagesBatchEvent({required this.roomId, required this.imageIds});
}

class ReorderRoomImagesEvent extends RoomImageEvent {
  final int roomId;
  final List<int> imageIds;

  const ReorderRoomImagesEvent({required this.roomId, required this.imageIds});
}

class ResetRoomImageStateEvent extends RoomImageEvent {
  const ResetRoomImageStateEvent();
}