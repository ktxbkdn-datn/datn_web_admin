// lib/src/features/report/presentations/tabs/user_page.dart
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
    context.read<UserBloc>().add(FetchUsersEvent());
    // Đặt tab mặc định là "Danh sách Người dùng" (index 1 trong drawer, tab 0 trong TabBarView)
    _selectedIndex = 1;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onDrawerItemTap(int index) {
    setState(() {
      _selectedIndex = index;
      // Đồng bộ với TabController
      if (index == 1) {
        // "Danh sách Người dùng" (index 1) ánh xạ với tab 0
        _tabController.animateTo(0);
      } else if (index == 2) {
        // "Tạo Người dùng" (index 2) ánh xạ với tab 1
        _tabController.animateTo(1);
      } else if (index == 0) {
        // "Dashboard" (index 0) không thuộc TabBarView, có thể điều hướng sang route khác
        Navigator.pushNamed(context, '/dashboard');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          // Không hiển thị thông báo ở đây, để EditUserDialog xử lý
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