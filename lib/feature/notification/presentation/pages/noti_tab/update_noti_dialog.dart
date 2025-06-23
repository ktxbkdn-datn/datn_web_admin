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
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade600, Colors.blue.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.edit, color: Colors.white, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Chỉnh sửa thông báo',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        labelText: 'Nội dung',
                        labelStyle: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                        prefixIcon: Icon(Icons.message_outlined, color: Colors.grey.shade400),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade600, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập nội dung' : null,
                      maxLines: 10,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Colors.grey.shade100,
                            foregroundColor: Colors.grey.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                            textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                          child: const Text('Hủy'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            elevation: 2,
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            shadowColor: Colors.blue.shade100,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.save, size: 20),
                              SizedBox(width: 8),
                              Text('Cập nhật'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}