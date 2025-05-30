import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/registration_bloc.dart';
import '../bloc/registration_event.dart';
import '../widget/registration_drawer.dart';
import '../widget/registration_list_page.dart';


class RegistrationManagementPage extends StatefulWidget {
  const RegistrationManagementPage({Key? key}) : super(key: key);

  @override
  _RegistrationManagementPageState createState() => _RegistrationManagementPageState();
}

class _RegistrationManagementPageState extends State<RegistrationManagementPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isExpanded = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    context.read<RegistrationBloc>().add(const FetchRegistrations(page: 1, limit: 12));
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
          RegistrationDrawer(
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
                  RegistrationListPage(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}