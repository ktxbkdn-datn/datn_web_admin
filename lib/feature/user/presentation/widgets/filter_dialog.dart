// lib/src/features/user/presentation/widgets/filter_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/user_bloc.dart';
import '../bloc/user_event.dart';

class FilterDialog extends StatefulWidget {
  const FilterDialog({Key? key}) : super(key: key);

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  final _emailController = TextEditingController();
  final _fullnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _classNameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _fullnameController.dispose();
    _phoneController.dispose();
    _classNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Lọc Người dùng'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _fullnameController,
              decoration: const InputDecoration(labelText: 'Họ và tên'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Số điện thoại'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _classNameController,
              decoration: const InputDecoration(labelText: 'Lớp'),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            _emailController.clear();
            _fullnameController.clear();
            _phoneController.clear();
            _classNameController.clear();
            context.read<UserBloc>().add(FetchUsersEvent());
            Navigator.pop(context);
          },
          child: const Text('Xóa bộ lọc'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        TextButton(
          onPressed: () {
            context.read<UserBloc>().add(FetchUsersEvent(
              email: _emailController.text.isNotEmpty ? _emailController.text : null,
              fullname: _fullnameController.text.isNotEmpty ? _fullnameController.text : null,
              phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
              className: _classNameController.text.isNotEmpty ? _classNameController.text : null,
            ));
            Navigator.pop(context);
          },
          child: const Text('Lọc'),
        ),
      ],
    );
  }
}