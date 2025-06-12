import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:logger/logger.dart';
import '../../../report/domain/entities/report_entity.dart';
import '../../../report/domain/entities/report_type_entity.dart';
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
  double pieRadius = 50.0;

  ReportPieChart({
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
  bool _isFetchingReports = false;
  Timer? _debounce;

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
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchReportsForMonth(DateTime month) async {
    final authState = context.read<AuthBloc>().state;
    if (authState.auth == null || _isFetchingReports) return;

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final reportState = context.read<ReportBloc>().state;
      if (reportState is ReportInitial ||
          reportState is ReportError ||
          (reportState is ReportsLoaded &&
              !reportState.reports.any((r) =>
                  r.createdAt != null &&
                  DateTime.tryParse(r.createdAt!)?.month == month.month &&
                  DateTime.tryParse(r.createdAt!)?.year == month.year))) {
        _logger.i('ReportPieChart: Fetching reports for month ${month.month}/${month.year}');
        if (mounted) {
          setState(() {
            _isFetchingReports = true;
          });
        }

        context.read<ReportBloc>().add(const GetAllReportsEvent(
          page: 1,
          limit: 1000,
        ));

        // Timeout to prevent prolonged loading
        await Future.any([
          Future.delayed(const Duration(seconds: 10)),
          Future(() async {
            while (_isFetchingReports && mounted) {
              await Future.delayed(const Duration(milliseconds: 100));
            }
          }),
        ]);

        if (_isFetchingReports && mounted) {
          setState(() {
            _isFetchingReports = false;
          });
          _logger.w('ReportPieChart: Fetch timeout for month ${month.month}/${month.year}');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: ValueListenableBuilder<DateTime>(
            valueListenable: _selectedMonth,
            builder: (context, month, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          "Phân bố loại báo cáo - ${DateFormat('MMMM yyyy', 'vi').format(month)}",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            tooltip: 'Làm mới dữ liệu',
                            color: Colors.green,
                            onPressed: _isFetchingReports
                                ? null
                                : () {
                                    final authState = context.read<AuthBloc>().state;
                                    if (authState.auth != null) {
                                      _logger.i('ReportPieChart: Refreshing reports');
                                      if (mounted) {
                                        setState(() {
                                          _isFetchingReports = true;
                                        });
                                      }
                                      context.read<ReportBloc>().add(const GetAllReportsEvent(
                                        page: 1,
                                        limit: 1000,
                                      ));
                                    }
                                  },
                          ),
                          TextButton(
                            onPressed: _isFetchingReports ? null : () => _showMonthSelectionDialog(context),
                            child: const Text("Xem thêm"),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  BlocListener<ReportBloc, ReportState>(
                    listener: (context, state) {
                      if (state is ReportsLoaded || state is ReportError) {
                        if (mounted) {
                          setState(() {
                            _isFetchingReports = false;
                          });
                        }
                      }
                    },
                    child: BlocBuilder<ReportBloc, ReportState>(
                      builder: (context, reportState) {
                        return BlocBuilder<ReportTypeBloc, ReportTypeState>(
                          builder: (context, reportTypeState) {
                            if (reportState is ReportLoading || reportTypeState is ReportTypeLoading || _isFetchingReports) {
                              _logger.i('ReportPieChart: Loading state');
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (reportState is ReportError) {
                              _logger.e('ReportPieChart: Report error - ${reportState.message}');
                              return Center(child: Text('Lỗi: ${reportState.message}'));
                            }
                            if (reportTypeState is ReportTypeError) {
                              _logger.e('ReportPieChart: Report type error - ${reportTypeState.message}');
                              return Center(child: Text('Lỗi: ${reportTypeState.message}'));
                            }
                            if (reportState is ReportsLoaded && reportTypeState is ReportTypesLoaded) {
                              if (reportTypeState.reportTypes.isEmpty) {
                                _logger.w('ReportPieChart: No report types available');
                                return const Center(child: Text('Không có loại báo cáo'));
                              }
                              _logger.i('ReportPieChart: Rendering chart with ${reportState.reports.length} reports and ${reportTypeState.reportTypes.length} report types');
                              return _buildPieChart(context, reportState.reports, reportTypeState.reportTypes, month);
                            }
                            _logger.w('ReportPieChart: No data available');
                            return const Center(child: Text('Không có dữ liệu'));
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart(
    BuildContext context,
    List<ReportEntity> reports,
    List<ReportTypeEntity> reportTypes,
    DateTime month,
  ) {
    final monthReports = reports.where((report) {
      if (report.createdAt == null) {
        _logger.w('ReportPieChart: Report with null createdAt - reportId: ${report.reportId}');
        return false;
      }
      try {
        final reportDate = DateTime.parse(report.createdAt!);
        return reportDate.year == month.year && reportDate.month == month.month;
      } catch (e) {
        _logger.e('ReportPieChart: Error parsing createdAt for reportId: ${report.reportId} - $e');
        return false;
      }
    }).toList();

    _logger.i('ReportPieChart: Filtered ${monthReports.length} reports for ${month.month}/${month.year}');

    final reportCounts = <int, int>{};
    for (var report in monthReports) {
      if (reportTypes.any((type) => type.reportTypeId == report.reportTypeId)) {
        reportCounts[report.reportTypeId] = (reportCounts[report.reportTypeId] ?? 0) + 1;
      } else {
        _logger.w('ReportPieChart: Report type ${report.reportTypeId} not found in reportTypes');
      }
    }

    final colors = [
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.yellow,
      Colors.teal,
      Colors.pink,
    ];
    final sections = <PieChartSectionData>[];
    final double totalReports = monthReports.length.toDouble();

    for (var reportType in reportTypes) {
      final count = reportCounts[reportType.reportTypeId] ?? 0;
      if (count > 0) {
        final percentage = totalReports > 0 ? (count / totalReports) * 100 : 0;
        final colorIndex = reportTypes.indexOf(reportType) % colors.length;
        sections.add(
          PieChartSectionData(
            color: colors[colorIndex],
            value: count.toDouble(),
            title: totalReports > 0 ? '${percentage.toStringAsFixed(1)}%' : '',
            radius: widget.pieRadius,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            badgeWidget: const SizedBox.shrink(),
          ),
        );
      }
    }

    final isEmpty = sections.isEmpty;
    if (isEmpty) {
      _logger.w('ReportPieChart: No valid sections to render');
      sections.add(
        PieChartSectionData(
          color: Colors.grey,
          value: 1,
          title: 'Không có dữ liệu',
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          badgeWidget: const SizedBox.shrink(),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SizedBox(
            width: widget.chartWidth / 1.5,
            height: widget.chartHeight - 40,
            child: PieChart(
              PieChartData(
                sections: sections,
                sectionsSpace: 2,
                centerSpaceRadius: widget.pieRadius / 6,
                pieTouchData: PieTouchData(
                  enabled: widget.isEnlarged, // Enable touch only in enlarged view
                  touchCallback: (FlTouchEvent event, PieTouchResponse? pieTouchResponse) {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      return;
                    }
                    if (mounted) {
                      _logger.i('ReportPieChart: Touched section ${pieTouchResponse.touchedSection!.touchedSectionIndex}');
                    }
                  },
                ),
              ),
              swapAnimationDuration: const Duration(milliseconds: 150),
              swapAnimationCurve: Curves.linear,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: isEmpty
              ? [
                  _buildLegendItem('Không có dữ liệu', Colors.grey),
                ]
              : reportTypes
                  .asMap()
                  .entries
                  .where((entry) => reportCounts.containsKey(entry.value.reportTypeId))
                  .map((entry) => _buildLegendItem(
                        entry.value.name,
                        colors[entry.key % colors.length],
                      ))
                  .toList(),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  void _showMonthSelectionDialog(BuildContext context) {
    int selectedYear = _selectedMonth.value.year;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Chọn tháng và năm'),
              content: SizedBox(
                width: double.maxFinite,
                height: 450,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Năm: ', style: TextStyle(fontSize: 16)),
                        DropdownButton<int>(
                          value: selectedYear,
                          items: List.generate(
                            10,
                            (index) {
                              final year = DateTime.now().year - 5 + index;
                              return DropdownMenuItem<int>(
                                value: year,
                                child: Text('$year'),
                              );
                            },
                          ),
                          onChanged: (int? newYear) {
                            if (newYear != null) {
                              setDialogState(() {
                                selectedYear = newYear;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 2,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                        itemCount: 12,
                        itemBuilder: (context, index) {
                          final month = DateTime(selectedYear, index + 1);
                          return ElevatedButton(
                            onPressed: _isFetchingReports
                                ? null
                                : () {
                                    _logger.i('ReportPieChart: Selected month ${month.month}/${month.year}');
                                    _selectedMonth.value = month;
                                    _fetchReportsForMonth(month);
                                    Future.delayed(Duration.zero, () {
                                      if (Navigator.canPop(dialogContext)) {
                                        Navigator.of(dialogContext).pop();
                                      }
                                    });
                                  },
                            child: Text('Tháng ${index + 1}'),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: _isFetchingReports
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop();
                          _showAllMonthsCharts(context, selectedYear);
                        },
                  child: const Text('Xem tất cả các tháng'),
                ),
                TextButton(
                  onPressed: () {
                    if (Navigator.canPop(dialogContext)) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  child: const Text('Đóng'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAllMonthsCharts(BuildContext context, int year) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Phân bố báo cáo theo tháng - Năm $year'),
          content: SizedBox(
            width: double.maxFinite,
            height: 700,
            child: ListView.builder(
              itemCount: 12,
              itemBuilder: (context, index) {
                final month = DateTime(year, index + 1);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('MMMM yyyy', 'vi').format(month),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      BlocBuilder<ReportBloc, ReportState>(
                        builder: (context, reportState) {
                          return BlocBuilder<ReportTypeBloc, ReportTypeState>(
                            builder: (context, reportTypeState) {
                              if (reportState is ReportsLoaded && reportTypeState is ReportTypesLoaded) {
                                return _buildPieChart(
                                  context,
                                  reportState.reports,
                                  reportTypeState.reportTypes,
                                  month,
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (Navigator.canPop(dialogContext)) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }
}