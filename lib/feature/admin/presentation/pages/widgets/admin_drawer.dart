import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../common/widget/custom_drawer.dart';


class AdminDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  final TabController tabController;

  const AdminDrawer({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
    required this.tabController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomDrawer(
      title: 'Quản lý Admin',
      headerIcon: Icons.admin_panel_settings,
      items: [
        DrawerItem(
          title: 'Trang chủ',
          icon: Iconsax.home,
          route: '/dashboard',
        ),
        DrawerItem(
          title: 'Thông tin Admin',
          icon: Icons.person,
        ),
        DrawerItem(
          title: 'Danh sách Admin',
          icon: Icons.list,
        ),
        DrawerItem(
          title: 'Tạo Admin',
          icon: Icons.add,
        ),
        DrawerItem(
          title: 'Đổi Mật khẩu',
          icon: Icons.lock,
        ),
      ],
      selectedIndex: selectedIndex,
      onTap: onTap,

    );
  }
}