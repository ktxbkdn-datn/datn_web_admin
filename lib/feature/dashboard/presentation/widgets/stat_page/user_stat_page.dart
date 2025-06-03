import 'package:datn_web_admin/feature/dashboard/presentation/bloc/statistic_bloc.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/bloc/statistic_event.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/bloc/statistic_state.dart';
import 'package:datn_web_admin/feature/room/presentations/bloc/area_bloc/area_bloc.dart';
import 'package:datn_web_admin/feature/room/presentations/bloc/area_bloc/area_event.dart';
import 'package:datn_web_admin/feature/room/presentations/bloc/area_bloc/area_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:logger/logger.dart';

class UserStatsPage extends StatefulWidget {
  const UserStatsPage({Key? key}) : super(key: key);

  @override
  _UserStatsPageState createState() => _UserStatsPageState();
}

class _UserStatsPageState extends State<UserStatsPage> {
  int _selectedYear = DateTime.now().year;
  int? _selectedAreaId;
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    _fetchData();
    context.read<AreaBloc>().add(FetchAreasEvent(page: 1, limit: 100));
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  void _fetchData() {
    _logger.i('Fetching user summary for year: $_selectedYear, areaId: $_selectedAreaId');
    context.read<StatisticsBloc>().add(FetchUserSummary(
      year: _selectedYear,
      areaId: _selectedAreaId,
    ));
  }

  void _triggerSnapshot() {
    _logger.i('Triggering manual snapshot for year: $_selectedYear');
    context.read<StatisticsBloc>().add(TriggerManualSnapshot(
      year: _selectedYear,
      month: null, // Snapshot for the whole year
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Thống kê sinh viên đang lưu trú theo tháng',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            tooltip: 'Làm mới dữ liệu',
            onPressed: _fetchData,
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt, color: Colors.black87),
            tooltip: 'Chụp snapshot',
            onPressed: _triggerSnapshot,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                          _logger.e('AreaBloc error: ${areaState.error}');
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
                            });
                            _fetchData();
                          },
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<int>(
                      value: _selectedYear,
                      items: List.generate(10, (index) => DateTime.now().year - 5 + index)
                          .map((year) => DropdownMenuItem(value: year, child: Text(year.toString())))
                          .toList(),
                      onChanged: (year) {
                        if (year != null) {
                          setState(() {
                            _selectedYear = year;
                          });
                          _fetchData();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<StatisticsBloc, StatisticsState>(
                builder: (context, state) {
                  _logger.i('StatisticsBloc state: $state');
                  if (state is StatisticsLoading || state is PartialLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is StatisticsError) {
                    _logger.e('StatisticsError: ${state.message}');
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
                  } else if (state is UserSummaryLoaded) {
                    if (state.summaryData.isEmpty) {
                      _logger.w('No user summary data');
                      return const Center(child: Text('Không có dữ liệu'));
                    }

                    final maxY = _getMaxY(state.summaryData);
                    final roundedMaxY = maxY == 0 ? 10.0 : _roundMaxYToEven(maxY);

                    _logger.i('Summary data: ${state.summaryData}');
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final chartWidth = constraints.maxWidth;
                        final chartHeight = constraints.maxHeight * 0.8 > 0 ? constraints.maxHeight * 0.8 : 200.0;
                        final yInterval = _calculateYInterval(roundedMaxY, chartHeight);

                        _logger.d('Chart dimensions: width=$chartWidth, height=$chartHeight, maxY=$maxY, yInterval=$yInterval');
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
                                        final month = groupIndex + 1;
                                        final value = _getUserCount(state.summaryData, month);
                                        return BarTooltipItem(
                                          'Tháng $month\n$value người',
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
                                          if (value < 0 || value > roundedMaxY) return const SizedBox.shrink();
                                          if (yInterval > 0 && value.toInt() % yInterval.toInt() != 0) return const SizedBox.shrink();
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
                                  barGroups: List.generate(12, (month) => _buildBarGroup(month, state.summaryData)),
                                  minY: 0,
                                  maxY: roundedMaxY,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.person, color: Colors.blue, size: 16),
                                    SizedBox(width: 4),
                                    Text('Người dùng', style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    );
                  } else if (state is ManualSnapshotTriggered) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message)),
                      );
                    });
                    _fetchData(); // Refresh data after snapshot
                    return const Center(child: Text('Đang làm mới dữ liệu sau snapshot...'));
                  } else if (state is StatisticsInitial) {
                    return const Center(child: Text('Đang khởi tạo...'));
                  } else {
                    _logger.w('Unexpected state: $state');
                    return const Center(child: Text('Không có dữ liệu'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int month, List<Map<String, dynamic>> data) {
    final monthKey = month + 1;
    final value = _getUserCount(data, monthKey);
    _logger.d('Building bar group for month $monthKey: value = $value');
    return BarChartGroupData(
      x: month,
      barRods: [
        BarChartRodData(
          toY: value.toDouble(),
          color: Colors.blue,
          width: 12,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  double _getMaxY(List<Map<String, dynamic>> data) {
    double maxY = 0;
    for (var monthData in data) {
      final value = _safeToDouble(monthData['total_users']);
      if (value > maxY) maxY = value;
    }
    _logger.d('Max Y value: $maxY');
    return maxY * 1.1; // Add 10% padding
  }

  double _roundMaxYToEven(double maxY) {
    return ((maxY / 5).ceil() * 5).toDouble();
  }

  double _calculateYInterval(double maxY, double chartHeight) {
    if (maxY <= 0 || chartHeight <= 0) return 1.0; // Smaller default interval
    const pixelsPerLabel = 40.0;
    final valuePerPixel = maxY / chartHeight;
    final minIntervalPixels = pixelsPerLabel / valuePerPixel;
    final interval = (minIntervalPixels / 5).ceil() * 5.0;
    return interval.clamp(1.0, maxY / 2);
  }

  int _getUserCount(List<Map<String, dynamic>> data, int month) {
    final monthData = data.firstWhere(
      (d) => d['month'] == month,
      orElse: () => {'month': month, 'total_users': 0},
    );
    final count = _safeToInt(monthData['total_users']);
    _logger.d('User count for month $month: $count');
    return count;
  }

  double _safeToDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed ?? 0.0;
    }
    return 0.0;
  }

  int _safeToInt(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed ?? 0;
    }
    return 0;
  }
}