import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:datn_web_admin/feature/dashboard/domain/entities/consumption.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/bloc/statistic_bloc.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/bloc/statistic_event.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/bloc/statistic_state.dart';
import 'package:datn_web_admin/feature/room/presentations/bloc/area_bloc/area_bloc.dart';
import 'package:datn_web_admin/feature/room/presentations/bloc/area_bloc/area_event.dart';
import 'package:datn_web_admin/feature/room/presentations/bloc/area_bloc/area_state.dart';
import 'package:datn_web_admin/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:datn_web_admin/feature/auth/presentation/bloc/auth_state.dart';

class DashboardBarChart extends StatefulWidget {
  final double chartWidth;
  final double chartHeight;

  const DashboardBarChart({
    Key? key,
    required this.chartWidth,
    required this.chartHeight,
  }) : super(key: key);

  @override
  _DashboardBarChartState createState() => _DashboardBarChartState();
}

class _DashboardBarChartState extends State<DashboardBarChart> {
  int _selectedYear = DateTime.now().year;
  int? _selectedAreaId; // Mặc định null để lấy tổng hợp
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  List<Consumption> _consumptionData = []; // Cache data

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState.auth != null) {
      context.read<AreaBloc>().add(FetchAreasEvent(page: 1, limit: 100));
      context.read<StatisticsBloc>().add(LoadCachedConsumption(
        year: _selectedYear,
        areaId: null,
      ));
      _fetchData();
    } else {
      print('DashboardBarChart: No auth token, skipping fetch');
    }
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  void _fetchData() {
    final authState = context.read<AuthBloc>().state;
    if (authState.auth != null) {
      print('DashboardBarChart: Fetching consumption data for year $_selectedYear, areaId $_selectedAreaId');
      context.read<StatisticsBloc>().add(FetchMonthlyConsumption(
        year: _selectedYear,
        month: null,
        areaId: _selectedAreaId,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    print('DashboardBarChart: Building widget');
    return MultiBlocListener(
      listeners: [
        BlocListener<AreaBloc, AreaState>(
          listener: (context, state) {
            if (!state.isLoading && state.error == null && state.areas.isNotEmpty) {
              // Không tự động chọn areaId, giữ _selectedAreaId là null
              context.read<StatisticsBloc>().add(LoadCachedConsumption(
                year: _selectedYear,
                areaId: _selectedAreaId,
              ));
            }
          },
        ),
        BlocListener<StatisticsBloc, StatisticsState>(
          listener: (context, state) {
            if (state is ConsumptionLoaded && state.consumptionData.isEmpty) {
              _fetchData();
            } else if (state is StatisticsInitial) {
              _fetchData();
            }
          },
        ),
      ],
      child: Container(
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
          child: SingleChildScrollView(
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
                            List<DropdownMenuItem<int?>> items = [
                              const DropdownMenuItem(value: null, child: Text('Tất cả')),
                              ...areaState.areas.map((area) => DropdownMenuItem(
                                    value: area.areaId,
                                    child: Text(area.name),
                                  )),
                            ];
                            return DropdownButton<int?>(
                              value: _selectedAreaId,
                              items: items,
                              onChanged: (value) {
                                setState(() {
                                  _selectedAreaId = value;
                                  _consumptionData = [];
                                });
                                context.read<StatisticsBloc>().add(LoadCachedConsumption(
                                  year: _selectedYear,
                                  areaId: value,
                                ));
                                _fetchData();
                              },
                            );
                          },
                        ),
                        const SizedBox(width: 8),
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
                                _consumptionData = [];
                              });
                              context.read<StatisticsBloc>().add(LoadCachedConsumption(
                                year: year,
                                areaId: _selectedAreaId,
                              ));
                              _fetchData();
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.green),
                          tooltip: 'Làm mới dữ liệu',
                          onPressed: () => _fetchData(),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                BlocBuilder<StatisticsBloc, StatisticsState>(
                  builder: (context, state) {
                    if (state is ConsumptionLoaded && state.consumptionData.isNotEmpty) {
                      Consumption consumption = _getConsumption(state.consumptionData);
                      return Text(
                        'Khu vực: ${consumption.areaName}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 16),
                BlocBuilder<StatisticsBloc, StatisticsState>(
                  builder: (context, state) {
                    if (state is ConsumptionLoaded) {
                      _consumptionData = state.consumptionData;
                    }

                    if (state is StatisticsLoading || state is StatisticsInitial) {
                      if (_consumptionData.isNotEmpty) {
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
                    }

                    if (_consumptionData.isNotEmpty) {
                      Consumption consumption = _getConsumption(_consumptionData);
                      final services = _getServices(consumption);
                      if (services.isEmpty) {
                        return const Center(child: Text('Không có dịch vụ nào để hiển thị'));
                      }

                      final colors = _generateColors(services.length);
                      final maxY = _getMaxY(consumption, services);

                      return AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: SizedBox(
                          width: widget.chartWidth,
                          height: widget.chartHeight - 80, // Adjust for title and legend
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
                                    width: widget.chartWidth,
                                    height: widget.chartHeight - 80,
                                    child: BarChart(
                                      BarChartData(
                                        alignment: BarChartAlignment.spaceAround,
                                        barTouchData: BarTouchData(
                                          enabled: true,
                                          handleBuiltInTouches: true,
                                          touchTooltipData: BarTouchTooltipData(
                                            tooltipPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            tooltipMargin: 20,
                                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                              final service = services[rodIndex];
                                              final month = groupIndex + 1;
                                              final value = consumption.months[month]?[service] ?? 0.0;
                                              final unit = consumption.serviceUnits[service] ?? '';
                                              return BarTooltipItem(
                                                'Tháng $month\n$service: $value $unit',
                                                const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                                textAlign: TextAlign.center,
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
                                        barGroups: List.generate(12, (month) => _buildBarGroup(month, consumption, services, colors)),
                                        minY: 0,
                                        maxY: maxY * 1.2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
                const SizedBox(height: 8),
                BlocBuilder<StatisticsBloc, StatisticsState>(
                  builder: (context, state) {
                    if (state is ConsumptionLoaded && state.consumptionData.isNotEmpty) {
                      Consumption consumption = _getConsumption(state.consumptionData);
                      final services = _getServices(consumption);
                      final colors = _generateColors(services.length);
                      return Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: List.generate(services.length, (index) {
                          final service = services[index];
                          final unit = consumption.serviceUnits[service] ?? '';
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
        ),
      ),
    );
  }

  Consumption _getConsumption(List<Consumption> consumptionData) {
    if (_selectedAreaId != null) {
      return consumptionData.firstWhere(
        (c) => c.areaId == _selectedAreaId,
        orElse: () => consumptionData.first,
      );
    } else {
      return consumptionData.firstWhere(
        (c) => c.areaId == 0,
        orElse: () => consumptionData.first,
      );
    }
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