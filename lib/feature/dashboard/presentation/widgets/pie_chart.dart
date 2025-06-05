import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../report/domain/entities/report_entity.dart';
import '../../../report/domain/entities/report_type_entity.dart';
import '../../../report/presentation/bloc/report/report_bloc.dart';
import '../../../report/presentation/bloc/report/report_event.dart';
import '../../../report/presentation/bloc/report/report_state.dart';
import '../../../report/presentation/bloc/rp_type/rp_type_bloc.dart';
import '../../../report/presentation/bloc/rp_type/rp_type_event.dart';
import '../../../report/presentation/bloc/rp_type/rp_type_state.dart';
import 'package:datn_web_admin/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:datn_web_admin/feature/auth/presentation/bloc/auth_state.dart';

class ReportPieChart extends StatefulWidget {
  final double chartWidth;
  final double chartHeight;

  const ReportPieChart({
    super.key,
    required this.chartWidth,
    required this.chartHeight,
  });

  @override
  _ReportPieChartState createState() => _ReportPieChartState();
}

class _ReportPieChartState extends State<ReportPieChart> {
  DateTime selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('vi', null).then((_) {
      setState(() {});
    });
    final authState = context.read<AuthBloc>().state;
    if (authState.auth != null) {
      context.read<ReportTypeBloc>().add(const GetAllReportTypesEvent());
      _fetchReportsForMonth(selectedMonth);
    } else {
      debugPrint('ReportPieChart: No auth token, skipping fetch');
    }
  }

  void _fetchReportsForMonth(DateTime month) {
    final authState = context.read<AuthBloc>().state;
    if (authState.auth != null) {
      context.read<ReportBloc>().add(const GetAllReportsEvent(
        page: 1,
        limit: 1000,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    "Phân bố loại báo cáo - ${DateFormat('MMMM yyyy', 'vi').format(selectedMonth)}",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 28),
                      tooltip: 'Làm mới dữ liệu',
                      color: Colors.green,
                      onPressed: () {
                        final authState = context.read<AuthBloc>().state;
                        if (authState.auth != null) {
                          context.read<ReportBloc>().add(const GetAllReportsEvent(
                            page: 1,
                            limit: 1000,
                          ));
                        }
                      },
                    ),
                    TextButton(
                      onPressed: () => _showMonthSelectionDialog(context),
                      child: const Text("Xem thêm", style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            BlocBuilder<ReportBloc, ReportState>(
              builder: (context, reportState) {
                return BlocBuilder<ReportTypeBloc, ReportTypeState>(
                  builder: (context, reportTypeState) {
                    if (reportState is ReportLoading || reportTypeState is ReportTypeLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (reportState is ReportError) {
                      return Center(child: Text('Lỗi: ${reportState.message}', style: const TextStyle(fontSize: 16)));
                    }
                    if (reportTypeState is ReportTypeError) {
                      return Center(child: Text('Lỗi: ${reportTypeState.message}', style: const TextStyle(fontSize: 16)));
                    }
                    if (reportState is ReportsLoaded && reportTypeState is ReportTypesLoaded) {
                      final reports = reportState.reports;
                      final reportTypes = reportTypeState.reportTypes;
                      return _buildPieChart(context, reports, reportTypes, selectedMonth);
                    }
                    return const Center(child: Text('Không có dữ liệu', style: TextStyle(fontSize: 16)));
                  },
                );
              },
            ),
          ],
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
      if (report.createdAt == null) return false;
      try {
        final reportDate = DateTime.parse(report.createdAt!);
        return reportDate.year == month.year && reportDate.month == month.month;
      } catch (e) {
        return false;
      }
    }).toList();

    final reportCounts = <int, int>{};
    for (var report in monthReports) {
      reportCounts[report.reportTypeId] = (reportCounts[report.reportTypeId] ?? 0) + 1;
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
    for (var i = 0; i < reportTypes.length; i++) {
      final reportType = reportTypes[i];
      final count = reportCounts[reportType.reportTypeId] ?? 0;
      if (count > 0) {
        final percentage = totalReports > 0 ? (count / totalReports) * 100 : 0;
        sections.add(
          PieChartSectionData(
            color: colors[i % colors.length],
            value: count.toDouble(),
            title: '${percentage.toStringAsFixed(1)}%',
            radius: 80, // Increased radius for larger chart
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            badgeWidget: Text(
              reportType.name,
              style: const TextStyle(fontSize: 0),
            ),
          ),
        );
      }
    }

    final isEmpty = sections.isEmpty;
    if (isEmpty) {
      sections.add(
        PieChartSectionData(
          color: Colors.grey,
          value: 1,
          title: 'Không có dữ liệu',
          radius: 80, // Increased radius
          titleStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          badgeWidget: const Text(
            'Không có dữ liệu',
            style: TextStyle(fontSize: 0),
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2, // Give more space to the chart
          child: SizedBox(
            width: widget.chartWidth * 0.6, // Use more of the available width
            height: widget.chartHeight - 60, // Slightly reduced to fit title/buttons
            child: PieChart(
              PieChartData(
                sections: sections,
                sectionsSpace: 3,
                centerSpaceRadius: 30, // Reduced to give more space to sections
                pieTouchData: PieTouchData(
                  enabled: true,
                  touchCallback: (FlTouchEvent event, PieTouchResponse? pieTouchResponse) {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      return;
                    }
                    setState(() {});
                  },
                ),
              ),
              swapAnimationDuration: const Duration(milliseconds: 150),
              swapAnimationCurve: Curves.linear,
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: Column(
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
        ),
      ],
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            color: color,
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showMonthSelectionDialog(BuildContext context) {
    int selectedYear = selectedMonth.year;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Chọn tháng và năm', style: TextStyle(fontSize: 20)),
              content: SizedBox(
                width: double.maxFinite,
                height: 500,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Năm: ', style: TextStyle(fontSize: 18)),
                        DropdownButton<int>(
                          value: selectedYear,
                          items: List.generate(
                            10,
                            (index) {
                              final year = DateTime.now().year - 5 + index;
                              return DropdownMenuItem<int>(
                                value: year,
                                child: Text('$year', style: const TextStyle(fontSize: 16)),
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
                    const SizedBox(height: 20),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                        ),
                        itemCount: 12,
                        itemBuilder: (context, index) {
                          final month = DateTime(selectedYear, index + 1);
                          return ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedMonth = month;
                                _fetchReportsForMonth(month);
                              });
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(12),
                            ),
                            child: Text('Tháng ${index + 1}', style: const TextStyle(fontSize: 14)),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => _showAllMonthsCharts(context, selectedYear),
                  child: const Text('Xem tất cả các tháng', style: TextStyle(fontSize: 16)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Đóng', style: TextStyle(fontSize: 16)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAllMonthsCharts(BuildContext context, int year) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Phân bố báo cáo theo tháng - Năm $year', style: const TextStyle(fontSize: 20)),
          content: SizedBox(
            width: double.maxFinite,
            height: 800, // Increased height for larger charts
            child: ListView.builder(
              itemCount: 12,
              itemBuilder: (context, index) {
                final month = DateTime(year, index + 1);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('MMMM yyyy', 'vi').format(month),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
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
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng', style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }
}