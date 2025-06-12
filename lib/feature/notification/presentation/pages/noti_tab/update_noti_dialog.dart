import 'package:datn_web_admin/feature/notification/presentation/bloc/noti/notification_bloc.dart';
import 'package:datn_web_admin/feature/notification/presentation/bloc/noti/notification_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../../../domain/entities/notification_entity.dart' as entity;


class UpdateNotificationDialog extends StatefulWidget {
  final entity.Notification notification;

  const UpdateNotificationDialog({super.key, required this.notification});

  @override
  UpdateNotificationDialogState createState() => UpdateNotificationDialogState();
}

class UpdateNotificationDialogState extends State<UpdateNotificationDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _messageController;
  late TextEditingController _emailController;
  late TextEditingController _roomNameController;
  String? _areaId;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController(text: widget.notification.message);
    _emailController = TextEditingController();
    _roomNameController = TextEditingController();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _emailController.dispose();
    _roomNameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<NotificationBloc>().add(UpdateNotificationEvent(
        notificationId: widget.notification.notificationId!,
        message: _messageController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        roomName: _roomNameController.text.isEmpty ? null : _roomNameController.text,
        areaId: _areaId != null ? int.tryParse(_areaId!) : null,
      ));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: const [
          Icon(Icons.edit, color: Colors.blue),
          SizedBox(width: 8),
          Text('Chỉnh sửa thông báo', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: SizedBox(
        width: 600, // Tăng width lên
        height: 500, // Tăng height lên
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    labelText: 'Nội dung',
                    prefixIcon: const Icon(Icons.message_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Vui lòng nhập nội dung' : null,
                  maxLines: 20,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close, color: Colors.red),
          label: const Text('Hủy'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
          ),
        ),
        ElevatedButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.save),
          label: const Text('Cập nhật'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }
}