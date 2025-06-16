import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:datn_web_admin/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:datn_web_admin/feature/admin/presentation/bloc/admin_bloc.dart';
import 'package:datn_web_admin/feature/admin/presentation/bloc/admin_event.dart';
import 'package:datn_web_admin/feature/admin/presentation/bloc/admin_state.dart';
import 'package:iconsax/iconsax.dart';
import 'widgets/current_admin_tab.dart';
import 'admin_list_page.dart';
import 'widgets/create_admin_tab.dart';
import 'widgets/change_password_tab.dart';

class AdminManagementPage extends StatefulWidget {
  const AdminManagementPage({Key? key}) : super(key: key);

  @override
  _AdminManagementPageState createState() => _AdminManagementPageState();
}

class _AdminManagementPageState extends State<AdminManagementPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isExpanded = true;
  int _selectedIndex = 2; // Mặc định mở AdminListPage

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.index = _selectedIndex; // Đặt tab mặc định
    final authState = context.read<AuthBloc>().state;
    if (authState.auth != null) {
      context.read<AdminBloc>().add(FetchCurrentAdminEvent(authState.auth!.id));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onDrawerItemTap(int index) {
    setState(() {
      _selectedIndex = index;
      _tabController.index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AdminBloc, AdminState>(
        listener: (context, state) {
          if (state is AdminError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(' ${state.failure.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state is AdminCreated || state is AdminUpdated || state is AdminPasswordChanged || state is AdminDeleted) {
            String? successMessage;
            if (state is AdminCreated) successMessage = state.successMessage;
            if (state is AdminUpdated && state.successMessage.isNotEmpty) successMessage = state.successMessage;
            if (state is AdminPasswordChanged) successMessage = state.successMessage;
            if (state is AdminDeleted) successMessage = state.successMessage;
            if (successMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(successMessage),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
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
              labelType: NavigationRailLabelType.none, // Ẩn label
              backgroundColor: Colors.blueGrey[900],
              leading: IconButton(
                icon: const Icon(Iconsax.home, color: Colors.white),
                tooltip: 'Quay lại',
                onPressed: () => Navigator.pop(context),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Tooltip(
                    message: 'Thông tin Admin',
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  selectedIcon: Icon(Icons.person, color: Colors.deepPurpleAccent),
                  label: Text('Thông tin Admin'),
                ),
                NavigationRailDestination(
                  icon: Tooltip(
                    message: 'Danh sách Admin',
                    child: Icon(Icons.list, color: Colors.white),
                  ),
                  selectedIcon: Icon(Icons.list, color: Colors.deepPurpleAccent),
                  label: Text('Danh sách Admin'),
                ),
                NavigationRailDestination(
                  icon: Tooltip(
                    message: 'Tạo Admin',
                    child: Icon(Icons.add, color: Colors.white),
                  ),
                  selectedIcon: Icon(Icons.add, color: Colors.deepPurpleAccent),
                  label: Text('Tạo Admin'),
                ),
                NavigationRailDestination(
                  icon: Tooltip(
                    message: 'Đổi Mật khẩu',
                    child: Icon(Icons.lock, color: Colors.white),
                  ),
                  selectedIcon: Icon(Icons.lock, color: Colors.deepPurpleAccent),
                  label: Text('Đổi Mật khẩu'),
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
                  children: [
                    const CurrentAdminTab(),
                    const AdminListPage(),
                    CreateAdminTab(),
                    const ChangePasswordTab(),
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