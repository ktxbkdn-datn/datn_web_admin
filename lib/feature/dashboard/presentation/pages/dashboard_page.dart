// lib/src/features/dashboard/presentation/widgets/dashboard_page.dart
import 'package:datn_web_admin/feature/dashboard/presentation/bloc/statistic_bloc.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/bloc/statistic_event.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/widgets/stat_card/report_stat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:datn_web_admin/feature/auth/presentation/bloc/auth_state.dart';
import 'package:datn_web_admin/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:datn_web_admin/feature/auth/presentation/bloc/auth_event.dart';
import 'package:datn_web_admin/feature/admin/presentation/bloc/admin_bloc.dart';
import 'package:datn_web_admin/feature/admin/presentation/bloc/admin_event.dart';
import 'package:datn_web_admin/feature/admin/presentation/bloc/admin_state.dart';
import 'package:datn_web_admin/feature/admin/domain/entities/admin_entity.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/widgets/dashboard_drawer.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/widgets/stat_card/room_stat.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/widgets/stat_card/user_stat.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../register/domain/entity/register_entity.dart';
import '../widgets/bar_chart.dart';
import '../widgets/maintenance_request_card.dart';
import '../widgets/pie_chart.dart';
import '../widgets/stat_card.dart';
import '../widgets/registration_card.dart';
import '../../../../common/constants/colors.dart';
import '../../../report/presentation/bloc/report/report_bloc.dart';
import '../../../report/presentation/bloc/report/report_event.dart';
import '../../../report/presentation/bloc/report/report_state.dart';
import '../../../report/domain/entities/report_entity.dart';
import '../../../report/presentation/bloc/rp_type/rp_type_bloc.dart';
import '../../../report/presentation/bloc/rp_type/rp_type_event.dart';
import '../../../report/presentation/bloc/rp_type/rp_type_state.dart';
import '../../../report/presentation/page/widget/report_tab/report_detail_dialog.dart';
import 'package:intl/intl.dart';
import '../../../register/presentation/bloc/registration_bloc.dart';
import '../../../register/presentation/bloc/registration_event.dart';
import '../../../register/presentation/bloc/registration_state.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with RouteAware {
  int _selectedIndex = 0;
  AdminEntity? _currentAdmin;
  int _currentReportTypePage = 0;
  List<int> _reportTypeIds = [4];
  bool _isLoading = false;

  final List<MenuItem> menuItems = const [
    MenuItem(title: 'Người dùng', icon: Iconsax.people, route: '/users'),
    MenuItem(title: 'Phòng', icon: Iconsax.house, route: '/rooms'),
    MenuItem(title: 'Hợp đồng', icon: Iconsax.document, route: '/contracts'),
    MenuItem(title: 'Đăng kí', icon: Iconsax.path, route: '/registrations'),
    MenuItem(title: 'Báo cáo', icon: Iconsax.ticket, route: '/reports'),
    MenuItem(title: 'Thông báo', icon: Iconsax.notification, route: '/notifications'),
    MenuItem(title: 'Dịch vụ', icon: Iconsax.electricity, route: '/services'),
    MenuItem(title: 'Hoá đơn tháng', icon: Iconsax.receipt, route: '/bills'),
  ];

  @override
  void initState() {
    super.initState();
    _loadLocalAdmin();
    _fetchAdmin();
    context.read<ReportBloc>().add(const GetAllReportsEvent(page: 1, limit: 1000));
    context.read<RegistrationBloc>().add(const FetchRegistrations(page: 1, limit: 1000));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Đăng ký RouteObserver
    final ModalRoute? route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // Gọi khi quay lại trang DashboardPage
  @override
  void didPopNext() {
    // Khi quay lại trang này, làm mới dữ liệu
    context.read<StatisticsBloc>().add(FetchMonthlyConsumption(
      year: DateTime.now().year, // Sử dụng năm hiện tại
      areaId: null, // Mặc định là null (tất cả khu vực)
    ));
    context.read<ReportBloc>().add(const GetAllReportsEvent(page: 1, limit: 1000));
    context.read<RegistrationBloc>().add(const FetchRegistrations(page: 1, limit: 1000));
  }

  Future<void> _loadLocalAdmin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminJson = prefs.getString('currentAdmin');
    if (adminJson != null) {
      setState(() {
        _currentAdmin = AdminEntity.fromJson(jsonDecode(adminJson));
      });
    }
  }

  Future<void> _saveLocalAdmin() async {
    if (_currentAdmin != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('currentAdmin', jsonEncode(_currentAdmin!.toJson()));
    }
  }

  void _fetchAdmin() {
    final authState = context.read<AuthBloc>().state;
    if (authState.auth != null) {
      context.read<AdminBloc>().add(FetchCurrentAdminEvent(authState.auth!.id));
    }
  }

  Future<void> _changePage(int newPage) async {
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(Duration.zero);
    setState(() {
      _currentReportTypePage = newPage;
      _isLoading = false;
    });
  }

  Widget buildRegistrationContent(RegistrationState state, BuildContext context) {
    switch (state.runtimeType) {
      case RegistrationLoading:
        return const CircularProgressIndicator();

      case RegistrationsLoaded:
        final loadedState = state as RegistrationsLoaded;
        final allRegistrations = loadedState.registrations;
        final pendingCount = allRegistrations.where((reg) => reg.status == 'PENDING').length;

        final pendingRegistrations = allRegistrations
            .where((reg) => reg.status == 'PENDING')
            .toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

        final processedRegistrations = allRegistrations
            .where((reg) => reg.status != 'PENDING')
            .toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

        final displayRegistrations = [...pendingRegistrations];
        if (displayRegistrations.length < 3) {
          displayRegistrations.addAll(processedRegistrations.take(3 - displayRegistrations.length));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Đăng ký (${pendingCount} chưa xử lý)',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/registrations',
                      arguments: {'statusFilter': 'PENDING'},
                    );
                  },
                  child: const Text('Xem tất cả', style: TextStyle(color: Colors.blue)),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    context.read<RegistrationBloc>().add(const FetchRegistrations(page: 1, limit: 1000));
                  },
                  icon: const Icon(Icons.refresh, color: Colors.green),
                  tooltip: 'Làm mới',
                ),
              ],
            ),
            const SizedBox(height: 10),
            displayRegistrations.isEmpty
                ? const Text('Không có đăng ký nào')
                : Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: displayRegistrations.map((reg) {
                      return RegistrationCard(registration: reg);
                    }).toList(),
                  ),
          ],
        );

      case RegistrationError:
        final errorState = state as RegistrationError;
        return Text('Lỗi: ${errorState.message}');

      default:
        return const Text('Không có dữ liệu');
    }
  }

  Widget buildReportContent(ReportState state, BuildContext context) {
    switch (state.runtimeType) {
      case ReportsLoaded:
        if (_isLoading) {
          return const CircularProgressIndicator();
        }
        final loadedState = state as ReportsLoaded;
        final allReports = loadedState.reports;
        final reportTypeIds = allReports.map((report) => report.reportTypeId).toSet().toList();

        if (reportTypeIds.isEmpty) {
          return const Text('Không có loại báo cáo nào');
        }

        reportTypeIds.sort((a, b) {
          if (a == 4) return -1;
          if (b == 4) return 1;
          return a.compareTo(b);
        });

        _reportTypeIds = reportTypeIds;

        int currentReportTypeId = reportTypeIds[_currentReportTypePage % reportTypeIds.length];
        final filteredReports = allReports.where((report) => report.reportTypeId == currentReportTypeId).toList();

        if (filteredReports.isEmpty) {
          return const Text('Không có báo cáo nào với loại này');
        }

        final pendingReports = filteredReports
            .where((report) => report.status == "PENDING")
            .toList()
          ..sort((a, b) {
            final aDate = a.createdAt != null ? DateTime.parse(a.createdAt!) : DateTime(0);
            final bDate = b.createdAt != null ? DateTime.parse(b.createdAt!) : DateTime(0);
            return aDate.compareTo(bDate);
          });

        final processedReports = filteredReports
            .where((report) => report.status != "PENDING")
            .toList()
          ..sort((a, b) {
            final aDate = a.createdAt != null ? DateTime.parse(a.createdAt!) : DateTime(0);
            final bDate = b.createdAt != null ? DateTime.parse(b.createdAt!) : DateTime(0);
            return bDate.compareTo(aDate);
          });

        final displayReports = [...pendingReports];
        if (displayReports.length < 3) {
          displayReports.addAll(processedReports.take(3 - displayReports.length));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (displayReports.isEmpty)
              const Text('Không có báo cáo nào với loại này')
            else
              ...displayReports.map((report) {
                final createdAt = report.createdAt != null
                    ? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(report.createdAt!))
                    : 'Không xác định';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => ReportDetailDialog(report: report),
                      );
                    },
                    child: _buildMaintenanceCard(
                      type: report.reportTypeName ?? 'Không xác định',
                      id: report.reportId.toString(),
                      createdAt: createdAt,
                      assignedTo: report.userFullname ?? 'Chưa phân công',
                      status: report.status,
                    ),
                  ),
                );
              }).toList(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _currentReportTypePage > 0
                      ? () async {
                          await _changePage(_currentReportTypePage - 1);
                        }
                      : null,
                  icon: const Icon(Icons.arrow_back_ios, size: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  'Loại báo cáo ${(_currentReportTypePage % reportTypeIds.length) + 1} / ${reportTypeIds.length}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _currentReportTypePage < reportTypeIds.length - 1
                      ? () async {
                          await _changePage(_currentReportTypePage + 1);
                        }
                      : null,
                  icon: const Icon(Icons.arrow_forward_ios, size: 16),
                ),
              ],
            ),
          ],
        );

      case ReportInitial:
        context.read<ReportBloc>().add(const GetAllReportsEvent(page: 1, limit: 1000));
        return const CircularProgressIndicator();

      case ReportLoading:
        return const CircularProgressIndicator();

      case ReportError:
        final errorState = state as ReportError;
        return Text('Lỗi: ${errorState.message}');

      default:
        return const Text('Không có dữ liệu');
    }
  }

  Widget buildReportHeader(ReportState state) {
    String typeName = 'Không xác định';
    int unassignedCount = 0;

    if (state is ReportsLoaded && !_isLoading) {
      final allReports = state.reports;
      final reportTypeIds = allReports.map((report) => report.reportTypeId).toSet().toList();

      if (reportTypeIds.isNotEmpty) {
        reportTypeIds.sort((a, b) {
          if (a == 4) return -1;
          if (b == 4) return 1;
          return a.compareTo(b);
        });

        _reportTypeIds = reportTypeIds;

        int currentReportTypeId = reportTypeIds[_currentReportTypePage % reportTypeIds.length];
        final filteredReports = allReports.where((report) => report.reportTypeId == currentReportTypeId).toList();

        if (filteredReports.isNotEmpty) {
          typeName = filteredReports.first.reportTypeName ?? 'Không xác định';
          unassignedCount = filteredReports.where((report) => report.status == "PENDING").length;
        }
      }
    }

    return Expanded(
      child: Text(
        '$typeName ($unassignedCount chưa tiếp nhận)',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.glassmorphismStart, AppColors.glassmorphismEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 960,
                minHeight: 600,
              ),
              child: Row(
                children: [
                  DashboardDrawer(
                    selectedIndex: _selectedIndex,
                    onTap: (index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                      Navigator.pushNamed(context, menuItems[index].route);
                    },
                    menuItems: menuItems,
                  ),
                  const VerticalDivider(thickness: 1, width: 1),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: BlocBuilder<AdminBloc, AdminState>(
                                      builder: (context, state) {
                                        String adminName = _currentAdmin?.fullName ?? 'Admin';
                                        if (state is AdminUpdated) {
                                          _currentAdmin = state.currentAdmin;
                                          adminName = _currentAdmin?.fullName ?? 'Admin';
                                          _saveLocalAdmin();
                                        }
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Xin chào, $adminName!',
                                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87,
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Khám phá thông tin và quản lý hoạt động về ký túc xá của bạn',
                                              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.pushNamed(context, '/admin-management');
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        icon: const Icon(Iconsax.personalcard, color: Colors.white),
                                        label: const Text('Quản lý Admin', style: TextStyle(color: Colors.white)),
                                      ),
                                      const SizedBox(width: 10),
                                      BlocBuilder<AuthBloc, AuthState>(
                                        builder: (context, state) {
                                          return Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              ElevatedButton.icon(
                                                onPressed: state.isLoading
                                                    ? null
                                                    : () {
                                                        context.read<AuthBloc>().add(LogoutSubmitted());
                                                      },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                ),
                                                icon: const Icon(Iconsax.logout, color: Colors.white),
                                                label: const Text('Đăng xuất', style: TextStyle(color: Colors.white)),
                                              ),
                                              if (state.isLoading)
                                                const SizedBox(
                                                  width: 24,
                                                  height: 24,
                                                  child: CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2,
                                                  ),
                                                ),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const RoomStatCard(),
                                    const SizedBox(width: 16),
                                    const UserStatCard(),
                                    const SizedBox(width: 16),
                                    const ReportStatCard(),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return constraints.maxWidth > 600
                                      ? Row(
                                          children: [
                                            const Expanded(child: DashboardBarChart()),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  const ReportPieChart(),
                                                  const SizedBox(height: 16),
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          children: [
                                            const DashboardBarChart(),
                                            const SizedBox(height: 16),
                                            const ReportPieChart(),
                                            const SizedBox(height: 16),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: TextButton(
                                                onPressed: () {},
                                                child: const Text('Xem chi tiết', style: TextStyle(color: Colors.blue)),
                                              ),
                                            ),
                                          ],
                                        );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.only(top: 10.0, left: 16.0, right: 16.0, bottom: 16.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return constraints.maxWidth > 600
                                      ? Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  BlocBuilder<RegistrationBloc, RegistrationState>(
                                                    builder: (context, state) => buildRegistrationContent(state, context),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      BlocBuilder<ReportBloc, ReportState>(
                                                        builder: (context, state) => buildReportHeader(state),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pushNamed(
                                                            context,
                                                            '/reports',
                                                            arguments: {'initialTab': 0, 'statusFilter': 'PENDING'},
                                                          );
                                                        },
                                                        child: const Text('Xem tất cả', style: TextStyle(color: Colors.blue)),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      IconButton(
                                                        onPressed: () {
                                                          context.read<ReportBloc>().add(const GetAllReportsEvent(page: 1, limit: 1000));
                                                        },
                                                        icon: const Icon(Icons.refresh, color: Colors.green),
                                                        tooltip: 'Làm mới',
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  BlocBuilder<ReportBloc, ReportState>(
                                                    builder: (context, state) => buildReportContent(state, context),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                BlocBuilder<RegistrationBloc, RegistrationState>(
                                                  builder: (context, state) => buildRegistrationContent(state, context),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    BlocBuilder<ReportBloc, ReportState>(
                                                      builder: (context, state) => buildReportHeader(state),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pushNamed(
                                                          context,
                                                          '/reports',
                                                          arguments: {'initialTab': 0, 'statusFilter': 'PENDING'},
                                                        );
                                                      },
                                                      child: const Text('Xem tất cả', style: TextStyle(color: Colors.blue)),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    IconButton(
                                                      onPressed: () {
                                                        context.read<ReportBloc>().add(const GetAllReportsEvent(page: 1, limit: 1000));
                                                      },
                                                      icon: const Icon(Icons.refresh, color: Colors.green),
                                                      tooltip: 'Làm mới',
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                BlocBuilder<ReportBloc, ReportState>(
                                                  builder: (context, state) => buildReportContent(state, context),
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                },
                              ),
                            ),
                            BlocListener<AdminBloc, AdminState>(
                              listener: (context, state) {
                                if (state is AdminError) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Lỗi: ${state.failure.message}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              child: Container(),
                            ),
                            BlocListener<AuthBloc, AuthState>(
                              listener: (context, state) {
                                if (state.auth == null && state.successMessage != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(state.successMessage!),
                                      backgroundColor: Colors.green,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                  Navigator.pushReplacementNamed(context, '/login');
                                }
                                if (state.error != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(state.error!),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  if (state.error!.contains('Authorization') || state.error!.contains('Token')) {
                                    Navigator.pushReplacementNamed(context, '/login');
                                  }
                                }
                              },
                              child: Container(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceCard({
    required String type,
    required String id,
    required String createdAt,
    required String assignedTo,
    required String status,
  }) {
    IconData statusIcon;
    Color statusColor;

    switch (status) {
      case 'PENDING':
        statusIcon = Icons.person;
        statusColor = Colors.orange;
        break;
      case 'RECEIVED':
        statusIcon = Icons.receipt;
        statusColor = Colors.yellow[700]!;
        break;
      case 'IN_PROGRESS':
        statusIcon = Icons.build;
        statusColor = Colors.blue;
        break;
      case 'RESOLVED':
        statusIcon = Icons.check_circle;
        statusColor = Colors.green;
        break;
      case 'CLOSED':
        statusIcon = Icons.lock;
        statusColor = Colors.grey;
        break;
      default:
        statusIcon = Icons.help;
        statusColor = Colors.grey;
    }

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.glassmorphismStart, AppColors.glassmorphismEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.blueGrey,
                  child: Icon(
                    statusIcon,
                    color: statusColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$type [$id]',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        createdAt,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      assignedTo,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.blueGrey,
                      child: Icon(Icons.person, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class MenuItem {
  final String title;
  final IconData icon;
  final String route;

  const MenuItem({
    required this.title,
    required this.icon,
    required this.route,
  });
}

// Định nghĩa RouteObserver ở cấp độ toàn cục
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();