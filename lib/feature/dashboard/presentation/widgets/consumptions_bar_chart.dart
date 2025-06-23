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
import 'package:intl/intl.dart';

class DashboardBarChart extends StatefulWidget {
  const DashboardBarChart({Key? key}) : super(key: key);

  @override
  _DashboardBarChartState createState() => _DashboardBarChartState();
}

class _DashboardBarChartState extends State<DashboardBarChart> {
  int _selectedYear = DateTime.now().year;
  int? _selectedAreaId;
  List<Consumption> _consumptionData = [];
  // --- UI Constants ---
  static const Map<String, String> _serviceNames = {
    'Điện': 'Điện',
    'Nước': 'Nước',
    'điện': 'Điện',
    'nước': 'Nước',
    'gas': 'Gas',
    'internet': 'Internet',
    // Thêm các khóa tiếng Anh để tương thích với API có thể trả về khác
    'electricity': 'Điện',
    'water': 'Nước',
  };

  static const Map<String, IconData> _serviceIcons = {
    'Điện': Icons.flash_on_outlined,
    'Nước': Icons.water_drop_outlined,
    'điện': Icons.flash_on_outlined,
    'nước': Icons.water_drop_outlined,
    'gas': Icons.local_fire_department_outlined,
    'internet': Icons.wifi_outlined,
    // Thêm các khóa tiếng Anh để tương thích
    'electricity': Icons.flash_on_outlined,
    'water': Icons.water_drop_outlined,
  };

  static const Map<String, Color> _serviceColors = {
    'Điện': Color(0xFFF59E0B), // Amber
    'Nước': Color(0xFF3B82F6), // Blue
    'điện': Color(0xFFF59E0B), // Amber
    'nước': Color(0xFF3B82F6), // Blue
    'gas': Color(0xFFEF4444), // Red
    'internet': Color(0xFF10B981), // Green
    // Thêm các khóa tiếng Anh để tương thích
    'electricity': Color(0xFFF59E0B), // Amber
    'water': Color(0xFF3B82F6), // Blue
  };

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState.auth != null) {
      context.read<AreaBloc>().add(FetchAreasEvent(page: 1, limit: 100));
      _fetchData();
    }
  }

  void _fetchData() {
    final authState = context.read<AuthBloc>().state;
    if (authState.auth != null) {
      context.read<StatisticsBloc>().add(FetchMonthlyConsumption(
        year: _selectedYear,
        month: null,
        areaId: _selectedAreaId,
        forceRefresh: true, // Always force backend fetch
      ));
    }
  }  String _getServiceName(String key) {
    // Thử tìm khớp trực tiếp
    if (_serviceNames.containsKey(key)) {
      return _serviceNames[key]!;
    }
    // Thử tìm khớp không phân biệt hoa thường
    final lowerKey = key.toLowerCase();
    return _serviceNames.entries
        .firstWhere(
          (entry) => entry.key.toLowerCase() == lowerKey,
          orElse: () => MapEntry(key, key),
        )
        .value;
  }
  
  IconData _getServiceIcon(String key) {
    // Thử tìm khớp trực tiếp
    if (_serviceIcons.containsKey(key)) {
      return _serviceIcons[key]!;
    }
    // Thử tìm khớp không phân biệt hoa thường
    final lowerKey = key.toLowerCase();
    return _serviceIcons.entries
        .firstWhere(
          (entry) => entry.key.toLowerCase() == lowerKey,
          orElse: () => const MapEntry("", Icons.help_outline),
        )
        .value;
  }
  
  Color _getServiceColor(String key) {
    // Thử tìm khớp trực tiếp
    if (_serviceColors.containsKey(key)) {
      return _serviceColors[key]!;
    }
    // Thử tìm khớp không phân biệt hoa thường
    final lowerKey = key.toLowerCase();
    return _serviceColors.entries
        .firstWhere(
          (entry) => entry.key.toLowerCase() == lowerKey,
          orElse: () => const MapEntry("", Colors.grey),
        )
        .value;
  }

  @override
  Widget build(BuildContext context) {    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFFF9FAFB), // Softer background color
      child: BlocConsumer<StatisticsBloc, StatisticsState>(
        listener: (context, state) {
          if (state is ConsumptionLoaded) {
            setState(() {
              // Đảm bảo chỉ cập nhật _consumptionData khi có dữ liệu hợp lệ
              if (state.consumptionData.isNotEmpty) {
                _consumptionData = state.consumptionData;
              } else {
                // Nếu không có dữ liệu, hiển thị trạng thái không có dữ liệu
                _consumptionData = [];
                print("DashboardBarChart: Received empty consumption data");
              }
            });
          }
        },
        builder: (context, state) {          Widget content;
          if (state is StatisticsLoading && _consumptionData.isEmpty) {
            content = _buildLoadingState();
          } else if (state is StatisticsError) {
            content = _buildErrorState(state.message);
          } else if (_consumptionData.isNotEmpty) {
            try {
              final consumption = _getConsumption(_consumptionData);
              final services = _getServices(consumption);
              if (services.isEmpty) {
                content = _buildNoDataState();
              } else {
                content = _buildLoadedState(consumption, services);
              }
            } catch (e) {
              content = _buildErrorState("Lỗi xử lý dữ liệu: ${e.toString()}");
            }
          } else {
            content = _buildNoDataState();
          }

          return Column(
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: content,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
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
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.flash_on_outlined, color: Colors.amber, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Thống kê năng lượng',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.grey),
                tooltip: 'Làm mới dữ liệu',
                onPressed: _fetchData,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildAreaDropdown()),
              const SizedBox(width: 16),
              Expanded(child: _buildYearDropdown()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAreaDropdown() {
    return BlocBuilder<AreaBloc, AreaState>(
      builder: (context, areaState) {
        if (areaState.isLoading && areaState.areas.isEmpty) {
          return const SizedBox(height: 48, child: Center(child: CircularProgressIndicator()));
        }

        List<DropdownMenuItem<int?>> items = [
          const DropdownMenuItem(value: null, child: Text('Tất cả khu vực')),
          ...areaState.areas.map((area) => DropdownMenuItem(
                value: area.areaId,
                child: Text(area.name, overflow: TextOverflow.ellipsis),
              )),
        ];

        return DropdownButtonFormField<int?>(
          value: _selectedAreaId,
          items: items,
          onChanged: (value) {
            setState(() {
              _selectedAreaId = value;
              _consumptionData = [];
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
    );
  }

  Widget _buildYearDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedYear,
      items: List.generate(6, (index) => DateTime.now().year - 5 + index)
          .reversed
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
          _fetchData();
        }
      },
      decoration: InputDecoration(
        labelText: 'Năm',
        prefixIcon: const Icon(Icons.calendar_today_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 48,
            width: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Colors.blue.shade600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Đang tải dữ liệu...",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
        ],
      ),
    );
  }
  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            "Lỗi: $message",
            style: TextStyle(color: Colors.grey.shade800, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _fetchData,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text("Thử lại"),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildNoDataState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.bar_chart, size: 32, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 16),
          Text(
            'Không có dữ liệu cho lựa chọn này.',
            style: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Chọn năm hoặc khu vực khác để xem dữ liệu",
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _fetchData,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text("Làm mới"),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(Consumption consumption, List<String> services) {
    final totals = _calculateTotals(consumption);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummaryCards(totals, consumption.serviceUnits),
        const SizedBox(height: 24),
        _buildChartSection(consumption, services),
        const SizedBox(height: 24),
        _buildInsightsSection(consumption, totals),
      ],
    );
  }

  Widget _buildSummaryCards(Map<String, double> totals, Map<String, String> units) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 250,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.8,
      ),
      itemCount: totals.length,
      itemBuilder: (context, index) {
        final service = totals.keys.elementAt(index);
        final value = totals[service]!;
        final unit = units[service] ?? '';
        return _StatCard(
          service: service,
          value: value,
          unit: unit,
        );
      },
    );
  }

  Widget _buildChartSection(Consumption consumption, List<String> services) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Biểu đồ tiêu thụ theo tháng',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'Năm $_selectedYear',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 300,
            child: LineChart(
              _buildLineChartData(consumption, services),
              duration: const Duration(milliseconds: 250),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildInsightsSection(Consumption consumption, Map<String, double> totals) {
    if (totals.isEmpty) {
      return const SizedBox.shrink(); // Không hiển thị nếu không có dữ liệu
    }
    
    final areaName = consumption.areaName;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.insights_outlined, color: Colors.blue),
              SizedBox(width: 8),
              Text('Thông tin chi tiết', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text('Khu vực: $areaName', style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          Text('Tổng tiêu thụ năm $_selectedYear:', style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          ...totals.entries.map((entry) {
            try {
              final service = entry.key;
              final value = entry.value;
              final unit = consumption.serviceUnits[service] ?? '';
              final formattedValue = NumberFormat("#,##0.00", "en_US").format(value);
              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  children: [
                    Icon(_getServiceIcon(service), color: _getServiceColor(service), size: 16),
                    const SizedBox(width: 8),
                    Text('${_getServiceName(service)}:'),
                    const Spacer(),
                    Text('$formattedValue $unit', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            } catch (e) {
              print("Lỗi khi hiển thị thông tin chi tiết: $e");
              return const SizedBox.shrink();
            }
          }),
        ],
      ),
    );
  }
  LineChartData _buildLineChartData(Consumption consumption, List<String> services) {
    if (services.isEmpty) {
      // Trả về biểu đồ trống nếu không có dịch vụ
      return LineChartData(
        lineBarsData: [],
        minY: 0,
        maxY: 10,
        titlesData: const FlTitlesData(show: false),
      );
    }

    final lineBarsData = services.map((service) {
      try {
        final color = _getServiceColor(service);
        final spots = List.generate(12, (monthIndex) {
          final month = monthIndex + 1;
          double value = 0.0;
          try {
            // Kiểm tra tháng và dịch vụ tồn tại trước khi truy cập
            if (consumption.months.containsKey(month) && 
                consumption.months[month]!.containsKey(service)) {
              value = consumption.months[month]![service] ?? 0.0;
            }
          } catch (e) {
            print("Lỗi khi lấy dữ liệu tháng $month, dịch vụ $service: $e");
          }
          return FlSpot(month.toDouble(), value);
        });

        return LineChartBarData(
          spots: spots,
          isCurved: true,
          color: color,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: color.withOpacity(0.1),
          ),
        );
      } catch (e) {
        print("Lỗi khi tạo LineChartBarData cho dịch vụ $service: $e");
        // Trả về dữ liệu trống nếu có lỗi
        return LineChartBarData(
          spots: List.generate(12, (i) => FlSpot(i + 1.0, 0)),
          isCurved: true,
          color: Colors.grey,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
        );
      }
    }).toList();

    return LineChartData(
      lineBarsData: lineBarsData,
      minY: 0,
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) => Text('T${value.toInt()}', style: const TextStyle(fontSize: 12)),
            interval: 1,
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) => FlLine(
          color: Colors.grey.withOpacity(0.2),
          strokeWidth: 1,
        ),
      ),
      borderData: FlBorderData(show: false),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {              try {
                final service = services[spot.barIndex];
                final serviceName = _getServiceName(service);
                final serviceColor = _getServiceColor(service);
                final serviceUnit = consumption.serviceUnits[service] ?? '';
                
                return LineTooltipItem(
                  '$serviceName\n${spot.y.toStringAsFixed(2)} $serviceUnit',
                  TextStyle(color: serviceColor, fontWeight: FontWeight.bold),
                );
              } catch (e) {
                return LineTooltipItem(
                  'Lỗi hiển thị dữ liệu',
                  const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                );
              }
            }).toList();
          },
        ),
      ),
    );
  }
  Consumption _getConsumption(List<Consumption> consumptionData) {
    if (consumptionData.isEmpty) {
      throw Exception("Danh sách dữ liệu tiêu thụ trống");
    }
    
    if (_selectedAreaId != null) {
      try {
        return consumptionData.firstWhere(
          (c) => c.areaId == _selectedAreaId,
          orElse: () => consumptionData.first,
        );
      } catch (e) {
        // Nếu không tìm thấy khu vực hoặc danh sách rỗng, trả về phần tử đầu tiên
        if (consumptionData.isNotEmpty) {
          return consumptionData.first;
        } else {
          throw Exception("Không tìm thấy dữ liệu cho khu vực đã chọn");
        }
      }
    } else {
      try {
        return consumptionData.firstWhere(
          (c) => c.areaId == 0,
          orElse: () => consumptionData.first,
        );
      } catch (e) {
        // Nếu không tìm thấy tổng hợp hoặc danh sách rỗng, trả về phần tử đầu tiên
        if (consumptionData.isNotEmpty) {
          return consumptionData.first;
        } else {
          throw Exception("Không tìm thấy dữ liệu tổng hợp");
        }
      }
    }
  }  List<String> _getServices(Consumption consumption) {
    final services = <String>{};
    if (consumption.months.isEmpty) {
      return [];
    }
    
    consumption.months.forEach((month, serviceMap) {
      services.addAll(serviceMap.keys);
    });
    
    if (services.isEmpty) {
      return [];
    }
    
    // Gán một mức ưu tiên cố định cho các dịch vụ phổ biến
    final servicePriority = {
      'điện': 1,
      'Điện': 1,
      'electricity': 1,
      'nước': 2,
      'Nước': 2,
      'water': 2,
      'gas': 3,
      'internet': 4,
    };
    
    final sortedServices = services.toList();
    try {
      sortedServices.sort((a, b) {
        // Lấy mức ưu tiên của dịch vụ a và b
        final priorityA = servicePriority[a] ?? 999; // Nếu không có trong danh sách, đặt ưu tiên thấp
        final priorityB = servicePriority[b] ?? 999;
        
        // Lấy tên hiển thị để sắp xếp thứ tự thứ hai
        final nameA = _getServiceName(a);
        final nameB = _getServiceName(b);
        
        // Ưu tiên sắp xếp theo mức ưu tiên, sau đó đến tên
        if (priorityA != priorityB) {
          return priorityA - priorityB;
        } else {
          return nameA.compareTo(nameB);
        }
      });
    } catch (e) {
      print("Lỗi khi sắp xếp dịch vụ: $e");
    }
    
    return sortedServices;
  }
  Map<String, double> _calculateTotals(Consumption consumption) {
    final totals = <String, double>{};
    final services = _getServices(consumption);
    
    if (services.isEmpty || consumption.months.isEmpty) {
      return {};
    }
    
    for (var service in services) {
      double sum = 0;
      try {
        consumption.months.forEach((month, serviceMap) {
          final value = serviceMap[service];
          if (value != null) {
            sum += value;
          }
        });
        totals[service] = sum;
      } catch (e) {
        print("Lỗi khi tính tổng cho dịch vụ $service: $e");
        totals[service] = 0;
      }
    }
    return totals;
  }
}

class _StatCard extends StatelessWidget {
  final String service;
  final double value;
  final String unit;

  const _StatCard({
    required this.service,
    required this.value,
    required this.unit,
  });
  String get _serviceName {
    // Thử tìm khớp trực tiếp
    if (_DashboardBarChartState._serviceNames.containsKey(service)) {
      return _DashboardBarChartState._serviceNames[service]!;
    }
    // Thử tìm khớp không phân biệt hoa thường
    final lowerKey = service.toLowerCase();
    return _DashboardBarChartState._serviceNames.entries
        .firstWhere(
          (entry) => entry.key.toLowerCase() == lowerKey,
          orElse: () => MapEntry(service, service),
        )
        .value;
  }
  
  IconData get _serviceIcon {
    // Thử tìm khớp trực tiếp
    if (_DashboardBarChartState._serviceIcons.containsKey(service)) {
      return _DashboardBarChartState._serviceIcons[service]!;
    }
    // Thử tìm khớp không phân biệt hoa thường
    final lowerKey = service.toLowerCase();
    return _DashboardBarChartState._serviceIcons.entries
        .firstWhere(
          (entry) => entry.key.toLowerCase() == lowerKey,
          orElse: () => const MapEntry("", Icons.help_outline),
        )
        .value;
  }
  
  Color get _serviceColor {
    // Thử tìm khớp trực tiếp
    if (_DashboardBarChartState._serviceColors.containsKey(service)) {
      return _DashboardBarChartState._serviceColors[service]!;
    }
    // Thử tìm khớp không phân biệt hoa thường
    final lowerKey = service.toLowerCase();
    return _DashboardBarChartState._serviceColors.entries
        .firstWhere(
          (entry) => entry.key.toLowerCase() == lowerKey,
          orElse: () => const MapEntry("", Colors.grey),
        )
        .value;
  }

  @override
  Widget build(BuildContext context) {
    final formattedValue = NumberFormat("#,##0", "en_US").format(value);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _serviceName,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              Icon(_serviceIcon, color: _serviceColor),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formattedValue,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                unit,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}