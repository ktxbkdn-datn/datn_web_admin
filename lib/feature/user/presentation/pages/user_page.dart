import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/user_bloc.dart';
import '../bloc/user_event.dart';
import '../bloc/user_state.dart';
import '../widgets/create_user_tab.dart';
import '../widgets/user_drawer.dart';
import '../widgets/user_list_tab.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedIndex = 1; // Default to "Danh sách Người dùng" tab
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onDrawerItemTap(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 1) {
        _tabController.animateTo(0); // "Danh sách Người dùng" tab
      } else if (index == 2) {
        _tabController.animateTo(1); // "Tạo Người dùng" tab
      } else if (index == 0) {
        Navigator.pushNamed(context, '/dashboard'); // Navigate to Dashboard
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is UserDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Xóa sinh viên dùng thành công!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          } else if (state is UserCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tạo sinh viên mới dùng thành công!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          } else if (state is UserUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cập nhật sinh viên thành công!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        child: Row(
          children: [
            UserDrawer(
              selectedIndex: _selectedIndex,
              onTap: _onDrawerItemTap,
              tabController: _tabController,
            ),
            Expanded(
              child: Container(
                color: Colors.grey[50],
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [
                    UserListTab(),
                    CreateUserTab(),
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