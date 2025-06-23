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
import 'dart:math' as math;

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

  void _fetchData({bool forceRefresh = false}) {
    _logger.i('Fetching room status summary for year: $_selectedYear, areaId: $_selectedAreaId, forceRefresh: $forceRefresh');
    if (forceRefresh) {
      // Clear cache first
      setState(() {
        _summaryData = [];
      });
    }
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
        key: const ValueKey('room_stats_main_column'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề
          const Text(
            'Biểu đồ đường thống kê trạng thái phòng hằng tháng',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 16),
          // Các button, dropdown, snapshot...
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Dropdown chọn khu vực
                  SizedBox(
                    width: 200,
                    child: BlocBuilder<AreaBloc, AreaState>(
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
                        return DropdownButtonFormField<int?>(
                          value: _selectedAreaId,
                          decoration: const InputDecoration(
                            labelText: 'Khu vực',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: items,
                          onChanged: (value) {
                            setState(() {
                              _selectedAreaId = value;
                              _summaryData = []; // Clear cache
                            });
                            _fetchData(forceRefresh: true);
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Dropdown chọn năm
                  SizedBox(
                    width: 100,
                    child: DropdownButtonFormField<int>(
                      value: _selectedYear,
                      decoration: const InputDecoration(
                        labelText: 'Năm',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: List.generate(10, (index) => DateTime.now().year - 5 + index)
                          .map((year) => DropdownMenuItem(value: year, child: Text(year.toString())))
                          .toList(),
                      onChanged: (year) {
                        if (year != null) {
                          setState(() {
                            _selectedYear = year;
                            _summaryData = [];
                          });
                          _fetchData(forceRefresh: true);
                        }
                      },
                    ),
                  ),
                ],
              ),
              // Buttons: refresh and snapshot
              Row(
                children: [
                  // Refresh button
                  ElevatedButton.icon(
                    onPressed: () => _fetchData(forceRefresh: true),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Làm mới'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Snapshot button
                  IconButton(
                    onPressed: _triggerSnapshot,
                    icon: const Icon(Icons.camera_alt, color: Colors.orange),
                    tooltip: 'Chụp snapshot',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Chart area
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
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => _fetchData(forceRefresh: true),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Thử lại'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue,
                          ),
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

                // Data visualization
                if (_summaryData.isNotEmpty) {
                  final statuses = _getStatuses(_summaryData);
                  
                  // Check if we have valid statuses to display
                  if (statuses.isEmpty) {
                    return Center(child: Text('Không có dữ liệu trạng thái phòng cho năm $_selectedYear'));
                  }
                  
                  final colors = _generateColors(statuses.length);
                  final maxY = _getMaxY(_summaryData, statuses);
                  // Ensure we always have a reasonable maxY even with zero or very small values
                  final roundedMaxY = maxY < 1.0 ? 10.0 : _roundMaxYToEven(maxY);

                  _logger.i('Summary data: $_summaryData');

                  // Chart dimensions - use MediaQuery for responsive sizing and enforce minimum dimensions
                  final screenSize = MediaQuery.of(context).size;
                  final chartHeight = math.max(250.0, screenSize.height * 0.4);
                  final chartWidth = math.max(300.0, screenSize.width - 64); // Account for padding

                  final yInterval = _calculateYInterval(roundedMaxY, chartHeight);

                  _logger.d('Chart dimensions: width=$chartWidth, height=$chartHeight, maxY=$maxY, yInterval=$yInterval');

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      // Get available size from LayoutBuilder for even more precise dimensions
                      final availableHeight = math.max(250.0, constraints.maxHeight * 0.8);
                      final availableWidth = math.max(300.0, constraints.maxWidth * 0.95);
                      
                      return Column(
                        children: [
                          // Fixed-size chart container with definite dimensions
                          Container(
                            height: availableHeight,
                            width: availableWidth,
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: LineChart(
                              LineChartData(
                                minX: 0,  // Tháng 1 (index 0)
                                maxX: 11, // Tháng 12 (index 11)
                                minY: 0,
                                maxY: roundedMaxY,
                                lineTouchData: LineTouchData(
                                  enabled: true,
                                  touchTooltipData: LineTouchTooltipData(
                                    tooltipPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),               
                                    tooltipMargin: 8,
                                    maxContentWidth: 200, // Increased width to prevent wrapping
                                    fitInsideHorizontally: true,
                                    fitInsideVertically: true,
                                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                                      return touchedSpots.map((spot) {
                                        final statusIndex = spot.barIndex;
                                        final status = statusIndex < statuses.length ? _translateStatus(statuses[statusIndex]) : 'Unknown';
                                        final month = (spot.x + 1).toInt();
                                        final value = spot.y.toInt();
                                        return LineTooltipItem(
                                          '$status - Tháng $month: $value phòng',
                                          const TextStyle(
                                            color: Colors.white, 
                                            fontSize: 12, 
                                            fontWeight: FontWeight.bold,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black26,
                                                blurRadius: 2,
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList();
                                    },
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 20,
                                      interval: 1, // Đảm bảo mỗi tháng cách đều nhau
                                      getTitlesWidget: (value, meta) {
                                        // Chỉ hiển thị nhãn cho các tháng từ 0-11 (tương ứng với tháng 1-12)
                                        final month = value.toInt() + 1;
                                        if (month >= 1 && month <= 12) {
                                          return Text('T$month', 
                                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                                            textAlign: TextAlign.center,
                                          );
                                        }
                                        return const SizedBox.shrink();
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
                                lineBarsData: _createLineChartData(_summaryData, statuses, colors),
                              ),
                            ),
                          ),
                          
                          // Legend - always ensure a reasonable size
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            width: availableWidth,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            constraints: const BoxConstraints(
                              minHeight: 60, // Ensure legend has minimum height
                            ),
                            child: statuses.isEmpty 
                              ? const Center(child: Text('Không có dữ liệu')) 
                              : Wrap(
                                  spacing: 16,
                                  runSpacing: 12,
                                  children: List.generate(statuses.length, (index) {
                                    if (index >= colors.length) return const SizedBox.shrink();
                                    final status = _translateStatus(statuses[index]);
                                    return Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 14, 
                                          height: 14, 
                                          decoration: BoxDecoration(
                                            color: colors[index],
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          status, 
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                ),
                          ),
                        ],
                      );
                    }
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
    
    if (data.isEmpty) {
      // Return default statuses if no data is available
      return ['AVAILABLE', 'OCCUPIED', 'MAINTENANCE', 'DISABLED'];
    }
    
    try {
      for (var monthData in data) {
        final statusesMap = monthData['statuses'] as Map<String, dynamic>? ?? {};
        statuses.addAll(statusesMap.keys);
      }
      
      // If we still have no statuses, add defaults
      if (statuses.isEmpty) {
        statuses.addAll(['AVAILABLE', 'OCCUPIED', 'MAINTENANCE', 'DISABLED']);
      }
    } catch (e) {
      _logger.e('Error in _getStatuses: $e');
      // Return default statuses on error
      return ['AVAILABLE', 'OCCUPIED', 'MAINTENANCE', 'DISABLED'];
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

  // Tạo danh sách các điểm dữ liệu cho line chart
  List<LineChartBarData> _createLineChartData(List<Map<String, dynamic>> data, List<String> statuses, List<Color> colors) {
    final result = <LineChartBarData>[];
    
    // Safety check
    if (data.isEmpty || statuses.isEmpty || colors.isEmpty) {
      // Return at least one dummy line to prevent chart rendering errors
      return [
        LineChartBarData(
          spots: List.generate(12, (index) => FlSpot(index.toDouble(), 0)),
          isCurved: true,
          color: Colors.grey.withOpacity(0.5),
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
        )
      ];
    }
    
    // Tạo một đường cho mỗi trạng thái
    for (int statusIndex = 0; statusIndex < statuses.length; statusIndex++) {
      if (statusIndex >= colors.length) continue; // Skip if not enough colors
      
      final status = statuses[statusIndex];
      final spots = <FlSpot>[];
      
      // Tạo danh sách điểm cho tất cả 12 tháng
      for (int month = 1; month <= 12; month++) {
        final value = _getStatusCount(data, month, status);
        // Sử dụng month-1 cho trục x để đảm bảo phù hợp với khoảng 0-11
        spots.add(FlSpot((month - 1).toDouble(), value));
      }
      
      // Tạo dữ liệu đường cho trạng thái này
      result.add(
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.3,
          color: colors[statusIndex],
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {              
              // Chỉ hiển thị điểm cho các tháng có dữ liệu thực
              final hasValue = spot.y > 0;
              return FlDotCirclePainter(
                radius: hasValue ? 5 : 0,  // Tăng kích thước điểm cho dễ nhìn
                color: colors[statusIndex],
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: colors[statusIndex].withOpacity(0.15),
          ),
        )
      );
    }
    
    // If no lines were created (shouldn't happen due to safety check above)
    if (result.isEmpty) {
      result.add(
        LineChartBarData(
          spots: List.generate(12, (index) => FlSpot(index.toDouble(), 0)),
          isCurved: true,
          color: Colors.grey.withOpacity(0.5),
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
        )
      );
    }
    
    return result;
  }

  double _getMaxY(List<Map<String, dynamic>> data, List<String> statuses) {
    double maxY = 0;
    
    // Safety check - if no data or no statuses, return a default value
    if (data.isEmpty || statuses.isEmpty) {
      return 10.0;
    }
    
    try {
      for (var monthData in data) {
        final statusesMap = monthData['statuses'] as Map<String, dynamic>? ?? {};
        for (var status in statuses) {
          final value = (statusesMap[status] as num?)?.toDouble() ?? 0;
          if (value > maxY) maxY = value;
        }
      }
      
      // Ensure we have a minimum value to show something on the chart
      if (maxY <= 0) {
        maxY = 10.0;
      } else {
        maxY *= 1.1; // Add 10% padding
      }
    } catch (e) {
      _logger.e('Error in _getMaxY: $e');
      return 10.0; // Return default on error
    }
    
    _logger.d('Max Y value: $maxY');
    return maxY;
  }

  double _roundMaxYToEven(double maxY) {
    return ((maxY / 5).ceil() * 5).toDouble();
  }

  double _calculateYInterval(double maxY, double chartHeight) {
    // Handle edge cases
    if (maxY <= 0 || chartHeight <= 0 || maxY.isNaN || chartHeight.isNaN) {
      return 5.0; // Default interval
    }
    
    // Ensure reasonable spacing between labels
    const pixelsPerLabel = 40.0;
    final valuePerPixel = maxY / chartHeight;
    
    if (valuePerPixel <= 0 || valuePerPixel.isInfinite || valuePerPixel.isNaN) {
      return 5.0;
    }
    
    final minIntervalPixels = pixelsPerLabel / valuePerPixel;
    
    if (minIntervalPixels.isInfinite || minIntervalPixels.isNaN) {
      return 5.0;
    }
    
    // Round to a nice number
    final interval = (minIntervalPixels / 5).ceil() * 5.0;
    return interval.clamp(5.0, maxY / 2);
  }

  double _getStatusCount(List<Map<String, dynamic>> data, int month, String status) {
    try {
      // Find the data for the specified month
      final monthData = data.firstWhere(
        (d) => d['month'] == month, 
        orElse: () => {'month': month, 'statuses': {}}
      );
      
      // Get the statuses map
      final statusesMap = monthData['statuses'] as Map<String, dynamic>? ?? {};
      
      // Return the count for the specified status
      return (statusesMap[status] as num?)?.toDouble() ?? 0;
    } catch (e) {
      _logger.e('Error in _getStatusCount: $e');
      return 0; // Return 0 on any error
    }
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