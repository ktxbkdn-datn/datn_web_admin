import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../common/widget/custom_drawer.dart';

class ContractDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const ContractDrawer({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomDrawer(
      title: 'Quản lý Hợp đồng',
      headerIcon: Iconsax.document,
      items: [
        DrawerItem(
          title: 'Dashboard',
          icon: Iconsax.home,
          route: '/dashboard',
        ),
        DrawerItem(
          title: 'Danh sách hợp đồng',
          icon: Icons.description,
        ),
      ],
      selectedIndex: selectedIndex,
      onTap: onTap,
    );
  }
}