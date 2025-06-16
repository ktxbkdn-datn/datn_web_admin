import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import '../bloc/user_bloc.dart';
import '../bloc/user_event.dart';
import '../bloc/user_state.dart';
import '../widgets/create_user_tab.dart';
import '../widgets/user_list_tab.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0; // 0: Danh sách, 1: Tạo mới

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.index = _selectedIndex;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${state.message}'),
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
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                  _tabController.index = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              backgroundColor: Colors.blueGrey[900],
              leading: IconButton(
                icon: const Icon(Iconsax.home, color: Colors.white),
                tooltip: 'Quay lại',
                onPressed: () => Navigator.pop(context),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.list, color: Colors.white),
                  selectedIcon: Icon(Icons.list, color: Colors.deepPurpleAccent),
                  label: Text('Danh sách Người dùng', style: TextStyle(color: Colors.white)),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.add, color: Colors.white),
                  selectedIcon: Icon(Icons.add, color: Colors.deepPurpleAccent),
                  label: Text('Tạo Người dùng', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
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