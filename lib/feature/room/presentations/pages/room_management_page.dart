import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:datn_web_admin/feature/room/presentations/bloc/room_bloc/room_bloc.dart';
import 'package:datn_web_admin/feature/room/presentations/widget/area/area_list_tab.dart';
import 'package:datn_web_admin/feature/room/presentations/widget/room/room_drawer.dart';
import '../bloc/area_bloc/area_bloc.dart';
import '../bloc/area_bloc/area_event.dart';
import '../bloc/area_bloc/area_state.dart';
import '../widget/room/room_list_page.dart';

class RoomManagementPage extends StatefulWidget {
  const RoomManagementPage({Key? key}) : super(key: key);

  @override
  _RoomManagementPageState createState() => _RoomManagementPageState();
}

class _RoomManagementPageState extends State<RoomManagementPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isExpanded = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<RoomBloc>().add(GetAllRoomsEvent(page: 1, limit: 12));
    context.read<AreaBloc>().add(FetchAreasEvent(page: 1, limit: 100));
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
      // Index 1 ("Danh sách Phòng") -> tab 0
      // Index 2 ("Quản lý Khu vực") -> tab 1
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
          BlocListener<RoomBloc, RoomState>(
            listener: (context, state) {
              // Thông báo thành công đã được xử lý trong RoomListTab và RoomListPage
            },
          ),
          BlocListener<AreaBloc, AreaState>(
            listener: (context, state) {
              // Xử lý thông báo nếu cần
            },
          ),
        ],
        child: Row(
          children: [
            RoomDrawer(
              selectedIndex: _selectedIndex,
              onTap: _onDrawerItemTap,
              tabController: _tabController,
            ),
            Expanded(
              child: Container(
                color: Colors.grey[50],
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [
                    RoomListPage(),
                    AreaListTab(),
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