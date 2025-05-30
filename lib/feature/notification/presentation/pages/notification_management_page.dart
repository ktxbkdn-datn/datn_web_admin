// lib/src/features/notification/presentations/notification_management_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widget/custom_drawer.dart';
import '../bloc/noti/notification_bloc.dart';
import '../bloc/noti/notification_event.dart';
import '../bloc/noti/notification_state.dart';
import '../bloc/noti_media/notification_media_bloc.dart';
import '../bloc/noti_media/notification_media_state.dart';
import 'noti_tab/notification_list_page.dart';

class NotificationManagementPage extends StatefulWidget {
  const NotificationManagementPage({Key? key}) : super(key: key);

  @override
  _NotificationManagementPageState createState() => _NotificationManagementPageState();
}

class _NotificationManagementPageState extends State<NotificationManagementPage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Khởi tạo dữ liệu cho tab
    context.read<NotificationBloc>().add(const GetAllNotificationsEvent(page: 1, limit: 12));
  }

  void _onDrawerItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Xử lý điều hướng dựa trên index
    if (index == 0) {
      // "Dashboard" - Điều hướng đến route '/dashboard'
      Navigator.pushNamed(context, '/dashboard');
    }
    // Chỉ có 1 tab (NotificationListPage), nên không cần điều hướng tab
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<NotificationBloc, NotificationState>(
            listener: (context, state) {
              if (state is NotificationError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi: ${state.message}')),
                );
              }
            },
          ),
          BlocListener<NotificationMediaBloc, NotificationMediaState>(
            listener: (context, state) {
              if (state is NotificationMediaError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi: ${state.message}')),
                );
              }
            },
          ),
        ],
        child: Row(
          children: [
            CustomDrawer(
              title: 'Quản lý Thông báo',
              headerIcon: Iconsax.notification,
              items: [
                DrawerItem(
                  title: 'Dashboard',
                  icon: Iconsax.home,
                  route: '/dashboard',
                ),
                DrawerItem(
                  title: 'Danh sách Thông báo',
                  icon: Iconsax.message_text,
                ),
              ],
              selectedIndex: _selectedIndex,
              onTap: _onDrawerItemTap,
            ),
            Expanded(
              child: Container(
                color: Colors.grey[50],
                child: const NotificationListPage(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}