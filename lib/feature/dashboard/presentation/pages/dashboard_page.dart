import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:datn_web_admin/feature/admin/domain/entities/admin_entity.dart';
import 'package:datn_web_admin/feature/admin/presentation/bloc/admin_bloc.dart';
import 'package:datn_web_admin/feature/admin/presentation/bloc/admin_event.dart';
import 'package:datn_web_admin/feature/admin/presentation/bloc/admin_state.dart';
import 'package:datn_web_admin/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:datn_web_admin/feature/auth/presentation/bloc/auth_state.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/bloc/statistic_bloc.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/bloc/statistic_event.dart';
import 'package:datn_web_admin/feature/register/domain/entity/register_entity.dart';
import 'package:datn_web_admin/feature/register/presentation/bloc/registration_bloc.dart';
import 'package:datn_web_admin/feature/register/presentation/bloc/registration_event.dart';
import 'package:datn_web_admin/feature/register/presentation/bloc/registration_state.dart';
import 'package:datn_web_admin/feature/report/presentation/bloc/report/report_bloc.dart';
import 'package:datn_web_admin/feature/report/presentation/bloc/report/report_event.dart';
import 'package:datn_web_admin/feature/report/presentation/bloc/report/report_state.dart';
import 'package:datn_web_admin/feature/report/presentation/page/widget/report_tab/report_detail_dialog.dart';
import 'package:datn_web_admin/common/constants/colors.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/widgets/consumptions_bar_chart.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/widgets/reports_pie_chart.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/widgets/registration_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with RouteAware {
  AdminEntity? _currentAdmin;
  int _currentReportTypePage = 0;
  List<int> _reportTypeIds = [4];
  bool _isLoading = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadLocalAdmin();
    _fetchAdmin();
    _fetchInitialData();
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _fetchInitialData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    final authState = context.read<AuthBloc>().state;
    if (authState.auth != null) {
      context.read<StatisticsBloc>().add(FetchMonthlyConsumption(
        year: DateTime.now().year,
        areaId: null, forceRefresh: false,
      ));
    }
  }

  Future<void> _fetchInitialData() async {
    final authState = context.read<AuthBloc>().state;
    if (authState.auth != null) {
      context.read<ReportBloc>().add(const GetAllReportsEvent(page: 1, limit: 1000));
      context.read<RegistrationBloc>().add(const FetchRegistrations(page: 1, limit: 1000));
    }
  }

  Future<void> _loadLocalAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    final adminJson = prefs.getString('currentAdmin');
    if (adminJson != null) {
      setState(() {
        _currentAdmin = AdminEntity.fromJson(jsonDecode(adminJson));
      });
    }
  }

  Future<void> _saveLocalAdmin() async {
    if (_currentAdmin != null) {
      final prefs = await SharedPreferences.getInstance();
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
    int pendingCount = 0;
    List<Registration> displayRegistrations = [];

    if (state is RegistrationsLoaded) {
      final loadedState = state;
      final allRegistrations = loadedState.registrations;
      pendingCount = allRegistrations.where((reg) => reg.status == 'PENDING').length;

      final pendingRegistrations = allRegistrations
          .where((reg) => reg.status == 'PENDING')
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

      final processedRegistrations = allRegistrations
          .where((reg) => reg.status != 'PENDING')
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

      displayRegistrations = [...pendingRegistrations];
      if (displayRegistrations.length < 3) {
        displayRegistrations.addAll(processedRegistrations.take(3 - displayRegistrations.length));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Đăng ký ($pendingCount chưa xử lý)',
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
                final authState = context.read<AuthBloc>().state;
                if (authState.auth != null) {
                  context.read<RegistrationBloc>().add(const FetchRegistrations(page: 1, limit: 1000));
                }
              },
              icon: const Icon(Icons.refresh, color: Colors.green),
              tooltip: 'Làm mới',
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (state is RegistrationLoading)
          const Center(child: CircularProgressIndicator())
        else if (state is RegistrationError)
          Text('Lỗi: ${state.message}')
        else if (displayRegistrations.isEmpty)
          const Text('Không có đăng ký nào')
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: displayRegistrations.map((reg) => RegistrationCard(registration: reg)).toList(),
          ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legendRegistrationIcon(Icons.pending, Colors.orange, 'Chờ duyệt'),
            const SizedBox(width: 12),
            _legendRegistrationIcon(Icons.check_circle, Colors.green, 'Đã duyệt'),
            const SizedBox(width: 12),
            _legendRegistrationIcon(Icons.cancel, Colors.red, 'Từ chối'),
          ],
        ),
      ],
    );
  }

  Widget buildReportContent(ReportState state, BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ReportsLoaded) {
      final allReports = state.reports;
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
      final currentReportTypeId = reportTypeIds[_currentReportTypePage % reportTypeIds.length];
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
              _legendIcon(Icons.pending, Colors.orange, 'Chờ xử lý'),
              const SizedBox(width: 12),
              _legendIcon(Icons.receipt, Colors.yellow, 'Đã tiếp nhận'),
              const SizedBox(width: 12),
              _legendIcon(Icons.build, Colors.blue, 'Đang xử lý'),
              const SizedBox(width: 12),
              _legendIcon(Icons.check_circle, Colors.green, 'Đã xử lý'),
              const SizedBox(width: 12),
              _legendIcon(Icons.lock, Colors.grey, 'Đã đóng'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _currentReportTypePage > 0
                    ? () => _changePage(_currentReportTypePage - 1)
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
                    ? () => _changePage(_currentReportTypePage + 1)
                    : null,
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ],
          ),
        ],
      );
    }

    if (state is ReportLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ReportError) {
      return Text('Lỗi: ${state.message}');
    }

    return const Text('Không có dữ liệu');
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
        final currentReportTypeId = reportTypeIds[_currentReportTypePage % reportTypeIds.length];
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
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.glassmorphismStart, AppColors.glassmorphismEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 960, minHeight: 600),
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
                                        'Xin chào',
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
     
                            // Row(
                            //   mainAxisSize: MainAxisSize.min,
                            //   children: [
                            //     ElevatedButton.icon(
                            //       onPressed: () {
                            //         Navigator.push(
                            //           context,
                            //           MaterialPageRoute(builder: (_) => const StatisticsOverviewPage()),
                            //         );
                            //       },
                            //       style: ElevatedButton.styleFrom(
                            //         backgroundColor: Colors.deepPurple,
                            //         shape: RoundedRectangleBorder(
                            //           borderRadius: BorderRadius.circular(8),
                            //         ),
                            //       ),
                            //       icon: const Icon(Icons.bar_chart, color: Colors.white),
                            //       label: const Text('Thống kê', style: TextStyle(color: Colors.white)),
                            //     ),
                            //     const SizedBox(width: 10),
                            //     ElevatedButton.icon(
                            //       onPressed: () {
                            //         Navigator.pushNamed(context, '/admin-management');
                            //       },
                            //       style: ElevatedButton.styleFrom(
                            //         backgroundColor: Colors.blue,
                            //         shape: RoundedRectangleBorder(
                            //           borderRadius: BorderRadius.circular(8),
                            //         ),
                            //       ),
                            //       icon: const Icon(Iconsax.personalcard, color: Colors.white),
                            //       label: const Text('Quản lý Admin', style: TextStyle(color: Colors.white)),
                            //     ),
                            //     const SizedBox(width: 10),
                            //     BlocBuilder<AuthBloc, AuthState>(
                            //       builder: (context, state) {
                            //         return Stack(
                            //           alignment: Alignment.center,
                            //           children: [
                            //             ElevatedButton.icon(
                            //               onPressed: state.isLoading
                            //                   ? null
                            //                   : () {
                            //                       context.read<AuthBloc>().add(LogoutSubmitted());
                            //                     },
                            //               style: ElevatedButton.styleFrom(
                            //                 backgroundColor: Colors.red,
                            //                 shape: RoundedRectangleBorder(
                            //                   borderRadius: BorderRadius.circular(8),
                            //                 ),
                            //               ),
                            //               icon: const Icon(Iconsax.logout, color: Colors.white),
                            //               label: const Text('Đăng xuất', style: TextStyle(color: Colors.white)),
                            //             ),
                            //             if (state.isLoading)
                            //               const SizedBox(
                            //                 width: 24,
                            //                 height: 24,
                            //                 child: CircularProgressIndicator(
                            //                   color: Colors.white,
                            //                   strokeWidth: 2,
                            //                 ),
                            //               ),
                            //           ],
                            //         );
                            //       },
                            //     ),
                            //   ],
                            // ),
      
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Column(
                              children: [
                                // Gọi trực tiếp DashboardBarChart như ReportPieChart
                                Container(
                                  margin: const EdgeInsets.only(bottom: 24),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 1,
                                        blurRadius: 3,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: DashboardBarChart(),
                                ),
                                
                                // Report Chart (Pie Chart) - Always enlarged with modern design
                                Container(
                                  margin: const EdgeInsets.only(bottom: 24),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.grey.shade200),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 0,
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: SizedBox(
                                    height: 700, // Increased height for the modernized pie chart
                                    child: ReportPieChart(
                                      chartWidth: constraints.maxWidth,
                                      chartHeight: 650,
                                      pieRadius: constraints.maxWidth * 0.12,
                                      isEnlarged: true,
                                    ),
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
                                                    final authState = context.read<AuthBloc>().state;
                                                    if (authState.auth != null) {
                                                      context.read<ReportBloc>().add(const GetAllReportsEvent(page: 1, limit: 1000));
                                                    }
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
                                                  final authState = context.read<AuthBloc>().state;
                                                  if (authState.auth != null) {
                                                    context.read<ReportBloc>().add(const GetAllReportsEvent(page: 1, limit: 1000));
                                                  }
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
                                content: Text('${state.failure.message}'),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                        child: const SizedBox.shrink(),
                      ),
                      BlocListener<AuthBloc, AuthState>(
                        listener: (context, state) {
                          if (state.auth == null) {
                            _refreshTimer?.cancel();
                            if (state.successMessage != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(state.successMessage!),
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            }
                            Navigator.pushReplacementNamed(context, '/login');
                          } else if (state.error != null) {
                            if (!state.error!.contains('Authorization') &&
                                !state.error!.contains('Token') &&
                                !state.error!.contains('Phiên đăng nhập đã hết hạn')) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(state.error!),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        child: const SizedBox.shrink(),
                      ),
                      BlocListener<RegistrationBloc, RegistrationState>(
                        listener: (context, state) {
                          if (state is RegistrationError) {
                            if (state.message.contains('Phiên đăng nhập đã hết hạn')) {
                              Navigator.pushReplacementNamed(context, '/login');
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${state.message}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        child: const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
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
        statusIcon = Icons.pending;
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

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 2),
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
              child: Icon(statusIcon, color: statusColor),
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
    );
  }

  Widget _legendIcon(IconData icon, Color color, String label) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _legendRegistrationIcon(IconData icon, Color color, String label) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();