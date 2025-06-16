import 'package:datn_web_admin/feature/dashboard/domain/entities/report_stats.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/bloc/statistic_bloc.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/bloc/statistic_event.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/bloc/statistic_state.dart';
import 'package:datn_web_admin/feature/room/presentations/bloc/area_bloc/area_bloc.dart';
import 'package:datn_web_admin/feature/room/presentations/bloc/area_bloc/area_event.dart';
import 'package:datn_web_admin/feature/room/presentations/bloc/area_bloc/area_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportStatsPage extends StatefulWidget {
  const ReportStatsPage({Key? key}) : super(key: key);

  @override
  _ReportStatsPageState createState() => _ReportStatsPageState();
}

class _ReportStatsPageState extends State<ReportStatsPage> {
  int _selectedYear = DateTime.now().year;
  int? _selectedAreaId;
  List<ReportStats> _reportStatsData = []; // Cache data

  @override
  void initState() {
    super.initState();
    _fetchData();
    context.read<AreaBloc>().add(FetchAreasEvent(page: 1, limit: 100));
    context.read<StatisticsBloc>().add(LoadCachedReportStatsEvent());
  }

  void _fetchData() {
    context.read<StatisticsBloc>().add(FetchReportStats(
      year: _selectedYear,
      areaId: _selectedAreaId,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề
          const Text(
            'Thống kê báo cáo nhận được hằng tháng',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          // Các button, dropdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  BlocBuilder<AreaBloc, AreaState>(
                    builder: (context, areaState) {
                      if (areaState.isLoading) {
                        return const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2));
                      } else if (areaState.error != null) {
                        return const Text('Lỗi tải khu vực');
                      }
                      List<DropdownMenuItem<int?>> items = [
                        const DropdownMenuItem(value: null, child: Text('Tất cả')),
                        ...areaState.areas.map((area) => DropdownMenuItem(value: area.areaId, child: Text(area.name))),
                      ];
                      return DropdownButton<int?>(
                        value: _selectedAreaId,
                        items: items,
                        onChanged: (value) {
                          setState(() {
                            _selectedAreaId = value;
                            _reportStatsData = [];
                          });
                          _fetchData();
                        },
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<int>(
                    value: _selectedYear,
                    items: List.generate(6, (index) => 2020 + index)
                        .map((year) => DropdownMenuItem(value: year, child: Text(year.toString())))
                        .toList(),
                    onChanged: (year) {
                      if (year != null) {
                        setState(() {
                          _selectedYear = year;
                          _reportStatsData = [];
                        });
                        _fetchData();
                      }
                    },
                  ),
                ],
              ),
              // Nếu có nút snapshot hoặc filter khác, thêm ở đây
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<StatisticsBloc, StatisticsState>(
              buildWhen: (previous, current) =>
                  current is StatisticsLoading ||
                  current is StatisticsError ||
                  current is ReportStatsLoaded ||
                  current is ManualSnapshotTriggered,
              builder: (context, state) {
                if (state is ReportStatsLoaded) {
                  _reportStatsData = state.reportStatsData;
                }

                if (state is StatisticsLoading) {
                  if (_reportStatsData.isNotEmpty) {
                    // Hiển thị dữ liệu cũ khi loading
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                } else if (state is StatisticsError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Lỗi: ${state.message}'),
                        ElevatedButton(
                          onPressed: _fetchData,
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                } else if (state is ManualSnapshotTriggered) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  });
                  _fetchData();
                  return const Center(child: CircularProgressIndicator());
                }

                if (_reportStatsData.isNotEmpty) {
                  List<ReportStats> filteredData;
                  if (_selectedAreaId == null) {
                    filteredData = _reportStatsData;
                  } else {
                    filteredData = _reportStatsData.where((area) => area.areaId == _selectedAreaId).toList();
                  }

                  if (filteredData.isEmpty) {
                    return const Center(child: Text('Không có dữ liệu cho khu vực này'));
                  }

                  final reportTypes = _getReportTypes(filteredData);
                  final colors = _generateColors(reportTypes.length);
                  final maxY = _getMaxY(filteredData, reportTypes);
                  final roundedMaxY = _roundMaxYToEven(maxY);

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final chartWidth = constraints.maxWidth;
                      final chartHeight = constraints.maxHeight * 0.8;
                      final yInterval = _calculateYInterval(roundedMaxY, chartHeight);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: chartWidth,
                            height: chartHeight,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                barTouchData: BarTouchData(
                                  enabled: true,
                                  touchTooltipData: BarTouchTooltipData(
                                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                      final reportType = reportTypes[rodIndex];
                                      final month = groupIndex + 1;
                                      final value = _getReportCount(filteredData, month, reportType);
                                      return BarTooltipItem(
                                        '$reportType\n$value báo cáo',
                                        const TextStyle(color: Colors.white, fontSize: 12),
                                      );
                                    },
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        final month = value.toInt() + 1;
                                        return Text('T$month', style: const TextStyle(fontSize: 12, color: Colors.grey));
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                      interval: yInterval,
                                      getTitlesWidget: (value, meta) {
                                        if (value.toInt() % yInterval.toInt() != 0) return const SizedBox.shrink();
                                        return Text(
                                          value.toInt().toString(),
                                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                                        );
                                      },
                                    ),
                                  ),
                                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                borderData: FlBorderData(show: false),
                                gridData: FlGridData(
                                  show: true,
                                  drawHorizontalLine: true,
                                  horizontalInterval: yInterval,
                                ),
                                barGroups: List.generate(12, (month) => _buildBarGroup(month, filteredData, reportTypes, colors)),
                                minY: 0,
                                maxY: roundedMaxY,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: List.generate(reportTypes.length, (index) {
                              final reportType = reportTypes[index];
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(width: 10, height: 10, color: colors[index]),
                                  const SizedBox(width: 4),
                                  Text(reportType, style: const TextStyle(fontSize: 12)),
                                ],
                              );
                            }),
                          ),
                        ],
                      );
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getReportTypes(List<ReportStats> data) {
    final reportTypes = <String>{};
    for (var area in data) {
      reportTypes.addAll(area.reportTypes.values);
    }
    return reportTypes.toList();
  }

  List<Color> _generateColors(int count) {
    const colors = [
      Colors.green,
      Colors.blue,
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.amber,
    ];
    return List.generate(count, (index) => colors[index % colors.length]);
  }

  BarChartGroupData _buildBarGroup(int month, List<ReportStats> data, List<String> reportTypes, List<Color> colors) {
    final monthKey = month + 1;
    return BarChartGroupData(
      x: month,
      barRods: List.generate(reportTypes.length, (index) {
        final reportType = reportTypes[index];
        final value = _getReportCount(data, monthKey, reportType);
        return BarChartRodData(
          toY: value.toDouble(),
          color: colors[index],
          width: 12,
          borderRadius: BorderRadius.circular(4),
        );
      }),
    );
  }

  double _getMaxY(List<ReportStats> data, List<String> reportTypes) {
    double maxY = 0;
    for (int month = 1; month <= 12; month++) {
      for (var reportType in reportTypes) {
        final value = _getReportCount(data, month, reportType);
        if (value > maxY) maxY = value.toDouble();
      }
    }
    return maxY * 1.1;
  }

  double _roundMaxYToEven(double maxY) {
    return ((maxY / 5).ceil() * 5).toDouble();
  }

  double _calculateYInterval(double maxY, double chartHeight) {
    if (maxY <= 0 || chartHeight <= 10) return 1.0;
    const pixelsPerLabel = 40.0;
    final valuePerPixel = maxY / chartHeight;
    if (valuePerPixel <= 0 || valuePerPixel.isInfinite || valuePerPixel.isNaN) return 1.0;
    final minIntervalPixels = pixelsPerLabel / valuePerPixel;
    if (minIntervalPixels.isInfinite || minIntervalPixels.isNaN) return 1.0;
    final interval = (minIntervalPixels / 5).ceil() * 5.0;
    return interval.clamp(1.0, maxY / 2);
  }

  int _getReportCount(List<ReportStats> data, int month, String reportType) {
    int count = 0;
    for (var area in data) {
      area.years[_selectedYear]?.months[month]?.forEach((type, value) {
        if (type == reportType) count += value;
      });
    }
    return count;
  }
}