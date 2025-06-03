// lib/src/features/room/presentation/widgets/room_stat_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/widgets/stat_page/room_stat_page.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/bloc/statistic_bloc.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/bloc/statistic_event.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/bloc/statistic_state.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/widgets/stat_card.dart';

class RoomStatCard extends StatefulWidget {
  const RoomStatCard({Key? key}) : super(key: key);

  @override
  _RoomStatCardState createState() => _RoomStatCardState();
}

class _RoomStatCardState extends State<RoomStatCard> {
  int _availableRoomsThisMonth = 0;
  int _availableRoomsLastMonth = 0;
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchRoomStatusSummary();
    });
  }

  void _fetchRoomStatusSummary() {
    if (_isFetching) {
      print('RoomStatCard: Already fetching, skipping'); // Debug log
      return;
    }
    print('RoomStatCard: Triggering FetchRoomStatusSummary for year ${DateTime.now().year}'); // Debug log
    _isFetching = true;
    try {
      final bloc = BlocProvider.of<StatisticsBloc>(context, listen: false);
      bloc.add(FetchRoomStatusSummary(
        year: DateTime.now().year,
        areaId: null, // Fetch for all areas
      ));
    } catch (e) {
      print('RoomStatCard: Error triggering FetchRoomStatusSummary: $e'); // Debug log
      _isFetching = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('RoomStatCard: Building widget'); // Debug log
    return GestureDetector(
      onTap: () {
        print('RoomStatCard: Navigating to RoomStatsPage'); // Debug log
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RoomStatsPage()),
        );
      },
      child: BlocListener<StatisticsBloc, StatisticsState>(
        listenWhen: (previous, current) => current is ManualSnapshotTriggered,
        listener: (context, state) {
          print('RoomStatCard: Manual snapshot triggered, refreshing data'); // Debug log
          _fetchRoomStatusSummary();
        },
        child: BlocBuilder<StatisticsBloc, StatisticsState>(
          buildWhen: (previous, current) =>
              current is StatisticsLoading ||
              (current is PartialLoading && current.requestType == 'room_status_summary') ||
              current is StatisticsError ||
              current is RoomStatusSummaryLoaded,
          builder: (context, state) {
            print('RoomStatCard: Processing state: $state'); // Debug log

            // Handle loading states
            if (state is StatisticsLoading ||
                (state is PartialLoading && state.requestType == 'room_status_summary')) {
              print('RoomStatCard: Displaying loading indicator'); // Debug log
              return const SizedBox(
                width: 200,
                height: 120,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // Handle error states
            if (state is StatisticsError) {
              print('RoomStatCard: Error: ${state.message}'); // Debug log
              _isFetching = false;
              return SizedBox(
                width: 200,
                height: 120,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Lỗi: ${state.message}'),
                      TextButton(
                        onPressed: _fetchRoomStatusSummary,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Handle room status summary loaded
            if (state is RoomStatusSummaryLoaded) {
              print('RoomStatCard: RoomStatusSummaryLoaded with data: ${state.summaryData}'); // Debug log
              final now = DateTime.now();
              final currentMonth = now.month;
              final currentYear = now.year;
              final lastMonth = currentMonth == 1 ? 12 : currentMonth - 1;
              final lastMonthYear = currentMonth == 1 ? currentYear - 1 : currentYear;

              // Find data for current month
              final currentMonthData = state.summaryData.firstWhere(
                (data) => data['month'] == currentMonth,
                orElse: () => {'month': currentMonth, 'statuses': {'AVAILABLE': 0}},
              );
              _availableRoomsThisMonth = currentMonthData['statuses']['AVAILABLE'] ?? 0;

              // Find data for last month
              final lastMonthData = state.summaryData.firstWhere(
                (data) => data['month'] == lastMonth,
                orElse: () => {'month': lastMonth, 'statuses': {'AVAILABLE': 0}},
              );
              _availableRoomsLastMonth = lastMonthData['statuses']['AVAILABLE'] ?? 0;

              print('RoomStatCard: Calculated: Current month ($currentMonth/$currentYear): $_availableRoomsThisMonth available rooms'); // Debug log
              print('RoomStatCard: Calculated: Last month ($lastMonth/$lastMonthYear): $_availableRoomsLastMonth available rooms'); // Debug log
              _isFetching = false;
            }

            // Calculate percentage change
            double percentageChange = _availableRoomsLastMonth > 0
                ? ((_availableRoomsThisMonth - _availableRoomsLastMonth) / _availableRoomsLastMonth * 100)
                : _availableRoomsThisMonth > 0
                    ? 100.0 // If last month had no available rooms, assume 100% increase
                    : 0.0; // If both months have no available rooms, 0%
            String percentageChangeText = percentageChange.isFinite
                ? '${percentageChange.toStringAsFixed(1)}%'
                : '0%';

            // Determine change color
            Color changeColor = percentageChange < 0 ? Colors.red : Colors.green;

            print('RoomStatCard: Rendering StatCard: value=$_availableRoomsThisMonth, percentageChange=$percentageChangeText, lastMonth=$_availableRoomsLastMonth'); // Debug log

            return StatCard(
              title: 'Tổng số phòng còn trống',
              value: _availableRoomsThisMonth.toString(),
              percentageChange: percentageChangeText,
              lastMonthTotal: _availableRoomsLastMonth.toString(),
              changeColor: changeColor,
            );
          },
        ),
      ),
    );
  }
}