// lib/src/features/user/presentation/widgets/add_user_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/user_bloc.dart';
import '../bloc/user_event.dart';

class AddUserDialog extends StatelessWidget {
  const AddUserDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final fullNameController = TextEditingController();
    final phoneController = TextEditingController();

    return AlertDialog(
      title: const Text('Thêm Người dùng'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: fullNameController,
              decoration: const InputDecoration(labelText: 'Họ và tên'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Số điện thoại'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        TextButton(
          onPressed: () {
            context.read<UserBloc>().add(CreateUserEvent(
              email: emailController.text,
              fullname: fullNameController.text,
              phone: phoneController.text.isNotEmpty ? phoneController.text : null,
            ));
            Navigator.pop(context);
          },
          child: const Text('Thêm'),
        ),
      ],
    );
  }
}