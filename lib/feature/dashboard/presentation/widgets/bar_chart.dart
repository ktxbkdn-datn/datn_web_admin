// lib/src/features/dashboard/presentation/widgets/bar_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../common/constants/colors.dart';
import '../bloc/statistic_bloc.dart';
import '../bloc/statistic_event.dart';
import '../bloc/statistic_state.dart';
import '../../../room/presentations/area_bloc/area_bloc.dart';
import '../../../room/presentations/area_bloc/area_event.dart';
import '../../../room/presentations/area_bloc/area_state.dart';
import '../../domain/entities/consumption.dart';

class DashboardBarChart extends StatefulWidget {
  const DashboardBarChart({Key? key}) : super(key: key);

  @override
  _DashboardBarChartState createState() => _DashboardBarChartState();
}

class _DashboardBarChartState extends State<DashboardBarChart> {
  int _selectedYear = DateTime.now().year;
  int? _selectedAreaId;
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Tải danh sách khu vực
    context.read<AreaBloc>().add( FetchAreasEvent(page: 1, limit: 100));
    // Tải dữ liệu tiêu thụ ban đầu (không có areaId cụ thể)
    context.read<StatisticsBloc>().add(FetchMonthlyConsumption(year: _selectedYear));
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  void _fetchData() {
    context.read<StatisticsBloc>().add(FetchMonthlyConsumption(
      year: _selectedYear,
      areaId: _selectedAreaId,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Flexible(
                  child: Text(
                    'Thống kê năng lượng',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                Row(
                  children: [
                    // Dropdown khu vực
                    BlocBuilder<AreaBloc, AreaState>(
                      builder: (context, areaState) {
                        if (areaState.isLoading) {
                          return const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        } else if (areaState.error != null) {
                          return const Text('Lỗi tải khu vực');
                        }
                        return DropdownButton<int>(
                          value: _selectedAreaId,
                          hint: const Text('Chọn khu vực'),
                          items: areaState.areas
                              .map((area) => DropdownMenuItem(
                                    value: area.areaId,
                                    child: Text(area.name),
                                  ))
                              .toList(),
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
                    // Dropdown năm
                    DropdownButton<int>(
                      value: _selectedYear,
                      items: List.generate(6, (index) => 2020 + index)
                          .map((year) => DropdownMenuItem(
                                value: year,
                                child: Text(year.toString()),
                              ))
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
            BlocBuilder<StatisticsBloc, StatisticsState>(
              builder: (context, state) {
                if (state is StatisticsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is StatisticsError) {
                  return Center(child: Text('Lỗi: ${state.message}'));
                } else if (state is ConsumptionLoaded) {
                  if (state.consumptionData.isEmpty) {
                    return const Center(child: Text('Không có dữ liệu cho khu vực này'));
                  }

                  // Lọc dữ liệu theo khu vực được chọn
                  Consumption? consumption;
                  if (_selectedAreaId != null) {
                    consumption = state.consumptionData.firstWhere(
                      (c) => c.areaId == _selectedAreaId,
                      orElse: () => state.consumptionData.first, // Mặc định lấy khu vực đầu tiên nếu không khớp
                    );
                  } else {
                    consumption = state.consumptionData.first; // Mặc định lấy khu vực đầu tiên
                  }

                  final services = _getServices(consumption);
                  final colors = _generateColors(services.length);
                  final maxY = _getMaxY(consumption, services);

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final chartWidth = constraints.maxWidth > 640 ? 640.0 : constraints.maxWidth;
                      final chartHeight = (maxY * 10).clamp(200.0, 400.0);

                      return SizedBox(
                        height: 200,
                        child: Scrollbar(
                          controller: _verticalScrollController,
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            controller: _verticalScrollController,
                            scrollDirection: Axis.vertical,
                            child: Scrollbar(
                              controller: _horizontalScrollController,
                              thumbVisibility: true,
                              child: SingleChildScrollView(
                                controller: _horizontalScrollController,
                                scrollDirection: Axis.horizontal,
                                child: SizedBox(
                                  width: chartWidth,
                                  height: chartHeight,
                                  child: BarChart(
                                    BarChartData(
                                      alignment: BarChartAlignment.spaceAround,
                                      barTouchData: BarTouchData(
                                        enabled: true,
                                        handleBuiltInTouches: false,
                                        touchTooltipData: BarTouchTooltipData(
                                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                            final service = services[rodIndex];
                                            final month = groupIndex + 1;
                                            final value = consumption!.months[month]?[service] ?? 0.0;
                                            final unit = consumption.serviceUnits[service] ?? '';
                                            return BarTooltipItem(
                                              '$service\n$value $unit',
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
                                              return Text(
                                                'T$month',
                                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                                              );
                                            },
                                          ),
                                        ),
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 30,
                                            getTitlesWidget: (value, meta) {
                                              return Text(
                                                value.toInt().toString(),
                                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                                              );
                                            },
                                          ),
                                        ),
                                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      ),
                                      borderData: FlBorderData(show: false),
                                      gridData: const FlGridData(show: true),
                                      barGroups: List.generate(12, (month) => _buildBarGroup(month, consumption!, services, colors)),
                                      minY: 0,
                                      maxY: maxY,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
                return const Center(child: Text('Không có dữ liệu'));
              },
            ),
            const SizedBox(height: 8),
            BlocBuilder<StatisticsBloc, StatisticsState>(
              builder: (context, state) {
                if (state is ConsumptionLoaded && state.consumptionData.isNotEmpty) {
                  Consumption? consumption;
                  if (_selectedAreaId != null) {
                    consumption = state.consumptionData.firstWhere(
                      (c) => c.areaId == _selectedAreaId,
                      orElse: () => state.consumptionData.first,
                    );
                  } else {
                    consumption = state.consumptionData.first;
                  }

                  final services = _getServices(consumption);
                  final colors = _generateColors(services.length);
                  return Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: List.generate(services.length, (index) {
                      final service = services[index];
                      final unit = consumption!.serviceUnits[service] ?? '';
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            color: colors[index],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$service ($unit)',
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      );
                    }),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getServices(Consumption consumption) {
    final services = <String>{};
    consumption.months.forEach((month, serviceMap) {
      services.addAll(serviceMap.keys);
    });
    return services.toList();
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

  BarChartGroupData _buildBarGroup(int month, Consumption consumption, List<String> services, List<Color> colors) {
    final monthKey = month + 1;
    return BarChartGroupData(
      x: month,
      barRods: List.generate(services.length, (index) {
        final service = services[index];
        final value = consumption.months[monthKey]?[service] ?? 0.0;
        return BarChartRodData(
          toY: value,
          color: colors[index],
          width: 6,
          borderRadius: BorderRadius.circular(4),
        );
      }),
    );
  }

  double _getMaxY(Consumption consumption, List<String> services) {
    double maxY = 0;
    for (var month in consumption.months.keys) {
      for (var service in services) {
        final value = consumption.months[month]?[service] ?? 0.0;
        if (value > maxY) maxY = value;
      }
    }
    return maxY * 1.1;
  }
}