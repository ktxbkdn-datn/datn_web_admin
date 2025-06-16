import 'package:datn_web_admin/feature/dashboard/presentation/bloc/statistic_bloc.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/bloc/statistic_event.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/bloc/statistic_state.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/widgets/fill_rate_pie_chart.dart';
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
  final Logger _logger = Logger();
  List<Map<String, dynamic>> _summaryData = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
    context.read<AreaBloc>().add(FetchAreasEvent(page: 1, limit: 100));
    context.read<StatisticsBloc>().add(LoadCachedUserMonthlyStatsEvent());
  }

  void _fetchData() {
    _logger.i('Fetching user summary and fill rate for year: $_selectedYear, areaId: $_selectedAreaId');
    context.read<StatisticsBloc>().add(FetchUserSummary(
      year: _selectedYear,
      areaId: _selectedAreaId,
    ));
    context.read<StatisticsBloc>().add(FetchRoomFillRateStats(
      areaId: _selectedAreaId,
      roomId: null,
    ));
  }

  void _triggerSnapshot() {
    _logger.i('Triggering manual snapshot for year: $_selectedYear');
    context.read<StatisticsBloc>().add(TriggerManualSnapshot(
      year: _selectedYear,
      month: null,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề
          const Text(
            'Thống kê sinh viên đang lưu trú theo tháng',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          // Các button, dropdown, snapshot...
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
                            _summaryData = [];
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
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedYear = value;
                          _summaryData = [];
                        });
                        _fetchData();
                      }
                    },
                  ),
                ],
              ),
              Row(
                children: [
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
            ],
          ),
          const SizedBox(height: 16),
          BlocBuilder<StatisticsBloc, StatisticsState>(
            buildWhen: (previous, current) =>
                current is StatisticsLoading ||
                (current is PartialLoading && current.requestType == 'user_summary') ||
                (current is StatisticsError && current.message.contains('user_summary')) ||
                current is UserSummaryLoaded ||
                current is UserMonthlyStatsLoaded ||
                current is ManualSnapshotTriggered,
            builder: (context, state) {
              _logger.i('Bar chart state: $state');

              if (state is UserSummaryLoaded) {
                _summaryData = state.summaryData;
              } else if (state is UserMonthlyStatsLoaded) {
                _summaryData = state.userMonthlyStatsData.map((data) {
                  return {
                    'month': data.months,
                    'total_users': data.totalUsers,
                  };
                }).toList();
              }

              if (state is StatisticsLoading || (state is PartialLoading && state.requestType == 'user_summary')) {
                if (_summaryData.isNotEmpty) {
                  _logger.i('Displaying cached data while loading');
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              } else if (state is StatisticsError && state.message.contains('user_summary')) {
                _logger.e('User summary error: ${state.message}');
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

              if (_summaryData.isNotEmpty) {
                final maxY = _getMaxY(_summaryData);
                final roundedMaxY = maxY == 0 ? 10.0 : _roundMaxYToEven(maxY);

                return ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: 200.0,
                    maxHeight: 300.0,
                    minWidth: double.infinity,
                  ),
                  child: Builder(
                    builder: (context) {
                      try {
                        final chartWidth = MediaQuery.of(context).size.width - 32;
                        final chartHeight = 300.0;
                        final yInterval = _calculateYInterval(roundedMaxY, chartHeight);

                        _logger.d('Bar chart dimensions: width=$chartWidth, height=$chartHeight, maxY=$maxY, yInterval=$yInterval');

                        return BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            barTouchData: BarTouchData(
                              enabled: true,
                              touchTooltipData: BarTouchTooltipData(
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  final month = groupIndex + 1;
                                  final value = _getUserCount(_summaryData, month);
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
                                    if (yInterval > 0 && value % yInterval != 0) return const SizedBox.shrink();
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
                            barGroups: List.generate(12, (month) => _buildBarGroup(month, _summaryData)),
                            minY: 0,
                            maxY: roundedMaxY,
                          ),
                        );
                      } catch (e, stackTrace) {
                        _logger.e('BarChart rendering error: $e, stack: $stackTrace');
                        return const Center(child: Text('Lỗi hiển thị biểu đồ'));
                      }
                    },
                  ),
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
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
          const SizedBox(height: 24),
          SizedBox(
            height: 320,
            width: double.infinity,
            child: FillRatePieChart(
              selectedAreaId: _selectedAreaId,
              chartHeight: 320,
              chartWidth: double.infinity,
            ),
          ),
        ],
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