// lib/src/features/dashboard/presentation/widgets/room_stat_page.dart
import 'package:datn_web_admin/feature/dashboard/domain/entities/room_status.dart';
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

class RoomStatsPage extends StatefulWidget {
  const RoomStatsPage({Key? key}) : super(key: key);

  @override
  _RoomStatsPageState createState() => _RoomStatsPageState();
}

class _RoomStatsPageState extends State<RoomStatsPage> {
  int _selectedYear = DateTime.now().year;
  int? _selectedAreaId;
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<StatisticsBloc>().add(FetchRoomStatusStats(year: _selectedYear));
    context.read<AreaBloc>().add(FetchAreasEvent(page: 1, limit: 100));
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  void _fetchData() {
    context.read<StatisticsBloc>().add(FetchRoomStatusStats(year: _selectedYear, areaId: _selectedAreaId));
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
                    'Thống kê trạng thái phòng',
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
                  if (state is StatisticsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is StatisticsError) {
                    return Center(child: Text('Lỗi: ${state.message}'));
                  } else if (state is RoomStatusLoaded) {
                    if (state.roomStatusData.isEmpty) {
                      return const Center(child: Text('Không có dữ liệu'));
                    }

                    final statuses = _getStatuses(state.roomStatusData);
                    final colors = _generateColors(statuses.length);
                    final maxY = _getMaxY(state.roomStatusData, statuses);
                    final roundedMaxY = _roundMaxYToEven(maxY);

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final chartWidth = constraints.maxWidth;
                        final chartHeight = constraints.maxHeight * 0.8; // Tăng chiều cao biểu đồ để có thêm không gian
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
                                        final status = _translateStatus(statuses[rodIndex]);
                                        final month = groupIndex + 1;
                                        final value = _getStatusCount(state.roomStatusData, month, statuses[rodIndex]);
                                        return BarTooltipItem(
                                          '$status\n$value phòng',
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
                                    horizontalInterval: yInterval, // Đồng bộ lưới với nhãn trục Y
                                  ),
                                  barGroups: List.generate(12, (month) => _buildBarGroup(month, state.roomStatusData, statuses, colors)),
                                  minY: 0,
                                  maxY: roundedMaxY,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: List.generate(statuses.length, (index) {
                                final status = _translateStatus(statuses[index]);
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(width: 10, height: 10, color: colors[index]),
                                    const SizedBox(width: 4),
                                    Text(status, style: const TextStyle(fontSize: 12)),
                                  ],
                                );
                              }),
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

  List<String> _getStatuses(List<RoomStatus> data) {
    final statuses = <String>{};
    for (var area in data) {
      statuses.addAll(area.statusCounts.keys);
    }
    return statuses.toList();
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

  BarChartGroupData _buildBarGroup(int month, List<RoomStatus> data, List<String> statuses, List<Color> colors) {
    final monthKey = month + 1;
    return BarChartGroupData(
      x: month,
      barRods: List.generate(statuses.length, (index) {
        final status = statuses[index];
        final value = _getStatusCount(data, monthKey, status);
        return BarChartRodData(
          toY: value.toDouble(),
          color: colors[index],
          width: 12,
          borderRadius: BorderRadius.circular(4),
        );
      }),
    );
  }

  double _getMaxY(List<RoomStatus> data, List<String> statuses) {
    double maxY = 0;
    for (int month = 1; month <= 12; month++) {
      for (var status in statuses) {
        final value = _getStatusCount(data, month, status);
        if (value > maxY) maxY = value.toDouble();
      }
    }
    return maxY * 1.1;
  }

  double _roundMaxYToEven(double maxY) {
    int rounded = (maxY / 5).ceil() * 5;
    return rounded.toDouble();
  }

  double _calculateYInterval(double maxY, double chartHeight) {
    // Ước tính số pixel trên mỗi đơn vị giá trị
    const pixelsPerLabel = 40.0; // Khoảng cách tối thiểu giữa các nhãn (pixel)
    final valuePerPixel = maxY / chartHeight; // Giá trị tương ứng với 1 pixel
    final minIntervalPixels = pixelsPerLabel / valuePerPixel; // Giá trị tối thiểu giữa các nhãn
    // Làm tròn minIntervalPixels thành bội số của 5
    final interval = (minIntervalPixels / 5).ceil() * 5.0;
    return interval.clamp(5.0, maxY / 2); // Đảm bảo không quá thưa hoặc quá mật
  }

  int _getStatusCount(List<RoomStatus> data, int month, String status) {
    int count = 0;
    for (var area in data) {
      if (area.areaId == null) continue;
      if (_selectedAreaId == null || area.areaId == _selectedAreaId) {
        count += area.statusCounts[status] ?? 0;
      }
    }
    return count;
  }

  String _translateStatus(String status) {
    switch (status.toUpperCase()) {
      case 'AVAILABLE':
        return 'Có sẵn';
      case 'OCCUPIED':
        return 'Đã sử dụng';
      default:
        return status;
    }
  }
}