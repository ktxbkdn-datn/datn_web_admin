import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'auth_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 2.5 / 4,
            child: Column(
              children: [
                Container(
                  color: const Color(0xFFF5F5F5),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(height: 50),
                        Container(
                          width: 500,
                          height: 500,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Image.asset(
                              'logo/logo.jpg',
                              errorBuilder: (context, error, stackTrace) {
                                print('Error loading image: $error');
                                return Container(
                                  width: 300,
                                  height: 300,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Lỗi khi tải logo',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'Địa chỉ: 60 Ngô Sỹ Liên, Hoà Khánh Bắc, Liên Chiểu, Đà Nẵng',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chào Mừng đến với\nKý Túc Xá Trường Đại học Bách Khoa\nĐại học Đà Nẵng',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 32),
                  DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 300,
                          child: AuthForm(
                            isAdmin: true,
                            onSubmit: (username, password, rememberMe) { // Cập nhật để nhận rememberMe
                              context.read<AuthBloc>().add(
                                AdminLoginSubmitted(
                                  username: username,
                                  password: password,
                                  rememberMe: rememberMe, 
                                  context: context,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Checkbox "Remember Me" đã được tích hợp trong AuthForm, không cần thêm ở đây nữa
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                        child: const Text(
                          'Quên Mật Khẩu?',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  BlocListener<AuthBloc, AuthState>(
                    listener: (context, state) {
                      print('AuthState updated: isLoading=${state.isLoading}, auth=${state.auth}, error=${state.error}, successMessage=${state.successMessage}');
                      if (state.auth != null) {
                        print('Navigating to DashboardPage');
                        Get.offAllNamed('/home'); // Sử dụng Get.offAllNamed
                      }
                      if (state.error != null) {
                        print('Showing error: ${state.error}');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.error!)),
                        );
                      }
                    },
                    child: Container(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}