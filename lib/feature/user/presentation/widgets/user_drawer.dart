import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../common/widget/custom_drawer.dart';
class UserDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  final TabController tabController;

  const UserDrawer({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
    required this.tabController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomDrawer(
      title: 'Quản lý Người dùng',
      headerIcon: Iconsax.people,
      items: [
        DrawerItem(
          title: 'Trang chủ',
          icon: Iconsax.home,
          route: '/dashboard',
        ),
        DrawerItem(
          title: 'Danh sách Người dùng',
          icon: Icons.list,
        ),
        DrawerItem(
          title: 'Tạo Người dùng',
          icon: Icons.add,
        ),
      ],
      selectedIndex: selectedIndex,
      onTap: onTap,

    );
  }
}