// lib/src/features/dashboard/presentation/widgets/user_stat_page.dart
import 'package:datn_web_admin/feature/dashboard/domain/entities/user_monthly_stats.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/bloc/statistic_bloc.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/bloc/statistic_event.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/bloc/statistic_state.dart';
import 'package:datn_web_admin/feature/room/presentations/bloc/area_bloc/area_bloc.dart';
import 'package:datn_web_admin/feature/room/presentations/bloc/area_bloc/area_event.dart';
import 'package:datn_web_admin/feature/room/presentations/bloc/area_bloc/area_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../common/constants/colors.dart';

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

  @override
  void initState() {
    super.initState();
    print('Fetching initial user stats for year: $_selectedYear');
    context.read<StatisticsBloc>().add(FetchUserMonthlyStats(
      year: _selectedYear,
      month: null,
      quarter: null,
      areaId: _selectedAreaId,
    ));
    context.read<AreaBloc>().add(FetchAreasEvent(page: 1, limit: 100));
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  void _fetchData() {
    print('Fetching user stats for year: $_selectedYear, areaId: $_selectedAreaId');
    context.read<StatisticsBloc>().add(FetchUserMonthlyStats(
      year: _selectedYear,
      month: null,
      quarter: null,
      areaId: _selectedAreaId,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Flexible(
                  child: Text(
                    'Thống kê người dùng',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
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
                  print('Current StatisticsBloc state: $state');
                  if (state is StatisticsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is StatisticsError) {
                    return Center(child: Text('Lỗi: ${state.message}'));
                  } else if (state is UserMonthlyStatsLoaded) {
                    print('UserMonthlyStatsLoaded with data: ${state.userMonthlyStatsData}');
                    if (state.userMonthlyStatsData.isEmpty) {
                      return const Center(child: Text('Không có dữ liệu'));
                    }

                    List<UserMonthlyStats> filteredData;
                    if (_selectedAreaId == null) {
                      filteredData = state.userMonthlyStatsData;
                    } else {
                      filteredData = state.userMonthlyStatsData
                          .where((area) => area.areaId == _selectedAreaId)
                          .toList();
                    }

                    if (filteredData.isEmpty) {
                      return const Center(child: Text('Không có dữ liệu cho khu vực này'));
                    }

                    print('Filtered data: $filteredData');
                    final maxY = _getMaxY(filteredData);
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
                                        final month = groupIndex + 1;
                                        final value = _getUserCount(filteredData, month);
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
                                          if (value.toInt() % yInterval.toInt() != 0) {
                                            return const SizedBox.shrink();
                                          }
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
                                  barGroups: List.generate(12, (month) => _buildBarGroup(month, filteredData)),
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
                  }
                  return const Center(child: Text('Không có dữ liệu'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int month, List<UserMonthlyStats> data) {
    final monthKey = month + 1;
    final value = _getUserCount(data, monthKey);
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

  double _getMaxY(List<UserMonthlyStats> data) {
    double maxY = 0;
    for (int month = 1; month <= 12; month++) {
      final value = _getUserCount(data, month);
      if (value > maxY) maxY = value.toDouble();
    }
    return maxY * 1.1;
  }

  double _roundMaxYToEven(double maxY) {
    int rounded = (maxY / 5).ceil() * 5;
    return rounded.toDouble();
  }

  double _calculateYInterval(double maxY, double chartHeight) {
    const pixelsPerLabel = 40.0;
    final valuePerPixel = maxY / chartHeight;
    final minIntervalPixels = pixelsPerLabel / valuePerPixel;
    final interval = (minIntervalPixels / 5).ceil() * 5.0;
    return interval.clamp(5.0, maxY / 2);
  }

  int _getUserCount(List<UserMonthlyStats> data, int month) {
    int count = 0;
    for (var area in data) {
      count += area.months[month] ?? 0;
    }
    return count;
  }
}