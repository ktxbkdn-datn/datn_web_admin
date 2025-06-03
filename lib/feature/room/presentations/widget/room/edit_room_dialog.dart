import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../../common/constants/api_string.dart';
import '../../../domain/entities/room_entity.dart';
import '../../bloc/room_bloc/room_bloc.dart';
import '../../bloc/room_image_bloc/room_image_bloc.dart';
import '../../bloc/room_image_bloc/room_image_state.dart';
import 'image_drop_area.dart';
import 'room_form_widget.dart';

const String baseUrl = APIbaseUrl;

class EditRoomDialog extends StatefulWidget {
  final RoomEntity room;

  const EditRoomDialog({Key? key, required this.room}) : super(key: key);

  @override
  _EditRoomDialogState createState() => _EditRoomDialogState();
}

class _EditRoomDialogState extends State<EditRoomDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _capacityController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _statusController = TextEditingController(); // Kept for compatibility, but not used
  int? _areaId;
  String? _selectedStatus;
  bool _hasShownSuccessMessage = false;
  bool _hasShownErrorMessage = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.room.name;
    _capacityController.text = widget.room.capacity.toString();
    _priceController.text = widget.room.price.toString();
    _descriptionController.text = widget.room.description ?? '';
    _selectedStatus = widget.room.status;
    _areaId = widget.room.areaId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      print('Submitting UpdateRoomEvent:');
      print('Room ID: ${widget.room.roomId}');
      print('Name: ${_nameController.text}');
      print('Capacity: ${_capacityController.text}');
      print('Price: ${_priceController.text}');
      print('Description: ${_descriptionController.text}');
      print('Status: $_selectedStatus');
      print('Area ID: $_areaId');

      context.read<RoomBloc>().add(UpdateRoomEvent(
        roomId: widget.room.roomId,
        name: _nameController.text,
        capacity: int.parse(_capacityController.text),
        price: double.parse(_priceController.text),
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        status: _selectedStatus,
        areaId: _areaId,
        imageIdsToDelete: [],
        newImages: [],
      ));
    }
  }

  void _openImageManagementDialog() {
    showDialog(
      context: context,
      builder: (context) => ImageManagementDialog(roomId: widget.room.roomId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = MediaQuery.of(context).size.width;
          double screenHeight = MediaQuery.of(context).size.height;

          double dialogWidth = screenWidth < 800
              ? screenWidth * 0.9
              : screenWidth < 1200
                  ? screenWidth * 0.7
                  : 800;
          double dialogHeight = screenHeight < 800
              ? screenHeight * 0.9
              : screenHeight < 900
                  ? screenHeight * 0.8
                  : 600;

          return Container(
            width: dialogWidth,
            height: dialogHeight,
            padding: const EdgeInsets.all(24),
            child: BlocListener<RoomBloc, RoomState>(
              listener: (context, state) {
                if ((state is RoomUpdated || state is RoomImagesUploaded) && !_hasShownSuccessMessage) {
                  print('Room Updated Successfully');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cập nhật phòng thành công!'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  setState(() {
                    _hasShownSuccessMessage = true;
                  });
                  context.read<RoomImageBloc>().add(GetRoomImagesEvent(widget.room.roomId));
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  });
                } else if (state is RoomError && !_hasShownErrorMessage) {
                  print('Room Update Error: ${state.message}');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi: ${state.message}'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                  setState(() {
                    _hasShownErrorMessage = true;
                  });
                }
              },
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Chỉnh sửa Phòng',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.image, color: Colors.blue),
                            tooltip: 'Quản lý ảnh',
                            onPressed: _openImageManagementDialog,
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: RoomFormWidget(
                        formKey: _formKey,
                        nameController: _nameController,
                        capacityController: _capacityController,
                        priceController: _priceController,
                        descriptionController: _descriptionController,
                        statusController: _statusController,
                        areaId: _areaId,
                        onAreaChanged: (value) {
                          setState(() {
                            _areaId = value;
                          });
                        },
                        status: _selectedStatus ?? widget.room.status,
                        onStatusChanged: (value) {
                          setState(() {
                            _selectedStatus = value;
                          });
                        },
                        showStatusField: true,
                        showImageField: false,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Hủy',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text(
                          'Lưu',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ImageManagementDialog extends StatelessWidget {
  final int roomId;

  const ImageManagementDialog({Key? key, required this.roomId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _ImageManagementDialog(roomId: roomId);
  }
}

class _ImageManagementDialog extends StatefulWidget {
  final int roomId;

  const _ImageManagementDialog({required this.roomId});

  @override
  _ImageManagementDialogState createState() => _ImageManagementDialogState();
}

class _ImageManagementDialogState extends State<_ImageManagementDialog> {
  List<Map<String, dynamic>> _newImages = [];
  List<Map<String, dynamic>> _imagesToDelete = [];
  List<Map<String, dynamic>> _currentImages = [];
  bool _hasShownSuccessMessage = false;
  bool _hasShownErrorMessage = false;
  bool _isProcessing = false;
  int _pendingOperations = 0;
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    _hasShownSuccessMessage = false;
    _hasShownErrorMessage = false;
    _pendingOperations = 0;
    _isProcessing = false;
    context.read<RoomImageBloc>().add(GetRoomImagesEvent(widget.roomId));
  }

  @override
  void dispose() {
    _imagesToDelete.clear();
    super.dispose();
  }

  void _updatePendingOperations(int change) {
    setState(() {
      _pendingOperations += change;
      _isProcessing = _pendingOperations > 0;
      print('Pending operations: $_pendingOperations, IsProcessing: $_isProcessing');
    });
  }

  Future<void> _saveImages() async {
    if (_isProcessing) return;

    if (_newImages.isEmpty && _imagesToDelete.isEmpty) {
      print('No changes to save, closing dialog...');
      Future.delayed(const Duration(microseconds: 200), () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
      return;
    }

    _updatePendingOperations(1);

    print('Saving images for Room ID: ${widget.roomId}');
    print('Images to Delete: ${_imagesToDelete.map((img) => img['imageId']).toList()}');
    print('New Images: ${_newImages.map((img) => img['name']).toList()}');

    try {
      if (_imagesToDelete.isNotEmpty) {
        print('Deleting images: ${_imagesToDelete.map((img) => img['imageId']).toList()}');
        final imageIds = _imagesToDelete.map((img) => img['imageId'] as int).toList();
        context.read<RoomImageBloc>().add(DeleteRoomImagesBatchEvent(
          roomId: widget.roomId,
          imageIds: imageIds,
        ));
      }
      if (_newImages.isNotEmpty) {
        print('Uploading new images...');
        _updatePendingOperations(1);
        context.read<RoomImageBloc>().add(UploadRoomImagesEvent(
          roomId: widget.roomId,
          images: _newImages,
        ));
      }
    } catch (e) {
      print('Error saving images: $e');
      _updatePendingOperations(-1);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasChanges = _newImages.isNotEmpty || _imagesToDelete.isNotEmpty;

    return Stack(
      children: [
        Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            width: 600,
            height: 500,
            padding: const EdgeInsets.all(24),
            child: BlocListener<RoomImageBloc, RoomImageState>(
              listener: (context, state) {
                if (state is RoomImagesUploaded) {
                  print('Images Uploaded Successfully');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tải media lên thành công!'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  setState(() {
                    _newImages = [];
                    _currentImages.addAll(state.imageUrls.map((url) => {
                          'imageUrl': url,
                          'fileType': url.endsWith('.mp4') || url.endsWith('.avi') ? 'video' : 'image',
                        }).toList());
                  });
                  _updatePendingOperations(-1);
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  });
                } else if (state is RoomImagesLoaded) {
                  print('Images Loaded Successfully');
                  setState(() {
                    _isInitialLoad = false;
                    _currentImages = List.from(state.images);
                  });
                  if (_pendingOperations > 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cập nhật danh sách media thành công!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    setState(() {
                      _newImages = [];
                      _imagesToDelete = [];
                    });
                    _updatePendingOperations(-1);
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted) {
                        Navigator.of(context).pop();
                      }
                    });
                  }
                } else if (state is RoomImageError) {
                  print('Image Update Error: ${state.message}');
                  if (!state.message.contains('Không tìm thấy ảnh cho phòng này')) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Lỗi: ${state.message}'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                  _updatePendingOperations(-1);
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  });
                }
              },
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Quản lý media',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          if (mounted) {
                            _imagesToDelete.clear();
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Media hiện có:',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          BlocBuilder<RoomImageBloc, RoomImageState>(
                            builder: (context, imageState) {
                              List<Map<String, dynamic>> media = [];
                              bool isLoading = false;

                              if (imageState is RoomImagesLoaded) {
                                media = imageState.images;
                                _currentImages = List.from(media);
                              } else if (imageState is RoomImagesUploaded) {
                                media = imageState.imageUrls.map((url) => {
                                      'imageUrl': url,
                                      'fileType': url.endsWith('.mp4') || url.endsWith('.avi') ? 'video' : 'image',
                                    }).toList();
                                _currentImages.addAll(media);
                              } else if (imageState is RoomImageLoading) {
                                isLoading = true;
                              }

                              if (isLoading && media.isEmpty) {
                                return const Center(child: CircularProgressIndicator());
                              } else if (media.isEmpty) {
                                return Container(
                                  height: 100,
                                  width: double.infinity,
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Text(
                                      'Chưa có media',
                                      style: TextStyle(fontSize: 14, color: Colors.grey),
                                    ),
                                  ),
                                );
                              } else {
                                final displayMedia = _currentImages
                                    .where((item) =>
                                        !_imagesToDelete.any((deleted) => deleted['imageId'] == item['imageId']))
                                    .toList();

                                return Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: List<Widget>.generate(
                                    displayMedia.length,
                                    (index) {
                                      final item = displayMedia[index];
                                      final String fileType = item['fileType'] as String? ?? 'image';

                                      return Stack(
                                        children: [
                                          if (fileType == 'video')
                                            Container(
                                              width: 100,
                                              height: 100,
                                              color: Colors.black,
                                              child: const Icon(
                                                Icons.videocam,
                                                color: Colors.white,
                                                size: 50,
                                              ),
                                            )
                                          else
                                            Image.network(
                                              _buildImageUrl(item['imageUrl']),
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                print(
                                                    'Error loading image: $error, URL: ${_buildImageUrl(item['imageUrl'])}');
                                                return const Icon(Icons.error);
                                              },
                                            ),
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: IconButton(
                                              icon: const Icon(Icons.close, color: Colors.red, size: 20),
                                              onPressed: () {
                                                setState(() {
                                                  _imagesToDelete.add({
                                                    'imageId': item['imageId'],
                                                    'imageUrl': item['imageUrl'],
                                                  });
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Thêm media mới:',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ImageDropArea(
                            onImagesDropped: (images) {
                              setState(() {
                                _newImages = images;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          if (mounted) {
                            _imagesToDelete.clear();
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text(
                          'Hủy',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: (_isProcessing || !hasChanges) ? null : _saveImages,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: _isProcessing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Lưu media',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isProcessing)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  String _buildImageUrl(String imagePath) {
    String fileName = imagePath.split('/').last;
    return '$baseUrl/roomimage/$fileName';
  }
}