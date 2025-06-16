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
  final Logger _logger = Logger();
  List<Map<String, dynamic>> _summaryData = []; // Cache data

  @override
  void initState() {
    super.initState();
    _fetchData();
    context.read<AreaBloc>().add(FetchAreasEvent(page: 1, limit: 100));
    // Load cached data
    context.read<StatisticsBloc>().add(LoadCachedRoomStatsEvent());
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  void _fetchData() {
    _logger.i('Fetching room status summary for year: $_selectedYear, areaId: $_selectedAreaId');
    context.read<StatisticsBloc>().add(FetchRoomStatusSummary(
      year: _selectedYear,
      areaId: _selectedAreaId,
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề
          const Text(
            'Thống kê trạng thái phòng hằng tháng',
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
                  // Dropdown chọn khu vực
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
                            _summaryData = []; // Clear cache
                          });
                          _fetchData();
                        },
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  // Dropdown chọn năm
                  DropdownButton<int>(
                    value: _selectedYear,
                    items: List.generate(10, (index) => DateTime.now().year - 5 + index)
                        .map((year) => DropdownMenuItem(value: year, child: Text(year.toString())))
                        .toList(),
                    onChanged: (year) {
                      if (year != null) {
                        setState(() {
                          _selectedYear = year;
                          _summaryData = [];
                        });
                        _fetchData();
                      }
                    },
                  ),
                ],
              ),
              // Nút snapshot chỉ là icon camera
              IconButton(
                onPressed: _triggerSnapshot,
                icon: const Icon(Icons.camera_alt, color: Colors.orange),
                tooltip: 'Chụp snapshot',
              ),
            ],
          ),
          const SizedBox(height: 16),
          // ...phần Expanded BlocBuilder chart giữ nguyên...
          Expanded(
            child: BlocBuilder<StatisticsBloc, StatisticsState>(
              buildWhen: (previous, current) =>
                  current is StatisticsLoading ||
                  (current is PartialLoading && current.requestType == 'room_status_summary') ||
                  current is StatisticsError ||
                  current is RoomStatusSummaryLoaded ||
                  current is ManualSnapshotTriggered,
              builder: (context, state) {
                _logger.i('StatisticsBloc state: $state');

                if (state is RoomStatusSummaryLoaded) {
                  _summaryData = state.summaryData;
                }

                if (state is StatisticsLoading ||
                    (state is PartialLoading && state.requestType == 'room_status_summary') ||
                    state is StatisticsInitial) {
                  if (_summaryData.isNotEmpty) {
                    _logger.i('Displaying cached data while loading');
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
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
                  final statuses = _getStatuses(_summaryData);
                  final colors = _generateColors(statuses.length);
                  final maxY = _getMaxY(_summaryData, statuses);
                  final roundedMaxY = maxY == 0 ? 10.0 : _roundMaxYToEven(maxY);

                  _logger.i('Summary data: $_summaryData');
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
                                      final status = _translateStatus(statuses[rodIndex]);
                                      final month = groupIndex + 1;
                                      final value = _getStatusCount(_summaryData, month, statuses[rodIndex]);
                                      return BarTooltipItem(
                                        '$status\nTháng $month: $value phòng',
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
                                barGroups: List.generate(12, (month) => _buildBarGroup(month, _summaryData, statuses, colors)),
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
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getStatuses(List<Map<String, dynamic>> data) {
    final statuses = <String>{};
    for (var monthData in data) {
      final statusesMap = monthData['statuses'] as Map<String, dynamic>;
      statuses.addAll(statusesMap.keys);
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

  BarChartGroupData _buildBarGroup(int month, List<Map<String, dynamic>> data, List<String> statuses, List<Color> colors) {
    final monthKey = month + 1;
    final monthData = data.firstWhere((d) => d['month'] == monthKey, orElse: () => {'month': monthKey, 'statuses': {}});
    final statusesMap = monthData['statuses'] as Map<String, dynamic>;
    return BarChartGroupData(
      x: month,
      barRods: List.generate(statuses.length, (index) {
        final status = statuses[index];
        final value = (statusesMap[status] as num?)?.toDouble() ?? 0;
        _logger.d('Building bar for month $monthKey, status $status: value = $value');
        return BarChartRodData(
          toY: value,
          color: colors[index],
          width: 12 / statuses.length,
          borderRadius: BorderRadius.circular(4),
        );
      }),
    );
  }

  double _getMaxY(List<Map<String, dynamic>> data, List<String> statuses) {
    double maxY = 0;
    for (var monthData in data) {
      final statusesMap = monthData['statuses'] as Map<String, dynamic>;
      for (var status in statuses) {
        final value = (statusesMap[status] as num?)?.toDouble() ?? 0;
        if (value > maxY) maxY = value;
      }
    }
    _logger.d('Max Y value: $maxY');
    return maxY * 1.1; // Add 10% padding
  }

  double _roundMaxYToEven(double maxY) {
    return ((maxY / 5).ceil() * 5).toDouble();
  }

  double _calculateYInterval(double maxY, double chartHeight) {
    if (maxY == 0 || chartHeight <= 0) return 5.0; // Default interval
    const pixelsPerLabel = 40.0;
    final valuePerPixel = maxY / chartHeight;
    final minIntervalPixels = pixelsPerLabel / valuePerPixel;
    final interval = (minIntervalPixels / 5).ceil() * 5.0;
    return interval.clamp(5.0, maxY / 2);
  }

  double _getStatusCount(List<Map<String, dynamic>> data, int month, String status) {
    final monthData = data.firstWhere((d) => d['month'] == month, orElse: () => {'month': month, 'statuses': {}});
    final statusesMap = monthData['statuses'] as Map<String, dynamic>;
    return (statusesMap[status] as num?)?.toDouble() ?? 0;
  }

  String _translateStatus(String status) {
    switch (status.toUpperCase()) {
      case 'AVAILABLE':
        return 'Còn chỗ trống';
      case 'OCCUPIED':
        return 'Hết chỗ';
      case 'MAINTENANCE':
        return 'Bảo trì';
      case 'DISABLED':
        return 'Không sử dụng được';
      default:
        return status;
    }
  }
}