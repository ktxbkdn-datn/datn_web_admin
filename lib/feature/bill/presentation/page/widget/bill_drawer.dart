import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:datn_web_admin/common/widget/custom_drawer.dart';

class BillDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  final TabController tabController;

  const BillDrawer({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
    required this.tabController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomDrawer(
      title: 'Quản lý Hóa đơn',
      headerIcon: Iconsax.receipt,
      items:  [
        DrawerItem(
          title: 'Dashboard',
          icon: Iconsax.home,
          route: '/dashboard',
        ),
        DrawerItem(
          title: 'Danh sách Hóa đơn',
          icon: Iconsax.document,
        ),
        DrawerItem(
          title: 'Danh sách báo cáo chỉ số',
          icon: Iconsax.bill,
        ),
      ],
      selectedIndex: selectedIndex,
      onTap: onTap,
    );
  }
}