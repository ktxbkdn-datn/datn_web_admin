import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/user_entity.dart';
import '../bloc/user_bloc.dart';
import '../bloc/user_event.dart';
import '../bloc/user_state.dart';

class EditUserDialog extends StatefulWidget {
  final UserEntity user;

  const EditUserDialog({Key? key, required this.user}) : super(key: key);

  @override
  _EditUserDialogState createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cccdController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _classNameController = TextEditingController();
  final _hometownController = TextEditingController();
  final _studentCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fullNameController.text = widget.user.fullname;
    _emailController.text = widget.user.email;
    _phoneController.text = widget.user.phone ?? '';
    _cccdController.text = widget.user.cccd ?? '';
    _dateOfBirthController.text = widget.user.dateOfBirth != null
        ? DateFormat('dd-MM-yyyy').format(widget.user.dateOfBirth!)
        : '';
    _classNameController.text = widget.user.className ?? '';
    _hometownController.text = widget.user.hometown ?? '';
    _studentCodeController.text = widget.user.studentCode ?? '';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cccdController.dispose();
    _dateOfBirthController.dispose();
    _classNameController.dispose();
    _hometownController.dispose();
    _studentCodeController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      DateTime? dateOfBirth;
      if (_dateOfBirthController.text.isNotEmpty) {
        try {
          dateOfBirth = DateFormat('dd-MM-yyyy').parse(_dateOfBirthController.text);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Định dạng ngày sinh không hợp lệ (dd-MM-yyyy)'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
          return;
        }
      }
      context.read<UserBloc>().add(UpdateUserEvent(
        userId: widget.user.userId,
        fullname: _fullNameController.text.isNotEmpty ? _fullNameController.text : null,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        cccd: _cccdController.text.isNotEmpty ? _cccdController.text : null,
        dateOfBirth: dateOfBirth,
        className: _classNameController.text.isNotEmpty ? _classNameController.text : null,
        hometown: _hometownController.text.isNotEmpty ? _hometownController.text : null,
        studentCode: _studentCodeController.text.isNotEmpty ? _studentCodeController.text : null,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        bool isLoading = state is UserLoading;

        return Dialog(
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
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Cập nhật sinh viên',
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
                                controller: _fullNameController,
                                decoration: const InputDecoration(
                                  labelText: 'Họ và tên',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Họ và tên không được để trống';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Email không được để trống';
                                  }
                                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                    return 'Email không hợp lệ';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _phoneController,
                                decoration: const InputDecoration(
                                  labelText: 'Số điện thoại',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    if (!RegExp(r'^(0|\+84)\d{9}$').hasMatch(value)) {
                                      return 'Số điện thoại phải bắt đầu bằng 0 hoặc +84 và có 10 chữ số (ví dụ: 0901234567 hoặc +84901234567)';
                                    }
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _cccdController,
                                decoration: const InputDecoration(
                                  labelText: 'CCCD',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _dateOfBirthController,
                                decoration: const InputDecoration(
                                  labelText: 'Ngày sinh (dd-MM-yyyy)',
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.calendar_today),
                                ),
                                keyboardType: TextInputType.datetime,
                                readOnly: true, // Chỉ cho phép chọn, không cho phép gõ tay
                                onTap: () async {
                                  FocusScope.of(context).requestFocus(FocusNode());
                                  DateTime initialDate = DateTime.now();
                                  if (_dateOfBirthController.text.isNotEmpty) {
                                    try {
                                      initialDate = DateFormat('dd-MM-yyyy').parse(_dateOfBirthController.text);
                                    } catch (_) {}
                                  }
                                  DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: initialDate,
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime.now(),
                                    locale: const Locale('vi', 'VN'),
                                  );
                                  if (picked != null) {
                                    _dateOfBirthController.text = DateFormat('dd-MM-yyyy').format(picked);
                                  }
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _classNameController,
                                decoration: const InputDecoration(
                                  labelText: 'Lớp',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _hometownController,
                                decoration: const InputDecoration(
                                  labelText: 'Quê quán',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _studentCodeController,
                                decoration: const InputDecoration(
                                  labelText: 'Mã số sinh viên',
                                  border: OutlineInputBorder(),
                                ),
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
                          onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                          child: const Text(
                            'Hủy',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Lưu',
                                style: TextStyle(color: Colors.white),
                              ),
                              if (isLoading) ...[
                                const SizedBox(width: 8),
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}