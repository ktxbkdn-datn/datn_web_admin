import 'package:datn_web_admin/feature/dashboard/presentation/pages/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:datn_web_admin/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:datn_web_admin/feature/auth/presentation/bloc/auth_state.dart';
import 'package:datn_web_admin/feature/admin/presentation/bloc/admin_bloc.dart';
import 'package:datn_web_admin/feature/admin/presentation/bloc/admin_event.dart';
import 'package:datn_web_admin/feature/admin/presentation/bloc/admin_state.dart';
import 'widgets/admin_drawer.dart';
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
                content: Text('Lỗi: ${state.failure.message}'),
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
            AdminDrawer(
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
                  children: [
                    DashboardPage(), 
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