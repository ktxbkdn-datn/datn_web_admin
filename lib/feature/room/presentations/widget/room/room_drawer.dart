import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../common/widget/custom_drawer.dart';

class RoomDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  final TabController tabController;
  final Function(bool)? onExpansionChanged;

  const RoomDrawer({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
    required this.tabController,
    this.onExpansionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomDrawer(
      title: 'Quản lý Phòng',
      headerIcon: Iconsax.house,
      items: [
        DrawerItem(
          title: 'Trang chủ',
          icon: Iconsax.home,
          route: '/dashboard',
        ),
        DrawerItem(
          title: 'Danh sách Phòng',
          icon: Icons.meeting_room,
        ),
        DrawerItem(
          title: 'Quản lý Khu vực',
          icon: Icons.location_city,
        ),
      ],
      selectedIndex: selectedIndex,
      onTap: onTap,

      onExpansionChanged: onExpansionChanged,
    );
  }
}