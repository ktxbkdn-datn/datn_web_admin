import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:datn_web_admin/common/widget/custom_drawer.dart';

class ServiceDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  final TabController tabController;

  const ServiceDrawer({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
    required this.tabController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomDrawer(
      title: 'Quản lý Dịch vụ',
      headerIcon: Iconsax.electricity,
      items:  [
        DrawerItem(
          title: 'Trang chủ',
          icon: Iconsax.home,
          route: '/dashboard',
        ),
        DrawerItem(
          title: 'Danh sách Dịch vụ',
          icon: Iconsax.chart,
        ),
      ],
      selectedIndex: selectedIndex,
      onTap: onTap,

    );
  }
}