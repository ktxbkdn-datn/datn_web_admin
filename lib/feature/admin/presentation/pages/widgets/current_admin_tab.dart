import 'package:datn_web_admin/common/extensions/iterable_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../common/constants/colors.dart';
import '../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../domain/entities/admin_entity.dart';
import '../../bloc/admin_bloc.dart';
import '../../bloc/admin_event.dart';
import '../../bloc/admin_state.dart';


class CurrentAdminTab extends StatelessWidget {
  const CurrentAdminTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final paddingHorizontal = screenWidth > 1200 ? screenWidth * 0.1 : 16.0;

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
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: 16.0),
            child: BlocListener<AdminBloc, AdminState>(
              listener: (context, state) {
                if (state is AdminError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${state.failure.message}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                if (state is AdminUpdated && state.successMessage.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.successMessage),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: BlocBuilder<AdminBloc, AdminState>(
                builder: (context, state) {
                  if (state is AdminLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is AdminError) {
                    return Center(child: Text('Lỗi: ${state.failure.message}'));
                  }

                  AdminEntity? currentAdmin;

                  final authState = context.read<AuthBloc>().state;
                  final currentAdminId = authState.auth?.id;

                  if (state is AdminUpdated) {
                    currentAdmin = state.currentAdmin;
                  } else if (state is AdminListLoaded) {
                    currentAdmin = state.admins.firstWhereOrNull(
                          (admin) => admin.adminId == currentAdminId,
                    );
                  } else if (state is AdminDeleted) {
                    currentAdmin = state.admins.firstWhereOrNull(
                          (admin) => admin.adminId == currentAdminId,
                    );
                  } else if (state is AdminCreated) {
                    context.read<AdminBloc>().add(FetchAllAdminsEvent());
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (currentAdmin == null) {
                    return const Center(child: Text('Không tìm thấy thông tin admin'));
                  }

                  final fullNameController = TextEditingController(text: currentAdmin.fullName ?? '');
                  final emailController = TextEditingController(text: currentAdmin.email ?? '');
                  final phoneController = TextEditingController(text: currentAdmin.phone ?? '');

                  return Container(
                    padding: const EdgeInsets.all(24.0),
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
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Thông tin Admin',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                          _buildTextField('Họ và Tên', fullNameController),
                          const SizedBox(height: 16),
                          _buildTextField('Email', emailController),
                          const SizedBox(height: 16),
                          _buildTextField('Số điện thoại', phoneController),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: state is AdminLoading
                                    ? null
                                    : () {
                                  fullNameController.text = currentAdmin?.fullName ?? '';
                                  emailController.text = currentAdmin?.email ?? '';
                                  phoneController.text = currentAdmin?.phone ?? '';
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                child: const Text('Hủy', style: TextStyle(color: Colors.white)),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: state is AdminLoading
                                    ? null
                                    : () {
                                  context.read<AdminBloc>().add(UpdateAdminEvent(
                                    adminId: currentAdmin!.adminId,
                                    fullName: fullNameController.text.isEmpty ? null : fullNameController.text,
                                    email: emailController.text.isEmpty ? null : emailController.text,
                                    phone: phoneController.text.isEmpty ? null : phoneController.text,
                                  ));
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('Cập nhật Thông tin', style: TextStyle(color: Colors.white)),
                                    if (state is AdminLoading) ...[
                                      const SizedBox(width: 8),
                                      const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      ),
                                    ],
                                  ],
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
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}
