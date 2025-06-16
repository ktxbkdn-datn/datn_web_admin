// import 'package:flutter/material.dart';
// import 'package:iconsax/iconsax.dart';
// import '../../../../common/widget/custom_drawer.dart';
// import '../pages/dashboard_page.dart';

// class DashboardDrawer extends StatelessWidget {
//   final int selectedIndex;
//   final Function(int) onTap;
//   final List<MenuItem> menuItems;

//   const DashboardDrawer({
//     Key? key,
//     required this.selectedIndex,
//     required this.onTap,
//     required this.menuItems,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     List<DrawerItem> drawerItems = menuItems.map((menuItem) {
//       return DrawerItem(
//         title: menuItem.title,
//         icon: menuItem.icon,
//         route: menuItem.route,
//       );
//     }).toList();

//     return CustomDrawer(
//       title: 'Quản lý',
//       headerIcon: Iconsax.home,
//       items: drawerItems,
//       selectedIndex: selectedIndex,
//       onTap: onTap,
//     );
//   }
// }