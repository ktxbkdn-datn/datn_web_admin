import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../room/presentations/bloc/area_bloc/area_bloc.dart';
import '../../../room/presentations/bloc/area_bloc/area_event.dart';
import '../../../room/presentations/bloc/area_bloc/area_state.dart';
import '../bloc/contract_bloc.dart';
import '../bloc/contract_event.dart';
import '../bloc/contract_state.dart';
import '../widget/contract_drawer.dart';
import '../widget/contract_list_page.dart';

class ContractManagementPage extends StatefulWidget {
  const ContractManagementPage({Key? key}) : super(key: key);

  @override
  _ContractManagementPageState createState() => _ContractManagementPageState();
}

class _ContractManagementPageState extends State<ContractManagementPage> {
  bool _isExpanded = true;
  int _selectedIndex = 1; // Mặc định chọn "Danh sách hợp đồng"
  bool _showAll = true; // Trạng thái tab mặc định: Tất cả
  bool _showExpired = false; // Trạng thái tab: Sắp đáo hạn

  @override
  void initState() {
    super.initState();
    context.read<ContractBloc>().add(const FetchAllContractsEvent());
    context.read<AreaBloc>().add( FetchAreasEvent(page: 1, limit: 100));
  }

  void _onDrawerItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onTabChanged({required bool showAll, required bool showExpired}) {
    setState(() {
      _showAll = showAll;
      _showExpired = showExpired;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<ContractBloc, ContractState>(
            listener: (context, state) {
              // Thông báo thành công và lỗi sẽ được xử lý trong ContractListPage
            },
          ),
          BlocListener<AreaBloc, AreaState>(
            listener: (context, state) {
              // Xử lý nếu cần khi danh sách khu vực thay đổi
            },
          ),
        ],
        child: Row(
          children: [
            ContractDrawer(
              selectedIndex: _selectedIndex,
              onTap: _onDrawerItemTap,
            ),
            Expanded(
              child: Container(
                color: Colors.grey[50],
                child: ContractListPage(
                  showAll: _showAll,
                  showExpired: _showExpired,
                  onTabChanged: _onTabChanged, // Callback để cập nhật trạng thái tab
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}