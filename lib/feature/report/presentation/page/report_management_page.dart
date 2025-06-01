// lib/src/features/report/presentations/report_management_page.dart
import 'package:datn_web_admin/feature/report/presentation/page/widget/report_tab/report_list_page.dart';
import 'package:datn_web_admin/feature/report/presentation/page/widget/rp_type_tab/report_type_list_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:datn_web_admin/common/widget/custom_drawer.dart';

import 'package:iconsax/iconsax.dart';

import '../bloc/report/report_bloc.dart';
import '../bloc/report/report_event.dart';
import '../bloc/report/report_state.dart';
import '../bloc/rp_image/rp_image_bloc.dart';
import '../bloc/rp_image/rp_image_state.dart';
import '../bloc/rp_type/rp_type_bloc.dart';
import '../bloc/rp_type/rp_type_event.dart';
import '../bloc/rp_type/rp_type_state.dart';

class ReportManagementPage extends StatefulWidget {
  const ReportManagementPage({Key? key}) : super(key: key);

  @override
  _ReportManagementPageState createState() => _ReportManagementPageState();
}

class _ReportManagementPageState extends State<ReportManagementPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Khởi tạo dữ liệu cho các tab
    context.read<ReportTypeBloc>().add(const GetAllReportTypesEvent());
    context.read<ReportBloc>().add(const GetAllReportsEvent(page: 1, limit: 12));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onDrawerItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Xử lý điều hướng dựa trên index
    if (index == 0) {
      // "Dashboard" - Điều hướng đến route '/dashboard'
      Navigator.pushNamed(context, '/dashboard');
    } else {
      // Các mục còn lại tương ứng với tab
      // Index 1 ("Tạo Report Type") -> tab 0
      // Index 2 ("Danh sách Report") -> tab 1
      int tabIndex = index - 1; // Ánh xạ index của DrawerItem với tab
      if (tabIndex >= 0 && tabIndex < _tabController.length) {
        _tabController.animateTo(tabIndex);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<ReportTypeBloc, ReportTypeState>(
            listener: (context, state) {
              if (state is ReportTypeError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi: ${state.message}')),
                );
              }
            },
          ),
          BlocListener<ReportBloc, ReportState>(
            listener: (context, state) {
              if (state is ReportError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi: ${state.message}')),
                );
              }
            },
          ),
          BlocListener<ReportImageBloc, ReportImageState>(
            listener: (context, state) {
              if (state is ReportImageError) {
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
              title: 'Quản lý Phản ánh',
              headerIcon: Iconsax.ticket,
              items: [
                DrawerItem(
                  title: 'Trang chủ',
                  icon: Iconsax.home,
                  route: '/dashboard',
                ),
                DrawerItem(
                  title: 'Danh sách Báo cáo',
                  icon: Iconsax.message_text,
                ),
                DrawerItem(
                  title: 'Tạo Loại Báo cáo',
                  icon: Iconsax.message_add,
                ),

              ],
              selectedIndex: _selectedIndex,
              onTap: _onDrawerItemTap,
            ),
            Expanded(
              child: Container(
                color: Colors.grey[50],
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [
                    ReportListPage(),
                    ReportTypeListTab(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}