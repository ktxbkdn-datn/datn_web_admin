import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../common/widget/custom_drawer.dart';


class RegistrationDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  final TabController tabController;

  const RegistrationDrawer({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
    required this.tabController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomDrawer(
      title: 'Quản lý Đăng ký',
      headerIcon: Iconsax.path,
      items: [
        DrawerItem(
          title: 'Dashboard',
          icon: Iconsax.home,
          route: '/dashboard',
        ),
        DrawerItem(
          title: 'Danh sách Đăng ký',
          icon: Icons.person,
        ),
      ],
      selectedIndex: selectedIndex,
      onTap: onTap,

    );
  }
}