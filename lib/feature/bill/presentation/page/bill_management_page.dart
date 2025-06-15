import 'package:datn_web_admin/feature/bill/presentation/bloc/bill_bloc.dart';
import 'package:datn_web_admin/feature/bill/presentation/bloc/bill_event.dart';
import 'package:datn_web_admin/feature/bill/presentation/page/widget/bill_meter_details/bill_detail_list_page.dart';
import 'package:datn_web_admin/feature/bill/presentation/page/widget/bill_drawer.dart';
import 'package:datn_web_admin/feature/bill/presentation/page/widget/monthly_bill/monthly_bill_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';

import '../../../../common/constants/colors.dart'; // Import constants

class BillManagementPage extends StatefulWidget {
  const BillManagementPage({Key? key}) : super(key: key);

  @override
  _BillManagementPageState createState() => _BillManagementPageState();
}

class _BillManagementPageState extends State<BillManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<BillBloc>().add(const FetchAllMonthlyBills(page: 1, limit: 1000));
    context.read<BillBloc>().add(const FetchAllBillDetails(page: 1, limit: 12));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onDrawerItemTap(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        // Check if the route exists before navigating
        if (ModalRoute.of(context)?.settings.name != '/dashboard') {
          Navigator.pushReplacementNamed(context, '/dashboard').catchError((e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Không thể điều hướng đến Dashboard: $e'),
                backgroundColor: AppColors.buttonError,
              ),
            );
          });
        }
      } else if (index == 1) {
        _tabController.animateTo(0);
      } else if (index == 2) {
        _tabController.animateTo(1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Glassmorphism Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.glassmorphismStart, AppColors.glassmorphismEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Row(
            children: [
              BillDrawer(
                selectedIndex: _selectedIndex,
                onTap: _onDrawerItemTap,
                tabController: _tabController,
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadowColor,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: const [
                      BillListPage(),
                      BillDetailListPage(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}