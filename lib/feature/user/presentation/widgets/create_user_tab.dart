import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../common/constants/colors.dart';
import '../bloc/user_bloc.dart';
import '../bloc/user_event.dart';
import '../bloc/user_state.dart';

class CreateUserTab extends StatefulWidget {
  const CreateUserTab({Key? key}) : super(key: key);

  @override
  _CreateUserTabState createState() => _CreateUserTabState();
}

class _CreateUserTabState extends State<CreateUserTab> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<UserBloc>().add(CreateUserEvent(
        email: _emailController.text,
        fullname: _fullNameController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
      ));
    }
  }

  void _clearFields() {
    _emailController.clear();
    _fullNameController.clear();
    _phoneController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.glassmorphismStart, AppColors.glassmorphismEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        SafeArea(
          child: Center(
            child: MultiBlocListener(
              listeners: [
                BlocListener<UserBloc, UserState>(
                  listener: (context, state) {
                    if (state is UserCreated) {
                      _clearFields(); // Clear các TextField khi tạo thành công
                    }
                  },
                ),
              ],
              child: BlocBuilder<UserBloc, UserState>(
                builder: (context, state) {
                  bool isLoading = state is UserLoading;

                  return Dialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: Colors.white,
                    elevation: 8,
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
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Tạo sinh viên Mới',
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
                                          controller: _emailController,
                                          decoration: InputDecoration(
                                            labelText: 'Email',
                                            labelStyle: const TextStyle(color: Colors.grey),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: const BorderSide(color: Colors.grey),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: const BorderSide(color: Colors.blue),
                                            ),
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 10,
                                            ),
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
                                          controller: _fullNameController,
                                          decoration: InputDecoration(
                                            labelText: 'Họ và Tên',
                                            labelStyle: const TextStyle(color: Colors.grey),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: const BorderSide(color: Colors.grey),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: const BorderSide(color: Colors.blue),
                                            ),
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 10,
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Họ và Tên không được để trống';
                                            }
                                            if (value.length < 2) {
                                              return 'Họ và Tên phải có ít nhất 2 ký tự';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        TextFormField(
                                          controller: _phoneController,
                                          decoration: InputDecoration(
                                            labelText: 'Số điện thoại (Tùy chọn)',
                                            labelStyle: const TextStyle(color: Colors.grey),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: const BorderSide(color: Colors.grey),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: const BorderSide(color: Colors.blue),
                                            ),
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 10,
                                            ),
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
                                          onSaved: (value) {
                                            if (value != null && value.isNotEmpty) {
                                              String cleanedValue = value.replaceAll(RegExp(r'[^0-9\+]'), '');
                                              if (cleanedValue.startsWith('0')) {
                                                cleanedValue = '+84${cleanedValue.substring(1)}';
                                              }
                                              _phoneController.text = cleanedValue;
                                            }
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
                                  ElevatedButton(
                                    onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    ),
                                    child: const Text(
                                      'Hủy',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  ElevatedButton(
                                    onPressed: isLoading ? null : _submit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          'Tạo',
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
              ),
            ),
          ),
        ),
      ],
    );
  }
}