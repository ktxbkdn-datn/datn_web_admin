import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; // Used for DateFormat in _buildHeader
import 'package:intl/date_symbol_data_local.dart';
import 'package:logger/logger.dart';
import '../../../report/domain/entities/report_entity.dart';
import '../../../report/domain/entities/report_type_entity.dart';
import '../../../report/data/models/report_type.dart'; // Import the ReportTypeModel
import '../../../report/presentation/bloc/report/report_bloc.dart';
import '../../../report/presentation/bloc/report/report_event.dart';
import '../../../report/presentation/bloc/report/report_state.dart';
import '../../../report/presentation/bloc/rp_type/rp_type_bloc.dart';
import '../../../report/presentation/bloc/rp_type/rp_type_event.dart';
import '../../../report/presentation/bloc/rp_type/rp_type_state.dart';
import 'package:datn_web_admin/feature/auth/presentation/bloc/auth_bloc.dart';

class ReportPieChart extends StatefulWidget {
  final double chartWidth;
  final double chartHeight;
  final bool isEnlarged; 
  final double pieRadius;

  const ReportPieChart({
    super.key,
    required this.chartWidth,
    required this.chartHeight,
    this.isEnlarged = false,
    required this.pieRadius,
  });

  @override
  _ReportPieChartState createState() => _ReportPieChartState();
}

class _ReportPieChartState extends State<ReportPieChart> {
  final ValueNotifier<DateTime> _selectedMonth = ValueNotifier(DateTime.now());
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('vi', null).then((_) {
      if (mounted) {
        setState(() {});
      }
    });
    final authState = context.read<AuthBloc>().state;
    if (authState.auth != null) {
      _logger.i('ReportPieChart: Fetching report types');
      context.read<ReportTypeBloc>().add(const GetAllReportTypesEvent());
      _fetchReportsForMonth(_selectedMonth.value);
    } else {
      _logger.w('ReportPieChart: No auth token, skipping fetch');
    }
  }

  @override
  void dispose() {
    _selectedMonth.dispose();
    super.dispose();
  }

  Future<void> _fetchReportsForMonth(DateTime month, {bool forceRefresh = false}) async {
    final authState = context.read<AuthBloc>().state;
    if (authState.auth == null) return;
    _logger.i('ReportPieChart: Fetching reports for month ${month.month}/${month.year}');
    context.read<ReportBloc>().add(GetAllReportsEvent(
      page: 1,
      limit: 1000,
      searchQuery: '${month.year}-${month.month.toString().padLeft(2, '0')}',
      forceRefresh: forceRefresh,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.grey.shade50],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildMonthYearSelector(),
              const SizedBox(height: 24),
              Expanded(
                child: _buildChartContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Giao diện header hiện đại giống Consumption ---
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.bar_chart, color: Colors.blue.shade700, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Phân bố loại báo cáo",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.refresh, color: Colors.blue.shade700),
                tooltip: 'Làm mới dữ liệu',
                onPressed: () {
                  final authState = context.read<AuthBloc>().state;
                  if (authState.auth != null) {
                    _logger.i('ReportPieChart: Refreshing reports');
                    _fetchReportsForMonth(_selectedMonth.value, forceRefresh: true);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "${_getMonthName(_selectedMonth.value.month)} ${_selectedMonth.value.year}",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // --- Giao diện chọn tháng/năm hiện đại giống Consumption ---
  Widget _buildMonthYearSelector() {
    return ValueListenableBuilder<DateTime>(
      valueListenable: _selectedMonth,
      builder: (context, selectedDate, _) {
        final currentYear = DateTime.now().year;
        final years = List.generate(10, (index) => currentYear - 5 + index);
        final monthNames = [
          'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6',
          'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'
        ];
        return Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                value: selectedDate.month,
                items: List.generate(12, (index) => DropdownMenuItem<int>(
                  value: index + 1,
                  child: Text(monthNames[index]),
                )),
                onChanged: (month) {
                  if (month != null) {
                    final newDate = DateTime(selectedDate.year, month);
                    _selectedMonth.value = newDate;
                    _fetchReportsForMonth(newDate);
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Tháng',
                  prefixIcon: const Icon(Icons.calendar_month),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<int>(
                value: selectedDate.year,
                items: years.map((year) => DropdownMenuItem<int>(
                  value: year,
                  child: Text(year.toString()),
                )).toList(),
                onChanged: (year) {
                  if (year != null) {
                    final newDate = DateTime(year, selectedDate.month);
                    _selectedMonth.value = newDate;
                    _fetchReportsForMonth(newDate);
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Năm',
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),

          ],
        );
      },
    );
  }

  Widget _buildChartContent() {
    return BlocBuilder<ReportBloc, ReportState>(
      builder: (context, reportState) {
        return BlocBuilder<ReportTypeBloc, ReportTypeState>(
          builder: (context, reportTypeState) {
            if (reportState is ReportLoading || reportTypeState is ReportTypeLoading) {
              return _buildLoadingState();
            }
            
            if (reportState is ReportError) {
              return _buildErrorState(reportState.message);
            }
            
            if (reportTypeState is ReportTypeError) {
              return _buildErrorState(reportTypeState.message);
            }
            
            if (reportState is ReportsLoaded && reportTypeState is ReportTypesLoaded) {
              if (reportTypeState.reportTypes.isEmpty) {
                return _buildEmptyState("Không có loại báo cáo");
              }
              
              return _buildChartWithData(reportState.reports, reportTypeState.reportTypes);
            }
            
            return _buildEmptyState("Không có dữ liệu");
          },
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 48,
            width: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Colors.blue.shade600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Đang tải dữ liệu...",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            "Lỗi: $message",
            style: TextStyle(color: Colors.grey.shade800, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => _fetchReportsForMonth(_selectedMonth.value),
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text("Thử lại"),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.bar_chart, size: 32, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Chọn tháng khác để xem báo cáo",
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartWithData(List<ReportEntity> reports, List<ReportTypeEntity> reportTypes) {
    final filteredReports = _filterReportsByMonth(reports, _selectedMonth.value);
    final reportCounts = _countReportsByType(filteredReports, reportTypes);
    
    // If no data after filtering
    if (reportCounts.isEmpty) {
      return _buildEmptyState("Không có dữ liệu báo cáo cho tháng này");
    }
    
    // Prepare data for chart
    final colors = [
      const Color(0xFF10B981), // Emerald
      const Color(0xFF3B82F6), // Blue
      const Color(0xFFF59E0B), // Amber
      const Color(0xFFEF4444), // Red
      const Color(0xFF8B5CF6), // Violet
      const Color(0xFF06B6D4), // Cyan
      const Color(0xFFF97316), // Orange
      const Color(0xFFEC4899), // Pink
    ];
      final sections = <PieChartSectionData>[];
    final double totalReports = filteredReports.length.toDouble();
    
    // Build sections data
    for (var entry in reportCounts.entries) {
      final reportType = reportTypes.firstWhere(
        (type) => type.reportTypeId == entry.key,
        orElse: () => ReportTypeModel(reportTypeId: entry.key, name: "Unknown Type"),
      );
      
      final count = entry.value;
      final percentage = totalReports > 0 ? (count / totalReports) * 100 : 0;
      final colorIndex = reportTypes.indexOf(reportType) % colors.length;
      
      sections.add(
        PieChartSectionData(
          color: colors[colorIndex],
          value: count.toDouble(),
          title: percentage >= 5 ? '${percentage.toStringAsFixed(1)}%' : '',
          radius: widget.pieRadius,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          badgeWidget: percentage < 5 ? null : null, // Badge for small sections if needed
          badgePositionPercentageOffset: 1.2,
        ),
      );
    }

    // Calculate total reports
    final totalCount = reportCounts.values.fold<int>(0, (sum, count) => sum + count);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive layout
        final bool isWideLayout = constraints.maxWidth > 750;
          if (isWideLayout) {
          // Side-by-side layout for wide screens
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chart Area - 3/5 width
                Expanded(
                  flex: 3,
                  child: _buildPieChartArea(sections, totalCount),
                ),
                
                // Divider
                Container(
                  width: 1,
                  height: double.infinity,
                  color: Colors.grey.shade200,
                ),
                
                // Legend Area - 2/5 width
                Expanded(
                  flex: 2,
                  child: _buildLegendArea(reportCounts, reportTypes, colors, totalCount),
                ),
              ],
            ),
          );
        } else {
          // Stacked layout for narrower screens
          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: _buildPieChartArea(sections, totalCount),
                ),
                
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: _buildLegendArea(reportCounts, reportTypes, colors, totalCount),
                ),
              ],
            ),
          );
        }
      },
    );
  }
  Widget _buildPieChartArea(List<PieChartSectionData> sections, int totalCount) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min, // Không chiếm quá nhiều không gian
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Biểu đồ phân bố",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.trending_up, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      "Tổng: $totalCount báo cáo",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 380, // Giảm chiều cao để không bị tràn
            width: double.infinity,
            child: Center(
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: (widget.pieRadius - 40) / 5,
                  sectionsSpace: 2,
                  pieTouchData: PieTouchData(
                    enabled: true,
                    touchCallback: (flTouchEvent, pieTouchResponse) {
                      // Touch handling logic here if needed
                    },
                  ),
                ),
                swapAnimationDuration: const Duration(milliseconds: 250),
                swapAnimationCurve: Curves.easeInOutQuad,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildLegendArea(Map<int, int> reportCounts, List<ReportTypeEntity> reportTypes, List<Color> colors, int totalCount) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Chi tiết báo cáo",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),const SizedBox(height: 16),
          // Legend items
          ...reportCounts.entries.map((entry) {
            final reportType = reportTypes.firstWhere(
              (type) => type.reportTypeId == entry.key,
              orElse: () => ReportTypeModel(reportTypeId: entry.key, name: "Unknown Type"),
            );
            
            final count = entry.value;
            final percentage = totalCount > 0 ? (count / totalCount) * 100 : 0;
            final colorIndex = reportTypes.indexOf(reportType) % colors.length;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[colorIndex],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reportType.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1F2937),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "$count báo cáo (${percentage.toStringAsFixed(1)}%)",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          
          // Summary section
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Tổng báo cáo:",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      totalCount.toString(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Loại báo cáo:",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      reportCounts.length.toString(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Đảm bảo các hàm tiện ích được đặt trước khi sử dụng trong class
  List<ReportEntity> _filterReportsByMonth(List<ReportEntity> reports, DateTime month) {
    return reports.where((report) {
      if (report.createdAt == null) {
        return false;
      }
      try {
        final reportDate = DateTime.parse(report.createdAt!);
        return reportDate.year == month.year && reportDate.month == month.month;
      } catch (e) {
        _logger.e('ReportPieChart: Error parsing createdAt for reportId: \\${report.reportId} - \\$e');
        return false;
      }
    }).toList();
  }

  Map<int, int> _countReportsByType(List<ReportEntity> reports, List<ReportTypeEntity> reportTypes) {
    final Map<int, int> counts = {};
    for (var report in reports) {
      if (reportTypes.any((type) => type.reportTypeId == report.reportTypeId)) {
        counts[report.reportTypeId] = (counts[report.reportTypeId] ?? 0) + 1;
      }
    }
    return counts;
  }

  String _getMonthName(int month) {
    final monthNames = [
      'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6',
      'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'
    ];
    if (month >= 1 && month <= 12) {
      return monthNames[month - 1];
    }
    return 'Tháng không hợp lệ';
  }
}