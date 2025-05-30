// lib/src/features/notification/presentations/widgets/edit_notification_type_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/notification_type_entity.dart';
import '../../bloc/noti_type/notification_type_bloc.dart';
import '../../bloc/noti_type/notification_type_event.dart';
import '../../bloc/noti_type/notification_type_state.dart';

class EditNotificationTypeDialog extends StatefulWidget {
  final NotificationType notificationType;

  const EditNotificationTypeDialog({Key? key, required this.notificationType}) : super(key: key);

  @override
  _EditNotificationTypeDialogState createState() => _EditNotificationTypeDialogState();
}

class _EditNotificationTypeDialogState extends State<EditNotificationTypeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _status;
  bool _isProcessing = false;
  int _pendingOperations = 0;
  bool _hasShownSuccessMessage = false;
  bool _hasShownErrorMessage = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.notificationType.name;
    _descriptionController.text = widget.notificationType.description ?? '';
    _status = widget.notificationType.status ?? 'ROOM'; // Giả sử status hiện tại từ API
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updatePendingOperations(int change) {
    setState(() {
      _pendingOperations += change;
      _isProcessing = _pendingOperations > 0;
      print('Pending operations: $_pendingOperations, IsProcessing: $_isProcessing');
    });
  }

  Future<void> _updateNotificationType() async {
    if (_isProcessing) return;

    if (_formKey.currentState!.validate()) {
      _updatePendingOperations(1);

      try {
        context.read<NotificationTypeBloc>().add(UpdateNotificationTypeEvent(
          typeId: widget.notificationType.typeId!,
          name: _nameController.text,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
          status: _status!,
        ));
      } catch (e) {
        print('Error updating notification type: $e');
        _updatePendingOperations(-1);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
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
                  : 600;

              return Container(
                width: dialogWidth,
                height: dialogHeight,
                padding: const EdgeInsets.all(24),
                child: BlocListener<NotificationTypeBloc, NotificationTypeState>(
                  listener: (context, state) {
                    if (state is NotificationTypeUpdated && !_hasShownSuccessMessage) {
                      print('Notification Type Updated Successfully');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cập nhật loại thông báo thành công!'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                      setState(() {
                        _hasShownSuccessMessage = true;
                      });
                      _updatePendingOperations(-1);
                      Future.delayed(const Duration(seconds: 2), () {
                        if (mounted) {
                          Navigator.of(context).pop();
                        }
                      });
                    } else if (state is NotificationTypeError && !_hasShownErrorMessage) {
                      print('Notification Type Update Error: ${state.message}');
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
                      _updatePendingOperations(-1);
                    }
                  },
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Chỉnh sửa Loại Thông báo',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  controller: _nameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Tên loại thông báo',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Tên không được để trống';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _descriptionController,
                                  decoration: const InputDecoration(
                                    labelText: 'Mô tả',
                                    border: OutlineInputBorder(),
                                  ),
                                  maxLines: 3,
                                ),
                                const SizedBox(height: 16),
                                DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: 'Đối tượng áp dụng',
                                    border: OutlineInputBorder(),
                                  ),
                                  value: _status,
                                  items: const [
                                    DropdownMenuItem(value: 'ALL', child: Text('Tất cả')),
                                    DropdownMenuItem(value: 'ROOM', child: Text('Phòng')),
                                    DropdownMenuItem(value: 'USER', child: Text('Người dùng')),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _status = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Vui lòng chọn đối tượng áp dụng';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
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
                            onPressed: _isProcessing ? null : _updateNotificationType,
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
}