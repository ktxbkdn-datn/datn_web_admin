import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/widgets/stat_page/room_stat_page.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/bloc/statistic_bloc.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/bloc/statistic_event.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/bloc/statistic_state.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/widgets/stat_card.dart';
import 'package:datn_web_admin/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:datn_web_admin/feature/auth/presentation/bloc/auth_state.dart';

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
      final authState = context.read<AuthBloc>().state;
      if (authState.auth != null) {
        _fetchRoomStatusSummary();
      } else {
        print('RoomStatCard: No auth token, skipping fetch');
      }
    });
  }

  void _fetchRoomStatusSummary() {
    if (_isFetching) {
      print('RoomStatCard: Already fetching, skipping');
      return;
    }
    print('RoomStatCard: Triggering FetchRoomStatusSummary for year ${DateTime.now().year}');
    _isFetching = true;
    try {
      final bloc = BlocProvider.of<StatisticsBloc>(context, listen: false);
      bloc.add(FetchRoomStatusSummary(
        year: DateTime.now().year,
        areaId: null,
      ));
    } catch (e) {
      print('RoomStatCard: Error triggering FetchRoomStatusSummary: $e');
      setState(() {
        _isFetching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('RoomStatCard: Building widget');
    return GestureDetector(
      onTap: () {
        print('RoomStatCard: Navigating to RoomStatsPage');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RoomStatsPage()),
        );
      },
      child: BlocListener<StatisticsBloc, StatisticsState>(
        listenWhen: (previous, current) => current is ManualSnapshotTriggered,
        listener: (context, state) {
          print('RoomStatCard: Manual snapshot triggered, refreshing data');
          final authState = context.read<AuthBloc>().state;
          if (authState.auth != null) {
            _fetchRoomStatusSummary();
          }
        },
        child: BlocBuilder<StatisticsBloc, StatisticsState>(
          buildWhen: (previous, current) =>
              current is StatisticsLoading ||
              (current is PartialLoading && current.requestType == 'room_status_summary') ||
              current is StatisticsError ||
              current is RoomStatusSummaryLoaded,
          builder: (context, state) {
            print('RoomStatCard: Processing state: $state');

            if (state is StatisticsLoading ||
                (state is PartialLoading && state.requestType == 'room_status_summary')) {
              print('RoomStatCard: Displaying loading indicator');
              return const SizedBox(
                width: 200,
                height: 120,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (state is StatisticsError) {
              print('RoomStatCard: Error: ${state.message}');
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
                        onPressed: () {
                          final authState = context.read<AuthBloc>().state;
                          if (authState.auth != null) {
                            _fetchRoomStatusSummary();
                          }
                        },
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is RoomStatusSummaryLoaded) {
              print('RoomStatCard: RoomStatusSummaryLoaded with data: ${state.summaryData}');
              final now = DateTime.now();
              final currentMonth = now.month;
              final currentYear = now.year;
              final lastMonth = currentMonth == 1 ? 12 : currentMonth - 1;
              final lastMonthYear = currentMonth == 1 ? currentYear - 1 : currentYear;

              final currentMonthData = state.summaryData.firstWhere(
                (data) => data['month'] == currentMonth,
                orElse: () => {'month': currentMonth, 'statuses': {'AVAILABLE': 0}},
              );
              _availableRoomsThisMonth = currentMonthData['statuses']['AVAILABLE'] ?? 0;

              final lastMonthData = state.summaryData.firstWhere(
                (data) => data['month'] == lastMonth,
                orElse: () => {'month': lastMonth, 'statuses': {'AVAILABLE': 0}},
              );
              _availableRoomsLastMonth = lastMonthData['statuses']['AVAILABLE'] ?? 0;

              print('RoomStatCard: Calculated: Current month ($currentMonth/$currentYear): $_availableRoomsThisMonth available rooms');
              print('RoomStatCard: Calculated: Last month ($lastMonth/$lastMonthYear): $_availableRoomsLastMonth available rooms');
              _isFetching = false;
            }

            double percentageChange = _availableRoomsLastMonth > 0
                ? ((_availableRoomsThisMonth - _availableRoomsLastMonth) / _availableRoomsLastMonth * 100)
                : _availableRoomsThisMonth > 0
                    ? 100.0
                    : 0.0;
            String percentageChangeText = percentageChange.isFinite
                ? '${percentageChange.toStringAsFixed(1)}%'
                : '0%';

            Color changeColor = percentageChange < 0 ? Colors.red : Colors.green;

            print('RoomStatCard: Rendering StatCard: value=$_availableRoomsThisMonth, percentageChange=$percentageChangeText, lastMonth=$_availableRoomsLastMonth');

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