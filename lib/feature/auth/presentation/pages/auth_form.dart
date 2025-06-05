import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';

class AuthForm extends StatefulWidget {
  final bool isAdmin;
  final void Function(String username, String password, bool rememberMe) onSubmit;

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
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
  }

  Future<void> _loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('remember_me') ?? false;
    });
    if (_rememberMe) {
      _usernameController.text = prefs.getString('saved_username') ?? '';
      _passwordController.text = prefs.getString('saved_password') ?? '';
    }
  }

  Future<void> _saveRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me', _rememberMe);
    if (_rememberMe) {
      await prefs.setString('saved_username', _usernameController.text);
      await prefs.setString('saved_password', _passwordController.text);
    } else {
      await prefs.remove('saved_username');
      await prefs.remove('saved_password');
    }
  }

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
              validator: (value) {
                if (value == null || value.isEmpty) return 'Mật khẩu không được để trống';
                if (value.length < 12) return 'Mật khẩu phải có ít nhất 12 ký tự';
                if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Mật khẩu phải chứa chữ hoa';
                if (!RegExp(r'[a-z]').hasMatch(value)) return 'Mật khẩu phải chứa chữ thường';
                if (!RegExp(r'[0-9]').hasMatch(value)) return 'Mật khẩu phải chứa số';
                if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                  return 'Mật khẩu phải chứa ký tự đặc biệt';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // "Remember Me" Checkbox
            Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: (value) {
                    setState(() {
                      _rememberMe = value ?? false;
                    });
                  },
                ),
                const Text('Ghi nhớ tôi'),
              ],
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
                            _saveRememberMe();
                            widget.onSubmit(
                              _usernameController.text,
                              _passwordController.text,
                              _rememberMe,
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