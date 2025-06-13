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
      title: 'Quản lý sinh viên',
      headerIcon: Iconsax.people,
      items: [
        DrawerItem(
          title: 'Trang chủ',
          icon: Iconsax.home,
          route: '/dashboard',
        ),
        DrawerItem(
          title: 'Danh sách sinh viên',
          icon: Icons.list,
        ),
        DrawerItem(
          title: 'Tạo sinh viên mới',
          icon: Icons.add,
        ),
      ],
      selectedIndex: selectedIndex,
      onTap: onTap,

    );
  }
}