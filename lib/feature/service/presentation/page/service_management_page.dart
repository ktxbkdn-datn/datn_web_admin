import 'package:datn_web_admin/feature/service/presentation/page/widget/service_drawer.dart';
import 'package:datn_web_admin/feature/service/presentation/page/widget/service_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:datn_web_admin/feature/service/presentation/bloc/service_bloc.dart';
import 'package:datn_web_admin/feature/service/presentation/bloc/service_event.dart';


class ServiceManagementPage extends StatefulWidget {
  const ServiceManagementPage({Key? key}) : super(key: key);

  @override
  _ServiceManagementPageState createState() => _ServiceManagementPageState();
}

class _ServiceManagementPageState extends State<ServiceManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    context.read<ServiceBloc>().add(const FetchServices(page: 1, limit: 12));
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          ServiceDrawer(
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
                  ServiceListPage(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}