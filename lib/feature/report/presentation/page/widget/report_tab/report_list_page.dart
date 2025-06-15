import 'package:datn_web_admin/feature/report/presentation/page/widget/report_tab/report_detail_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../../../../../common/constants/colors.dart';
import '../../../../../../common/widget/custom_data_table.dart';
import '../../../../../../common/widget/filter_tab.dart';
import '../../../../../../common/widget/pagination_controls.dart';
import '../../../../../../common/widget/search_bar.dart';
import '../../../../domain/entities/report_entity.dart';
import '../../../../domain/entities/report_type_entity.dart';
import '../../../bloc/report/report_bloc.dart';
import '../../../bloc/report/report_event.dart';
import '../../../bloc/report/report_state.dart';
import '../../../bloc/rp_image/rp_image_bloc.dart';
import '../../../bloc/rp_image/rp_image_event.dart';
import '../../../bloc/rp_type/rp_type_bloc.dart';
import '../../../bloc/rp_type/rp_type_event.dart';
import '../../../bloc/rp_type/rp_type_state.dart';

class ReportListPage extends StatefulWidget {
  final String? initialStatusFilter;

  const ReportListPage({super.key, this.initialStatusFilter});

  @override
  ReportListPageState createState() => ReportListPageState();
}

class ReportListPageState extends State<ReportListPage> with AutomaticKeepAliveClientMixin {
  int _currentPage = 1;
  static const int _limit = 10; // Fixed limit for server-side pagination
  String _filterStatus = 'All';
  int? _filterReportTypeId = 4; // Default to "Báo cáo hư hỏng" (report_type_id = 4)
  String _searchQuery = '';
  List<ReportEntity> _allReports = [];
  List<ReportEntity> _filteredReports = []; // Stores current page's reports
  bool _isInitialLoad = true;
  List<ReportTypeEntity> _reportTypes = [];
  bool _isReportTypesLoaded = false;
  final List<double> _columnWidths = [300.0, 200.0, 200.0, 200.0, 80.0]; // Title, Sender, Status, Created Date, Action

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (widget.initialStatusFilter != null) {
      _filterStatus = widget.initialStatusFilter!;
    }
    _loadLocalData();
    context.read<ReportTypeBloc>().add(const GetAllReportTypesEvent());
    _fetchReports();
  }

  Future<void> _loadLocalData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _currentPage = prefs.getInt('reportCurrentPage') ?? 1;
      if (widget.initialStatusFilter == null) {
        _filterStatus = prefs.getString('reportFilterStatus') ?? 'All';
      }
      _filterReportTypeId = prefs.getInt('reportFilterReportTypeId') ?? 4;
      _searchQuery = prefs.getString('reportSearchQuery') ?? '';
      String? reportsJson = prefs.getString('reports');
      if (reportsJson != null) {
        try {
          List<dynamic> reportsList = jsonDecode(reportsJson);
          setState(() {
            _allReports = reportsList.map((json) => ReportEntity.fromJson(json)).toList();
            _applyFilters();
          });
        } catch (e) {
          print('Error loading local reports: $e');
          await prefs.remove('reports');
        }
      }
    } catch (e) {
      print('Error in _loadLocalData: $e');
    }
  }

  Future<void> _saveLocalData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('reportCurrentPage', _currentPage);
      await prefs.setString('reportFilterStatus', _filterStatus);
      await prefs.setInt('reportFilterReportTypeId', _filterReportTypeId ?? 4);
      await prefs.setString('reportSearchQuery', _searchQuery);
      await prefs.setString('reports', jsonEncode(_allReports.map((report) => report.toJson()).toList()));
    } catch (e) {
      print('Error saving local data: $e');
    }
  }

  void _fetchReports() {
    context.read<ReportBloc>().add(GetAllReportsEvent(
      page: _currentPage, 
      limit: _limit,
      status: _filterStatus == 'All' ? null : _filterStatus,  // Chuyển null khi "All"
      reportTypeId: _filterReportTypeId,
      searchQuery: _searchQuery.isEmpty ? null : _searchQuery  // Chuyển null khi rỗng
    ));
  }

  void _applyFilters() {
    print('Applying filters: status=$_filterStatus, reportTypeId=$_filterReportTypeId, searchQuery=$_searchQuery');
    print('All reports: ${_allReports.length}');
    setState(() {
      final filtered = _allReports.where((report) {
        bool matchesStatus = _filterStatus == 'All' || report.status.toUpperCase() == _filterStatus.toUpperCase();
        bool matchesReportType = _filterReportTypeId == null || report.reportTypeId == _filterReportTypeId;
        bool matchesSearch = _searchQuery.isEmpty ||
            report.title.toLowerCase().contains(_searchQuery.toLowerCase());
        bool matchesAll = matchesStatus && matchesReportType && matchesSearch;
        if (!matchesAll && report.status.toUpperCase() == 'PENDING') {
          print('Report filtered out: id=${report.reportId}, status=${report.status}, typeId=${report.reportTypeId}, title=${report.title}, matchesStatus=$matchesStatus, matchesReportType=$matchesReportType, matchesSearch=$matchesSearch');
        }
        return matchesAll;
      }).toList();
      
      // Fix the pagination issue with empty list
      if (filtered.isEmpty) {
        _filteredReports = [];
        _currentPage = 1; // Reset to page 1 if no data
      } else {
        // Calculate start index
        int startIndex = (_currentPage - 1) * _limit;
        
        // If startIndex >= filtered.length, reset to page 1
        if (startIndex >= filtered.length) {
          _currentPage = 1;
          startIndex = 0;
        }
        
        // Apply pagination
        _filteredReports = filtered.sublist(
          startIndex,
          startIndex + _limit > filtered.length ? filtered.length : startIndex + _limit,
        );
      }
      
      print('Filtered reports: ${_filteredReports.length}, current page: $_currentPage');
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final screenWidth = MediaQuery.of(context).size.width;
    final paddingHorizontal = screenWidth > 1200 ? screenWidth * 0.1 : 8.0;

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
        SafeArea(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 960,
              minHeight: 600,
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: MultiBlocListener(
                listeners: [
                  BlocListener<ReportBloc, ReportState>(
                    listener: (context, state) {
                      if (state is ReportError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${state.message}')),
                        );
                      } else if (state is ReportDeleted) {
                        setState(() {
                          _allReports.removeWhere((report) => report.reportId == state.reportId);
                          _applyFilters();
                        });
                        _saveLocalData();
                        _fetchReports(); // Re-fetch current page
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Xóa báo cáo thành công!'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else if (state is ReportStatusUpdated) {
                        setState(() {
                          final index = _allReports.indexWhere((report) => report.reportId == state.report.reportId);
                          if (index != -1) {
                            _allReports[index] = state.report;
                          }
                          _applyFilters();
                        });
                        _saveLocalData();
                        _fetchReports(); // Re-fetch current page
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cập nhật trạng thái báo cáo thành công!'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else if (state is ReportsLoaded) {
                        setState(() {
                          _allReports = state.reports;
                          _isInitialLoad = false;
                          _applyFilters();
                        });
                        _saveLocalData();
                      }
                    },
                  ),
                  BlocListener<ReportTypeBloc, ReportTypeState>(
                    listener: (context, state) {
                      if (state is ReportTypesLoaded) {
                        setState(() {
                          _reportTypes = state.reportTypes;
                          _isReportTypesLoaded = true;
                          if (_reportTypes.isNotEmpty &&
                              !_reportTypes.any((type) => type.reportTypeId == _filterReportTypeId)) {
                            _filterReportTypeId = _reportTypes.first.reportTypeId;
                            _saveLocalData();
                          }
                          _applyFilters();
                        });
                      } else if (state is ReportTypeError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Lỗi khi tải loại báo cáo: ${state.message}')),
                        );
                      }
                    },
                  ),
                ],
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: 16.0),
                        child: Container(
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    // Tab lọc theo trạng thái
                                    FilterTab(
                                      label: 'Tất cả',
                                      isSelected: _filterStatus == 'All',
                                      onTap: () {
                                        setState(() {
                                          _filterStatus = 'All';
                                          _currentPage = 1;
                                          _saveLocalData();
                                        });
                                        _fetchReports();  // Quan trọng: Gửi yêu cầu mới đến server
                                      },
                                    ),
                                    const SizedBox(width: 10),
                                    FilterTab(
                                      label: 'Chưa tiếp nhận',
                                      isSelected: _filterStatus == 'PENDING',
                                      onTap: () {
                                        setState(() {
                                          _filterStatus = 'PENDING';
                                          _currentPage = 1;
                                          _saveLocalData();
                                        });
                                        _fetchReports();
                                      },
                                    ),
                                    const SizedBox(width: 10),
                                    FilterTab(
                                      label: 'Đã tiếp nhận',
                                      isSelected: _filterStatus == 'RECEIVED',
                                      onTap: () {
                                        setState(() {
                                          _filterStatus = 'RECEIVED';
                                          _currentPage = 1;
                                          _saveLocalData();
                                        });
                                        _fetchReports();
                                      },
                                    ),
                                    const SizedBox(width: 10),
                                    FilterTab(
                                      label: 'Đang xử lý (${_allReports.where((report) => report.status.toUpperCase() == 'IN_PROGRESS').length})',
                                      isSelected: _filterStatus == 'IN_PROGRESS',
                                      onTap: () {
                                        setState(() {
                                          _filterStatus = 'IN_PROGRESS';
                                          _currentPage = 1;
                                          _saveLocalData();
                                        });
                                        _fetchReports();
                                      },
                                    ),
                                    const SizedBox(width: 10),
                                    FilterTab(
                                      label: 'Đã giải quyết (${_allReports.where((report) => report.status.toUpperCase() == 'RESOLVED').length})',
                                      isSelected: _filterStatus == 'RESOLVED',
                                      onTap: () {
                                        setState(() {
                                          _filterStatus = 'RESOLVED';
                                          _currentPage = 1;
                                          _saveLocalData();
                                        });
                                        _fetchReports();
                                      },
                                    ),
                                    const SizedBox(width: 10),
                                    FilterTab(
                                      label: 'Hoàn tất (${_allReports.where((report) => report.status.toUpperCase() == 'CLOSED').length})',
                                      isSelected: _filterStatus == 'CLOSED',
                                      onTap: () {
                                        setState(() {
                                          _filterStatus = 'CLOSED';
                                          _currentPage = 1;
                                          _saveLocalData();
                                        });
                                        _fetchReports();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: _isReportTypesLoaded
                                              ? DropdownButton<int?>(
                                                  value: _filterReportTypeId,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _filterReportTypeId = value;
                                                      _currentPage = 1;
                                                      _saveLocalData();
                                                    });
                                                    _fetchReports();  // Quan trọng: Gửi yêu cầu mới đến server
                                                  },
                                                  hint: const Text('Chọn loại báo cáo'),
                                                  isExpanded: true,
                                                  underline: const SizedBox(),
                                                  items: [
                                                    const DropdownMenuItem<int>(
                                                      value: null,
                                                      child: Text('Tất cả loại báo cáo'),
                                                    ),
                                                    ..._reportTypes.map((reportType) {
                                                      return DropdownMenuItem<int>(
                                                        value: reportType.reportTypeId,
                                                        child: Text(reportType.name),
                                                      );
                                                    }).toList(),
                                                  ],
                                                )
                                              : const SizedBox(
                                                  width: 24,
                                                  height: 24,
                                                  child: CircularProgressIndicator(strokeWidth: 2),
                                                ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: SearchBarTab(
                                            onChanged: (value) {
                                              setState(() {
                                                _searchQuery = value;
                                                _currentPage = 1;
                                                _saveLocalData();
                                              });
                                              _fetchReports();  // Quan trọng: Gửi yêu cầu mới đến server
                                            },
                                            hintText: 'Tìm kiếm báo cáo...',
                                            initialValue: _searchQuery,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Row(
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: _fetchReports,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        icon: const Icon(Icons.refresh, color: Colors.white),
                                        label: const Text('Làm mới', style: TextStyle(color: Colors.white)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: MediaQuery.of(context).size.height - 200,
                        child: SingleChildScrollView(
                          child: BlocBuilder<ReportBloc, ReportState>(
                            builder: (context, state) {
                              if (state is ReportLoading) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              if (state is ReportError) {
                                return Center(child: Text('Lỗi: ${state.message}'));
                              }
                              if (state is ReportsLoaded) {
                                // Nếu là tab "Tất cả", sắp xếp theo thời gian mới nhất
                                final List<ReportEntity> sortedReports = _filterStatus == 'All'
                                    ? (List<ReportEntity>.from(state.reports)
                                        ..sort((a, b) => (b.createdAt ?? '').compareTo(a.createdAt ?? '')))
                                    : state.reports;

                                return Column(
                                  children: [
                                    GenericDataTable<ReportEntity>(
                                      headers: const [
                                        'Tiêu đề',
                                        'Người gửi',
                                        'Trạng thái',
                                        'Ngày tạo',
                                        '',
                                      ],
                                      data: sortedReports, // <-- truyền danh sách đã sắp xếp
                                      columnWidths: _columnWidths,
                                      cellBuilder: (report, index) {
                                        switch (index) {
                                          case 0:
                                            return Text(
                                              report.title,
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                            );
                                          case 1:
                                            return Text(
                                              report.userFullname ?? 'N/A',
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                            );
                                          case 2:
                                            return Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: _getStatusColor(report.status),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                _getStatusDisplayText(report.status),
                                                style: const TextStyle(color: Colors.white),
                                                textAlign: TextAlign.center,
                                              ),
                                            );
                                          case 3:
                                            return Text(
                                              _formatDateTime(report.createdAt) ?? 'N/A',
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                            );
                                          case 4:
                                            return Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.visibility),
                                                  onPressed: () {
                                                    context.read<ReportBloc>().add(GetReportByIdEvent(report.reportId));
                                                    context.read<ReportImageBloc>().add(GetReportImagesEvent(report.reportId));
                                                    showDialog(
                                                      context: context,
                                                      barrierDismissible: false,
                                                      builder: (dialogContext) => ReportDetailDialog(report: report),
                                                    );
                                                  },
                                                ),
                                              ],
                                            );
                                          default:
                                            return const SizedBox();
                                        }
                                      },
                                    ),
                                    PaginationControls(
                                      currentPage: _currentPage,
                                      totalItems: state.totalItems,  // Lấy tổng số từ state
                                      limit: _limit,
                                      onPageChanged: (page) {
                                        setState(() {
                                          _currentPage = page;
                                          _saveLocalData();
                                        });
                                        _fetchReports();  // Quan trọng: Gửi yêu cầu mới đến server
                                      },
                                    ),
                                  ],
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getStatusDisplayText(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Chưa tiếp nhận';
      case 'RECEIVED':
        return 'Đã tiếp nhận';
      case 'IN_PROGRESS':
        return 'Đang xử lý';
      case 'RESOLVED':
        return 'Đã giải quyết';
      case 'CLOSED':
        return 'Hoàn tất';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.grey;
      case 'RECEIVED':
        return Colors.blue;
      case 'IN_PROGRESS':
        return Colors.orange;
      case 'RESOLVED':
        return Colors.green;
      case 'CLOSED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String? _formatDateTime(String? dateTime) {
    if (dateTime == null) return null;
    return dateTime.replaceFirst('T', ' ');
  }
}
