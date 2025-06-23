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
import 'package:intl/date_symbol_data_local.dart';
import 'package:logger/logger.dart';

class ReportStatsPage extends StatefulWidget {
  const ReportStatsPage({Key? key}) : super(key: key);

  @override
  _ReportStatsPageState createState() => _ReportStatsPageState();
}

class _ReportStatsPageState extends State<ReportStatsPage> {
  final ValueNotifier<DateTime> _selectedMonth = ValueNotifier(DateTime.now());
  int? _selectedAreaId;
  List<ReportStats> _reportStatsData = []; // Cache data
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('vi', null);
    _fetchData();
    context.read<AreaBloc>().add(FetchAreasEvent(page: 1, limit: 100));
    context.read<StatisticsBloc>().add(LoadCachedReportStatsEvent());
  }
  
  @override
  void dispose() {
    _selectedMonth.dispose();
    super.dispose();
  }
    void _fetchData({bool forceRefresh = false}) {
    try {
      final date = _selectedMonth.value;
      _logger.i('ReportStatsPage: Fetching reports for year ${date.year}');
      context.read<StatisticsBloc>().add(FetchReportStats(
        year: date.year,
        areaId: _selectedAreaId,
        forceRefresh: forceRefresh,
      ));
    } catch (e) {
      _logger.e('Error in _fetchData: $e');
      // Use current date as fallback
      final now = DateTime.now();
      context.read<StatisticsBloc>().add(FetchReportStats(
        year: now.year,
        areaId: _selectedAreaId,
        forceRefresh: forceRefresh,
      ));
    }
  }@override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildYearSelector(),
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
                  }                } else if (state is StatisticsError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Lỗi: ${state.message}'),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(                          onPressed: () {
                            setState(() {
                              _reportStatsData = [];
                            });
                            _fetchData(forceRefresh: true);
                          },
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
                    );                  });
                  _fetchData(forceRefresh: true);
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
                        children: [                          SizedBox(
                            width: chartWidth,
                            height: chartHeight,
                            child: LineChart(
                              LineChartData(
                                minX: 0,  // Tháng 1 (index 0)
                                maxX: 11, // Tháng 12 (index 11)
                                lineTouchData: LineTouchData(
                                  enabled: true,
                                  touchTooltipData: LineTouchTooltipData(                                    tooltipPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    tooltipMargin: 8,
                                    maxContentWidth: 300, // Increased width further to prevent wrapping
                                    fitInsideHorizontally: true,
                                    fitInsideVertically: true,
                                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                                      return touchedSpots.map((spot) {
                                        final reportTypeIndex = spot.barIndex;
                                        final reportType = reportTypes[reportTypeIndex];
                                        final month = (spot.x + 1).toInt();
                                        final value = spot.y.toInt();
                                        return LineTooltipItem(
                                          '$reportType - Tháng $month: $value báo cáo', // Single line format
                                          TextStyle(
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
                                      interval: 1, // Ensure each month is evenly spaced
                                      getTitlesWidget: (value, meta) {
                                        // Only show labels for months 1-12
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
                                  ),                                  leftTitles: AxisTitles(
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
                                lineBarsData: _createLineChartData(filteredData, reportTypes, colors),
                                minY: 0,
                                maxY: roundedMaxY,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Improved legend styling
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Wrap(
                              spacing: 16,
                              runSpacing: 8,
                              children: List.generate(reportTypes.length, (index) {
                                final reportType = reportTypes[index];
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 12, 
                                      height: 12, 
                                      decoration: BoxDecoration(
                                        color: colors[index],
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      reportType, 
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
  }  // --- Header with title and refresh button ---  
  Widget _buildHeader() {
    // Safely get the current selected date, defaulting to now if null or disposed
    DateTime selectedDate;
    try {
      // ValueNotifier<T> value can't be null, but we can safely handle any exceptions
      selectedDate = _selectedMonth.value;
    } catch (e) {
      // Handle the case where ValueNotifier might be disposed or invalid
      _logger.e('Error accessing _selectedMonth: $e');
      selectedDate = DateTime.now();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.timeline, color: Colors.blue.shade700, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Biểu đồ báo cáo theo thời gian",
                    style: TextStyle(
                      color: Color(0xFF1F2937),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.refresh, color: Colors.blue.shade700),
                tooltip: 'Làm mới dữ liệu',
                onPressed: () {
                  _logger.i('ReportStatsPage: Refreshing reports');
                  setState(() {
                    _reportStatsData = [];
                  });
                  _fetchData(forceRefresh: true);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),          Text(
            "Năm ${selectedDate.year}",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
  // --- Area and year selector with modern styling ---
  Widget _buildYearSelector() {
    return ValueListenableBuilder<DateTime>(
      valueListenable: _selectedMonth,
      builder: (context, selectedDate, _) {
        final currentYear = DateTime.now().year;
        final years = List.generate(6, (index) => currentYear - 3 + index);
        return Row(
          children: [
            // Area selector
            Expanded(
              child: BlocBuilder<AreaBloc, AreaState>(
                builder: (context, areaState) {
                  if (areaState.isLoading) {
                    return const SizedBox(height: 48, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
                  } else if (areaState.error != null) {
                    return const Text('Lỗi tải khu vực');
                  }
                  List<DropdownMenuItem<int?>> items = [
                    const DropdownMenuItem(value: null, child: Text('Tất cả khu vực')),
                    ...areaState.areas.map((area) => DropdownMenuItem(value: area.areaId, child: Text(area.name))),
                  ];
                  return DropdownButtonFormField<int?>(
                    value: _selectedAreaId,
                    items: items,
                    onChanged: (value) {
                      setState(() {
                        _selectedAreaId = value;
                        _reportStatsData = [];
                      });
                      _fetchData();
                    },
                    decoration: InputDecoration(
                      labelText: 'Khu vực',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            // Year selector
            Expanded(
              child: DropdownButtonFormField<int>(
                value: selectedDate.year,
                items: years.map((year) => DropdownMenuItem<int>(
                  value: year,
                  child: Text(year.toString()),
                )).toList(),
                onChanged: (year) {
                  if (year != null) {
                    final newDate = DateTime(year, 1); // Luôn đặt tháng là tháng 1 khi chỉ chọn năm
                    _selectedMonth.value = newDate;
                    setState(() {
                      _reportStatsData = [];
                    });
                    _fetchData();
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Năm',
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
          ],
        );
      },
    );  }

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

  // Create line chart data for each report type
  List<LineChartBarData> _createLineChartData(List<ReportStats> data, List<String> reportTypes, List<Color> colors) {
    final result = <LineChartBarData>[];
    
    // Create a line for each report type
    for (int typeIndex = 0; typeIndex < reportTypes.length; typeIndex++) {
      final reportType = reportTypes[typeIndex];
      final spots = <FlSpot>[];
      
      // Create data points for all 12 months
      for (int month = 1; month <= 12; month++) {
        final value = _getReportCount(data, month, reportType);
        // Use month-1 for x-axis to match 0-11 range
        spots.add(FlSpot((month - 1).toDouble(), value.toDouble()));
      }
      
      // Create line data for this report type
      result.add(
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.3,
          color: colors[typeIndex],
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              // Only show dots for months with data
              final hasValue = spot.y > 0;
              return FlDotCirclePainter(
                radius: hasValue ? 5 : 0,
                color: colors[typeIndex],
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: colors[typeIndex].withOpacity(0.15),
          ),
        )
      );
    }
    
    return result;
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
  }  int _getReportCount(List<ReportStats> data, int month, String reportType) {
    int count = 0;
    for (var area in data) {
      area.years[_selectedMonth.value.year]?.months[month]?.forEach((type, value) {
        if (type == reportType) count += value;
      });
    }
    return count;
  }
}