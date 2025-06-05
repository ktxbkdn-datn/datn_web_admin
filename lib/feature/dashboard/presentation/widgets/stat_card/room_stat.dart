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

class _RoomStatCardState extends State<RoomStatCard> with RouteAware {
  int _availableRoomsThisMonth = 0;
  int _availableRoomsLastMonth = 0;
  bool _isFetching = false;
  bool _isDataFromThisCard = false;
  List<Map<String, dynamic>> _summaryData = []; // Cache data

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Làm mới dữ liệu khi quay lại trang
    final authState = context.read<AuthBloc>().state;
    if (authState.auth != null && !_isFetching) {
      _fetchRoomStatusSummary();
    }
  }

  void _initializeData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState.auth != null) {
        final currentState = context.read<StatisticsBloc>().state;
        if (currentState is RoomStatusSummaryLoaded) {
          print('RoomStatCard: Restoring data from existing state');
          _processRoomStatusSummary(currentState);
        }
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
    print('RoomStatCard: Triggering FetchRoomStatusSummary for year ${DateTime.now().year} for all areas');
    _isFetching = true;
    _isDataFromThisCard = true;
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
        _isDataFromThisCard = false;
      });
    }
  }

  void _processRoomStatusSummary(StatisticsState state) {
    if (state is RoomStatusSummaryLoaded) {
      _summaryData = state.summaryData;
    } else {
      return;
    }

    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;
    final lastMonth = currentMonth == 1 ? 12 : currentMonth - 1;
    final lastMonthYear = currentMonth == 1 ? currentYear - 1 : currentYear;

    final currentMonthData = _summaryData.firstWhere(
      (data) => data['month'] == currentMonth,
      orElse: () => {'month': currentMonth, 'statuses': {'AVAILABLE': 0}},
    );
    _availableRoomsThisMonth = currentMonthData['statuses']['AVAILABLE'] ?? 0;

    final lastMonthData = _summaryData.firstWhere(
      (data) => data['month'] == lastMonth,
      orElse: () => {'month': lastMonth, 'statuses': {'AVAILABLE': 0}},
    );
    _availableRoomsLastMonth = lastMonthData['statuses']['AVAILABLE'] ?? 0;

    print('RoomStatCard: Calculated: Current month ($currentMonth/$currentYear): $_availableRoomsThisMonth available rooms');
    print('RoomStatCard: Calculated: Last month ($lastMonth/$lastMonthYear): $_availableRoomsLastMonth available rooms');
    _isFetching = false;
    _isDataFromThisCard = false;
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
              (current is RoomStatusSummaryLoaded && _isDataFromThisCard),
          builder: (context, state) {
            print('RoomStatCard: Processing state: $state');

            if ((state is StatisticsLoading ||
                    (state is PartialLoading && state.requestType == 'room_status_summary') ||
                    state is StatisticsInitial) &&
                (_availableRoomsThisMonth == 0 && _availableRoomsLastMonth == 0)) {
              print('RoomStatCard: Displaying loading indicator');
              return const SizedBox(
                width: 200,
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (state is StatisticsError) {
              print('RoomStatCard: Error: ${state.message}');
              _isFetching = false;
              _isDataFromThisCard = false;
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

            if (state is RoomStatusSummaryLoaded && _isDataFromThisCard) {
              print('RoomStatCard: Processing loaded data for all areas');
              _processRoomStatusSummary(state);
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