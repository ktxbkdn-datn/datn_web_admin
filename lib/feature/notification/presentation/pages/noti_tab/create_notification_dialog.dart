import 'package:datn_web_admin/feature/notification/presentation/pages/noti_tab/image_dropzone.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../../room/presentations/bloc/area_bloc/area_bloc.dart';
import '../../../../room/presentations/bloc/area_bloc/area_event.dart';
import '../../../../room/presentations/bloc/area_bloc/area_state.dart';
import '../../bloc/noti/notification_bloc.dart';
import '../../bloc/noti/notification_event.dart';
import '../../bloc/noti/notification_state.dart';

// Widget cho trường tiêu đề
class TitleField extends StatelessWidget {
  final TextEditingController controller;

  const TitleField({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Tiêu đề',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập tiêu đề';
        }
        return null;
      },
    );
  }
}

// Widget cho chọn đối tượng nhận
class RecipientSelector extends StatelessWidget {
  final String? recipientType;
  final ValueChanged<String?> onChanged;
  final int? areaId;
  final ValueChanged<int?> onAreaChanged;
  final TextEditingController emailController;
  final TextEditingController roomNameController;

  const RecipientSelector({
    Key? key,
    required this.recipientType,
    required this.onChanged,
    required this.areaId,
    required this.onAreaChanged,
    required this.emailController,
    required this.roomNameController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (recipientType == 'ALL') {
      return const Text(
        'Thông báo "Chung" sẽ gửi đến tất cả người dùng.',
        style: TextStyle(fontSize: 12, color: Colors.grey),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: recipientType,
          decoration: const InputDecoration(
            labelText: 'Đối tượng nhận',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'ALL', child: Text('Tất cả người dùng')),
            DropdownMenuItem(value: 'USER', child: Text('Người dùng')),
            DropdownMenuItem(value: 'ROOM', child: Text('Phòng')),
          ],
          onChanged: onChanged,
          validator: (value) {
            if (value == null) {
              return 'Vui lòng chọn đối tượng nhận';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        if (recipientType == 'USER')
          TextFormField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Email người dùng',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Email không hợp lệ';
              }
              return null;
            },
          ),
        if (recipientType == 'ROOM') ...[
          BlocBuilder<AreaBloc, AreaState>(
            builder: (context, areaState) {
              if (areaState.isLoading) {
                return const CircularProgressIndicator();
              }
              if (areaState.error != null) {
                return Text(
                  'Lỗi: ${areaState.error}',
                  style: const TextStyle(color: Colors.red),
                );
              }
              return DropdownButtonFormField<int>(
                value: areaId,
                decoration: const InputDecoration(
                  labelText: 'Khu vực',
                  border: OutlineInputBorder(),
                ),
                items: areaState.areas.map((area) {
                  return DropdownMenuItem<int>(
                    value: area.areaId,
                    child: Text(area.name),
                  );
                }).toList(),
                onChanged: onAreaChanged,
                validator: (value) {
                  if (value == null) {
                    return 'Vui lòng chọn khu vực';
                  }
                  return null;
                },
              );
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: roomNameController,
            decoration: const InputDecoration(
              labelText: 'Tên phòng',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập tên phòng';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }
}

class CreateNotificationDialog extends StatefulWidget {
  const CreateNotificationDialog({Key? key}) : super(key: key);

  @override
  _CreateNotificationDialogState createState() => _CreateNotificationDialogState();
}

class _CreateNotificationDialogState extends State<CreateNotificationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _emailController = TextEditingController();
  final _roomNameController = TextEditingController();
  String? _recipientType;
  int? _areaId;
  List<Map<String, dynamic>> _media = [];
  List<String> _altTexts = [];
  bool _isProcessing = false;
  int _pendingOperations = 0;
  bool _hasShownSuccessMessage = false;
  bool _hasShownErrorMessage = false;
  bool _isSubmitting = false;
  bool _isRefreshing = false;
  static const int MAX_FILES = 20; // Tăng từ 15 lên 20
  static const int MAX_VIDEOS = 1;
  static const int MAX_IMAGES = 10;
  static const int MAX_DOCUMENTS = 5;
  bool _exceedsFileLimit = false;
  bool _exceedsVideoLimit = false;
  bool _exceedsImageLimit = false;
  bool _exceedsDocumentLimit = false;
  Key _mediaDropzoneKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    context.read<AreaBloc>().add(FetchAreasEvent(page: 1, limit: 100));
    _clearAllFields();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _emailController.dispose();
    _roomNameController.dispose();
    super.dispose();
  }

  void _updatePendingOperations(int change) {
    setState(() {
      _pendingOperations += change;
      _isProcessing = _pendingOperations > 0;
      print('Pending operations: $_pendingOperations, IsProcessing: $_isProcessing');
    });
  }

  void _clearAllFields() {
    _titleController.clear();
    _messageController.clear();
    _emailController.clear();
    _roomNameController.clear();
    setState(() {
      _recipientType = null;
      _areaId = null;
      _media = [];
      _altTexts = [];
      _exceedsFileLimit = false;
      _exceedsVideoLimit = false;
      _exceedsImageLimit = false;
      _exceedsDocumentLimit = false;
      _hasShownSuccessMessage = false;
      _hasShownErrorMessage = false;
      _isSubmitting = false;
      _isRefreshing = false;
      _mediaDropzoneKey = UniqueKey();
    });
  }

  Future<void> _createNotification() async {
    if (_isProcessing || _exceedsFileLimit || _exceedsVideoLimit || _exceedsImageLimit || _exceedsDocumentLimit || _isSubmitting) return;

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });
      _updatePendingOperations(1);

      try {
        List<http.MultipartFile> multipartFiles = [];
        print('Media list before processing: $_media');
        for (var mediaItem in _media) {
          final XFile file = mediaItem['file'] as XFile;
          final filename = mediaItem['name'] as String;
          final bytes = await file.readAsBytes();
          print('Processing media item: $filename, bytes length: ${bytes.length}');
          multipartFiles.add(http.MultipartFile.fromBytes(
            'media',
            bytes,
            filename: filename,
          ));
        }
        print('Multipart files created: ${multipartFiles.length}');

        context.read<NotificationBloc>().add(CreateNotificationEvent(
          title: _titleController.text,
          message: _messageController.text,
          targetType: _recipientType!,
          email: _recipientType == 'USER' ? _emailController.text : null,
          roomName: _recipientType == 'ROOM' ? _roomNameController.text : null,
          areaId: _recipientType == 'ROOM' ? _areaId : null,
          media: multipartFiles.isNotEmpty ? multipartFiles : null,
          altTexts: _altTexts.isNotEmpty ? _altTexts : null,
        ));
      } catch (e) {
        print('Error creating notification: $e');
        _updatePendingOperations(-1);
        if (!_hasShownErrorMessage) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
          setState(() {
            _hasShownErrorMessage = true;
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: LayoutBuilder(
            builder: (context, constraints) {
              double screenWidth = MediaQuery.of(context).size.width;
              double screenHeight = MediaQuery.of(context).size.height;

              double dialogWidth = screenWidth < 600
                  ? screenWidth * 0.9
                  : screenWidth < 1200
                  ? screenWidth * 0.7
                  : 800;
              double dialogHeight = screenHeight < 600
                  ? screenHeight * 0.9
                  : screenHeight < 900
                  ? screenHeight * 0.8
                  : 700;

              return Container(
                width: dialogWidth,
                height: dialogHeight,
                padding: const EdgeInsets.all(24),
                child: BlocListener<NotificationBloc, NotificationState>(
                  listener: (context, state) {
                    print('NotificationBloc state: $state');
                    if (state is NotificationCreated && !_hasShownSuccessMessage) {
                      print('Notification Created Successfully');
                      setState(() {
                        _hasShownSuccessMessage = true;
                        _isRefreshing = true;
                        _isProcessing = true;
                      });
                      _clearAllFields();
                      _updatePendingOperations(-1);
                      context.read<NotificationBloc>().add(const ResetNotificationStateEvent());
                      context.read<NotificationBloc>().add(const GetAllNotificationsEvent());
                    } else if (state is NotificationsLoaded && _isRefreshing) {
                      print('Notifications Loaded, showing success and closing dialog');
                      Future.delayed(const Duration(seconds: 2), () {
                        if (mounted) {
                          setState(() {
                            _isRefreshing = false;
                            _isProcessing = false;
                          });
                          Navigator.of(context).pop();
                        }
                      });
                    } else if (state is NotificationError) {
                      print('Notification Error: ${state.message}, closing dialog');
                      setState(() {
                        _isRefreshing = false;
                        _isSubmitting = false;
                        _isProcessing = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Lỗi: ${state.message}'),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                      if (mounted) {
                        Navigator.of(context).pop();
                      }
                    }
                  },
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Tạo Thông báo Mới',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                _clearAllFields();
                                Navigator.of(context).pop();
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
                                TitleField(controller: _titleController),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _messageController,
                                  decoration: const InputDecoration(
                                    labelText: 'Nội dung',
                                    border: OutlineInputBorder(),
                                  ),
                                  maxLines: 5,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Vui lòng nhập nội dung';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                RecipientSelector(
                                  recipientType: _recipientType,
                                  onChanged: (value) {
                                    setState(() {
                                      _recipientType = value;
                                      _areaId = null;
                                      _emailController.clear();
                                      _roomNameController.clear();
                                    });
                                  },
                                  areaId: _areaId,
                                  onAreaChanged: (value) {
                                    setState(() {
                                      _areaId = value;
                                      _roomNameController.clear();
                                    });
                                  },
                                  emailController: _emailController,
                                  roomNameController: _roomNameController,
                                ),
                                const SizedBox(height: 16),
                                MediaDropzone(
                                  key: _mediaDropzoneKey,
                                  onMediaDropped: (media, altTexts) {
                                    print('Media dropped: $media');
                                    print('Alt texts: $altTexts');
                                    setState(() {
                                      int videoCount = media.where((item) {
                                        String filename = item['name'] as String;
                                        return filename.toLowerCase().endsWith('.mp4') || filename.toLowerCase().endsWith('.avi');
                                      }).length;
                                      int imageCount = media.where((item) => item['fileType'] == 'image').length;
                                      int documentCount = media.where((item) => item['fileType'] == 'document').length;

                                      _media = media;
                                      _altTexts = altTexts;
                                      _exceedsFileLimit = media.length > MAX_FILES;
                                      _exceedsVideoLimit = videoCount > MAX_VIDEOS;
                                      _exceedsImageLimit = imageCount > MAX_IMAGES;
                                      _exceedsDocumentLimit = documentCount > MAX_DOCUMENTS;
                                    });
                                  },
                                  initialMedia: const [],
                                  initialAltTexts: const [],
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
                                _clearAllFields();
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                'Hủy',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: (_isProcessing || _exceedsFileLimit || _exceedsVideoLimit || _exceedsImageLimit || _exceedsDocumentLimit || _isSubmitting)
                                  ? null
                                  : _createNotification,
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
                                      'Tạo',
                                      style: TextStyle(color: Colors.white),
                                    ),
                            ),
                          ],
                        ),
                        if (_exceedsFileLimit)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Số lượng file vượt quá giới hạn ($MAX_FILES). Vui lòng giảm số lượng file.',
                              style: const TextStyle(color: Colors.red, fontSize: 14),
                            ),
                          ),
                        if (_exceedsVideoLimit)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Số lượng video vượt quá giới hạn ($MAX_VIDEOS). Vui lòng giảm số lượng video.',
                              style: const TextStyle(color: Colors.red, fontSize: 14),
                            ),
                          ),
                        if (_exceedsImageLimit)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Số lượng ảnh vượt quá giới hạn ($MAX_IMAGES). Vui lòng giảm số lượng ảnh.',
                              style: const TextStyle(color: Colors.red, fontSize: 14),
                            ),
                          ),
                        if (_exceedsDocumentLimit)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Số lượng tài liệu vượt quá giới hạn ($MAX_DOCUMENTS). Vui lòng giảm số lượng tài liệu.',
                              style: const TextStyle(color: Colors.red, fontSize: 14),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (_isProcessing || _isRefreshing)
          Container(
            color: Colors.black54,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  if (_hasShownSuccessMessage && _isRefreshing) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Cập nhật thành công!',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}