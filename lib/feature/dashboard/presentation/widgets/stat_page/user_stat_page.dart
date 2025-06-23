import 'package:datn_web_admin/feature/dashboard/presentation/bloc/statistic_bloc.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/bloc/statistic_event.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/bloc/statistic_state.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/widgets/fill_rate_pie_chart.dart';
import 'package:datn_web_admin/feature/dashboard/domain/entities/user_monthly_stats.dart';
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
  }

  void _fetchData() {
    _logger.i('Fetching user summary and fill rate for year: $_selectedYear, areaId: $_selectedAreaId');
    // Add more detailed logging to debug data fetching
    try {
      context.read<StatisticsBloc>().add(FetchUserSummary(
        year: _selectedYear,
        areaId: _selectedAreaId,
      ));
      
      _logger.i('Dispatching FetchUserMonthlyStats event');
      context.read<StatisticsBloc>().add(FetchUserMonthlyStats(
        year: _selectedYear,
        month: null,  // Add month parameter explicitly as null
        quarter: null, // Add quarter parameter explicitly
        areaId: _selectedAreaId,
        roomId: null, // Add roomId parameter explicitly
      ));
      
      context.read<StatisticsBloc>().add(FetchRoomFillRateStats(
        areaId: _selectedAreaId,
        roomId: null,
      ));
      
      // Thêm log để xác nhận các sự kiện đã được gửi đi
      _logger.d('All fetch events dispatched successfully');
    } catch (e) {
      _logger.e('Error dispatching events: $e');
    }
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
    _logger.d('Building UserStatsPage with year=$_selectedYear, areaId=$_selectedAreaId');
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [          // Tiêu đề
          const Text(
            'Biểu đồ đường thống kê sinh viên đang lưu trú theo tháng',
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
                        items: items,                        onChanged: (value) {
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
                (current is PartialLoading && (current.requestType == 'user_summary' || current.requestType == 'user_monthly_stats')) ||
                (current is StatisticsError && (current.message.contains('user_summary') || current.message.contains('user_monthly_stats'))) ||
                current is UserSummaryLoaded ||
                current is UserMonthlyStatsLoaded ||
                current is ManualSnapshotTriggered,
            builder: (context, state) {
              _logger.i('Bar chart state: $state');              // Handle UserSummaryLoaded state
              if (state is UserSummaryLoaded) {
                _summaryData = state.summaryData;
                _logger.d('Loaded summary data: ${_summaryData.length} entries');
              } 
              // Handle UserMonthlyStatsLoaded state
              else if (state is UserMonthlyStatsLoaded) {
                _summaryData = _transformUserMonthlyStats(state.userMonthlyStatsData);
                _logger.d('Loaded monthly stats data: ${_summaryData.length} entries');
              }

              if (state is StatisticsLoading || (state is PartialLoading && (state.requestType == 'user_summary' || state.requestType == 'user_monthly_stats'))) {
                if (_summaryData.isNotEmpty) {
                  _logger.i('Displaying cached data while loading');
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              } else if (state is StatisticsError && (state.message.contains('user_summary') || state.message.contains('user_monthly_stats'))) {
                _logger.e('User summary/monthly stats error: ${state.message}');
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
              }              // Make sure to log data for debugging
              if (_summaryData.isNotEmpty) {
                _logger.d('Rendering chart with ${_summaryData.length} data points');
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

                        _logger.d('Bar chart dimensions: width=$chartWidth, height=$chartHeight, maxY=$maxY, yInterval=$yInterval');                        // Tạo dữ liệu cho line chart
                        final lineSpots = _createLineChartData(_summaryData);
                          return LineChart(                          LineChartData(
                            minX: 0,  // Tháng 1 (index 0)
                            maxX: 11, // Tháng 12 (index 11)
                            lineTouchData: LineTouchData(
                              enabled: true,                              touchTooltipData: LineTouchTooltipData(
                                getTooltipItems: (List<LineBarSpot> touchedSpots) {
                                  return touchedSpots.map((spot) {
                                    // x đã là 0-11, nên phải +1 để chuyển thành tháng 1-12
                                    final month = (spot.x + 1).toInt();
                                    final value = spot.y.toInt();
                                    return LineTooltipItem(
                                      'Tháng $month: $value người',
                                      const TextStyle(color: Colors.white, fontSize: 12),
                                    );
                                  }).toList();
                                },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              show: true,                              bottomTitles: AxisTitles(
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
                            lineBarsData: [
                              LineChartBarData(                                spots: lineSpots,
                                isCurved: true,
                                curveSmoothness: 0.3,  // Làm mịn đường cong
                                color: Colors.blue,
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter: (spot, percent, barData, index) {
                                    // Chỉ hiển thị điểm cho các tháng có dữ liệu thực
                                    final hasValue = spot.y > 0;
                                    return FlDotCirclePainter(
                                      radius: hasValue ? 4 : 0,  // Ẩn điểm cho giá trị 0
                                      color: Colors.blue,
                                      strokeWidth: 1,
                                      strokeColor: Colors.white,
                                    );
                                  },
                                ),                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue.withOpacity(0.3),
                                      Colors.blue.withOpacity(0.05),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ],
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
            children: [              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.show_chart, color: Colors.blue, size: 16),
                  SizedBox(width: 4),
                  Text('Biểu đồ đường thể hiện số lượng người dùng', style: TextStyle(fontSize: 12)),
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
  // Các phương thức hỗ trợ cho biểu đồ
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
  // Transform UserMonthlyStats to the format expected by the chart
  List<Map<String, dynamic>> _transformUserMonthlyStats(List<UserMonthlyStats> stats) {
    final result = <Map<String, dynamic>>[];
    final monthTotals = <int, int>{};  // Map để tổng hợp dữ liệu theo tháng
    
    // Tính tổng số người dùng cho mỗi tháng từ tất cả các khu vực
    for (var stat in stats) {
      stat.months.forEach((month, count) {
        monthTotals[month] = (monthTotals[month] ?? 0) + count;
      });
    }
    
    // Tạo danh sách kết quả với một bản ghi duy nhất cho mỗi tháng
    monthTotals.forEach((month, count) {
      result.add({
        'month': month,
        'total_users': count,
        'area_id': stats.isNotEmpty ? stats.first.areaId : 0,
        'area_name': stats.isNotEmpty ? stats.first.areaName : '',
      });
    });
    
    _logger.d('Transformed ${stats.length} UserMonthlyStats objects into ${result.length} unique monthly data points');
    return result;
  }  // Tạo danh sách các điểm dữ liệu cho line chart
  List<FlSpot> _createLineChartData(List<Map<String, dynamic>> data) {
    final spots = <FlSpot>[];
    final monthData = <int, double>{};  // Map để đảm bảo mỗi tháng chỉ có một giá trị
    
    // Lấy giá trị cho mỗi tháng từ dữ liệu đầu vào
    for (var entry in data) {
      final month = _safeToInt(entry['month']);
      final count = _safeToDouble(entry['total_users']);
      if (month >= 1 && month <= 12) {
        // Nếu tháng đã tồn tại, chỉ cập nhật nếu giá trị mới lớn hơn
        if (!monthData.containsKey(month) || count > monthData[month]!) {
          monthData[month] = count;
        }
      }
    }
    
    _logger.d('Extracted data for ${monthData.length} unique months');
    
    // Tạo danh sách điểm cho tất cả 12 tháng, đảm bảo sắp xếp theo thứ tự tháng
    for (int month = 1; month <= 12; month++) {
      final userCount = monthData[month] ?? 0.0;
      // Quan trọng: x = month - 1 để phù hợp với chỉ số 0-11 trên trục x
      spots.add(FlSpot((month - 1).toDouble(), userCount));
      _logger.d('Added spot for month $month with value $userCount at x=${month-1}');
    }
    
    return spots;
  }
}