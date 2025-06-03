// lib/src/features/report/presentation/widgets/report_pie_chart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Để hỗ trợ định dạng ngôn ngữ

import '../../../report/domain/entities/report_entity.dart';
import '../../../report/domain/entities/report_type_entity.dart';
import '../../../report/presentation/bloc/report/report_bloc.dart';
import '../../../report/presentation/bloc/report/report_event.dart';
import '../../../report/presentation/bloc/report/report_state.dart';
import '../../../report/presentation/bloc/rp_type/rp_type_bloc.dart';
import '../../../report/presentation/bloc/rp_type/rp_type_event.dart';
import '../../../report/presentation/bloc/rp_type/rp_type_state.dart';

class ReportPieChart extends StatefulWidget {
  const ReportPieChart({super.key});

  @override
  _ReportPieChartState createState() => _ReportPieChartState();
}

class _ReportPieChartState extends State<ReportPieChart> {
  DateTime selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Khởi tạo locale để hỗ trợ tiếng Việt
    initializeDateFormatting('vi', null).then((_) {
      setState(() {});
    });
    // Fetch report types and reports for the current month
    context.read<ReportTypeBloc>().add(const GetAllReportTypesEvent());
    _fetchReportsForMonth(selectedMonth);
  }

  void _fetchReportsForMonth(DateTime month) {
    // Assuming status null fetches all statuses; adjust if needed
    context.read<ReportBloc>().add(const GetAllReportsEvent(
      page: 1,
      limit: 1000, // Large limit to get all reports; consider pagination if needed
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Phân bố loại báo cáo - ${DateFormat('MMMM yyyy', 'vi').format(selectedMonth)}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Làm mới dữ liệu',
                      color: Colors.green,
                      onPressed: () {
                        _fetchReportsForMonth(selectedMonth);
                      },
                    ),
                    TextButton(
                      onPressed: () => _showMonthSelectionDialog(context),
                      child: const Text("Xem thêm"),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            BlocBuilder<ReportBloc, ReportState>(
              builder: (context, reportState) {
                return BlocBuilder<ReportTypeBloc, ReportTypeState>(
                  builder: (context, reportTypeState) {
                    if (reportState is ReportLoading || reportTypeState is ReportTypeLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (reportState is ReportError) {
                      return Center(child: Text('Lỗi: ${reportState.message}'));
                    }
                    if (reportTypeState is ReportTypeError) {
                      return Center(child: Text('Lỗi: ${reportTypeState.message}'));
                    }
                    if (reportState is ReportsLoaded && reportTypeState is ReportTypesLoaded) {
                      final reports = reportState.reports;
                      final reportTypes = reportTypeState.reportTypes;
                      return _buildPieChart(context, reports, reportTypes, selectedMonth);
                    }
                    return const Center(child: Text('Không có dữ liệu'));
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
    // Filter reports for the selected month
    final monthReports = reports.where((report) {
      if (report.createdAt == null) return false;
      try {
        final reportDate = DateTime.parse(report.createdAt!);
        return reportDate.year == month.year && reportDate.month == month.month;
      } catch (e) {
        return false;
      }
    }).toList();

    // Count reports by report type
    final reportCounts = <int, int>{};
    for (var report in monthReports) {
      reportCounts[report.reportTypeId] = (reportCounts[report.reportTypeId] ?? 0) + 1;
    }

    // Generate pie chart sections
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
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            badgeWidget: Text(
              reportType.name,
              style: const TextStyle(fontSize: 0), // Hidden for tooltip use
            ),
          ),
        );
      }
    }

    // Handle no data case
    final isEmpty = sections.isEmpty;
    if (isEmpty) {
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
          badgeWidget: const Text(
            'Không có dữ liệu',
            style: TextStyle(fontSize: 0), // Hidden for tooltip use
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: sections,
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                pieTouchData: PieTouchData(
                  enabled: true,
                  touchCallback: (FlTouchEvent event, PieTouchResponse? pieTouchResponse) {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      return;
                    }
                    setState(() {}); // Refresh to update tooltip
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
    int selectedYear = selectedMonth.year;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Chọn tháng và năm'),
              content: SizedBox(
                width: double.maxFinite,
                height: 450,
                child: Column(
                  children: [
                    // Dropdown để chọn năm
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
                    // Grid để chọn tháng
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
                            onPressed: () {
                              setState(() {
                                selectedMonth = month;
                                _fetchReportsForMonth(month);
                              });
                              Navigator.pop(context);
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
                  onPressed: () => _showAllMonthsCharts(context, selectedYear),
                  child: const Text('Xem tất cả các tháng'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
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
    Navigator.pop(context); // Close the dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Phân bố báo cáo theo tháng - Năm $year'),
          content: SizedBox(
            width: double.maxFinite,
            height: 600,
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
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }
}