import 'package:datn_web_admin/feature/dashboard/presentation/bloc/statistic_bloc.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/bloc/statistic_event.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/bloc/statistic_state.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/widgets/stat_page/user_stat_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FillRateStatCard extends StatelessWidget {
  final int? selectedAreaId;

  const FillRateStatCard({Key? key, this.selectedAreaId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UserStatsPage()),
        );
      },
      child: BlocBuilder<StatisticsBloc, StatisticsState>(
        buildWhen: (previous, current) =>
            current is RoomFillRateLoaded ||
            (current is PartialLoading && current.requestType == 'room_fill_rate') ||
            (current is StatisticsError && current.message.contains('room_fill_rate')),
        builder: (context, state) {
          double totalCapacity = 0;
          double totalUsers = 0;
          double fillRate = 0;

          if (state is RoomFillRateLoaded) {
            final fillRateData = state.roomFillRateData;
            totalCapacity = fillRateData.fold(0, (sum, area) => sum + area.totalCapacity);
            totalUsers = fillRateData.fold(0, (sum, area) => sum + area.totalUsers);
            fillRate = totalCapacity > 0 ? (totalUsers / totalCapacity) : 0;
          }

          final double fillPercent = fillRate;
          final double emptyPercent = 1 - fillPercent;

          Widget content;
          if (state is RoomFillRateLoaded) {
            content = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Tỉ lệ lấp đầy phòng',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Đủ người', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: fillPercent,
                        minHeight: 10,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('${(fillPercent * 100).toStringAsFixed(1)}%', style: const TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Text('Trống', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 18),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: emptyPercent,
                        minHeight: 10,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('${(emptyPercent * 100).toStringAsFixed(1)}%', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            );
          } else if (state is PartialLoading && state.requestType == 'room_fill_rate') {
            content = const Center(child: CircularProgressIndicator());
          } else if (state is StatisticsError && state.message.contains('room_fill_rate')) {
            content = const Center(child: Text('Lỗi tải dữ liệu'));
          } else {
            content = const Center(child: CircularProgressIndicator());
          }

          return SizedBox(
            width: 200,
            height: 120,
            child: Card(
              elevation: 2,
              margin: EdgeInsets.zero,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: content,
              ),
            ),
          );
        },
      ),
    );
  }
}