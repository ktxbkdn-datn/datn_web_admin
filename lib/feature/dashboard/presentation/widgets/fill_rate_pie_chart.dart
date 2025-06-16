import 'package:datn_web_admin/feature/dashboard/presentation/bloc/statistic_bloc.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/bloc/statistic_event.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/bloc/statistic_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:logger/logger.dart';

class FillRatePieChart extends StatelessWidget {
  final int? selectedAreaId;
  final double chartHeight;
  final double chartWidth;

  const FillRatePieChart({
    Key? key,
    this.selectedAreaId,
    required this.chartHeight,
    required this.chartWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logger = Logger();
    return BlocBuilder<StatisticsBloc, StatisticsState>(
      buildWhen: (previous, current) =>
          current is RoomFillRateLoaded ||
          (current is PartialLoading && current.requestType == 'room_fill_rate') ||
          (current is StatisticsError && current.message.contains('room_fill_rate')),
      builder: (context, state) {
        logger.i('Pie chart state: $state');
        double totalCapacity = 0;
        double totalUsers = 0;
        double fillRate = 0;

        if (state is RoomFillRateLoaded) {
          final fillRateData = state.roomFillRateData;
          totalCapacity = fillRateData.fold(0, (sum, area) => sum + area.totalCapacity);
          totalUsers = fillRateData.fold(0, (sum, area) => sum + area.totalUsers);
          fillRate = totalCapacity > 0 ? (totalUsers / totalCapacity * 100) : 0;
          logger.i('Fill rate data loaded: $fillRate%, Capacity: $totalCapacity, Users: $totalUsers');
        } else if (state is PartialLoading && state.requestType == 'room_fill_rate') {
          logger.i('Loading fill rate data');
          return const Center(child: CircularProgressIndicator());
        } else if (state is StatisticsError && state.message.contains('room_fill_rate')) {
          logger.e('Fill rate error: ${state.message}');
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Lỗi tải dữ liệu: ${state.message}'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    context.read<StatisticsBloc>().add(FetchRoomFillRateStats(
                      areaId: selectedAreaId,
                      roomId: null,
                    ));
                  },
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        } else {
          logger.w('No fill rate data available, state: $state');
          return const Center(child: Text('Chưa có dữ liệu tỷ lệ lấp đầy'));
        }

        // Nếu không có dữ liệu, vẫn hiển thị PieChart với giá trị 0
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tỷ lệ lấp đầy phòng của ${selectedAreaId == null ? 'tất cả khu vực' : 'khu vực được chọn'}: ${fillRate.toStringAsFixed(2)}%',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: chartWidth,
              height: chartHeight - 60,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 20,
                  sections: [
                    PieChartSectionData(
                      color: Colors.blue,
                      value: totalUsers,
                      title: '${(totalUsers / (totalCapacity > 0 ? totalCapacity : 1) * 100).toStringAsFixed(1)}%',
                      radius: 200,
                      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    PieChartSectionData(
                      color: Colors.grey[300]!,
                      value: (totalCapacity - totalUsers).clamp(0, totalCapacity),
                      title: '${((totalCapacity - totalUsers) / (totalCapacity > 0 ? totalCapacity : 1) * 100).toStringAsFixed(1)}%',
                      radius: 200,
                      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ],
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                        return;
                      }
                      logger.i('Touched pie chart section: ${pieTouchResponse.touchedSection!.touchedSectionIndex}');
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bed, color: Colors.blue, size: 16),
                    SizedBox(width: 4),
                    Text('Phòng đã đủ người', style: TextStyle(fontSize: 12)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bed, color: Colors.grey, size: 16),
                    SizedBox(width: 4),
                    Text('Phòng còn chỗ trống', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}