// lib/src/features/auth/presentation/widgets/auth_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';

class AuthForm extends StatefulWidget {
  final bool isAdmin;
  final void Function(String username, String password) onSubmit;

  const AuthForm({
    Key? key,
    required this.isAdmin,
    required this.onSubmit,
  }) : super(key: key);

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Username or Email Field
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                hintText: widget.isAdmin ? 'Tài khoản' : 'Email',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(
                  widget.isAdmin ? Icons.person : Icons.email,
                  color: Colors.grey,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return widget.isAdmin ? 'Tài khoản không được để trống' : 'Email không được để trống';
                }
                if (!widget.isAdmin) {
                  final emailRegex = RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$');
                  if (!emailRegex.hasMatch(value)) return 'Định dạng email không hợp lệ';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Password Field
            TextFormField(
              controller: _passwordController,
              obscureText: _obscureText,
              decoration: InputDecoration(
                hintText: 'Mật khẩu',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
              ),
              // validator: (value) {
              //   if (value == null || value.isEmpty) return 'Mật khẩu không được để trống';
              //   if (value.length < 12) return 'Mật khẩu phải có ít nhất 12 ký tự';
              //   if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Mật khẩu phải chứa chữ hoa';
              //   if (!RegExp(r'[a-z]').hasMatch(value)) return 'Mật khẩu phải chứa chữ thường';
              //   if (!RegExp(r'[0-9]').hasMatch(value)) return 'Mật khẩu phải chứa số';
              //   if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
              //     return 'Mật khẩu phải chứa ký tự đặc biệt';
              //   }
              //   return null;
              // },
            ),
            const SizedBox(height: 24),
            // Login Button
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                return state.isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      widget.onSubmit(
                        _usernameController.text,
                        _passwordController.text,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Đăng nhập',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}