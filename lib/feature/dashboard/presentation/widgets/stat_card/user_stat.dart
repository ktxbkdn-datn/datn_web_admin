import 'package:datn_web_admin/feature/dashboard/presentation/widgets/stat_page/user_stat_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../user/domain/entities/user_entity.dart';
import '../../../../user/presentation/bloc/user_bloc.dart';
import '../../../../user/presentation/bloc/user_state.dart';
import '../../../../user/presentation/bloc/user_event.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/widgets/stat_card.dart';
import 'package:datn_web_admin/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:datn_web_admin/feature/auth/presentation/bloc/auth_state.dart';

class UserStatCard extends StatefulWidget {
  const UserStatCard({Key? key}) : super(key: key);

  @override
  _UserStatCardState createState() => _UserStatCardState();
}

class _UserStatCardState extends State<UserStatCard> {
  List<UserEntity> _allUsers = [];
  int _totalUsers = 0;
  int _totalThisMonth = 0;
  int _lastMonthTotal = 0;
  bool _isFetching = false;
  bool _isCacheValid = false;

  @override
  void initState() {
    super.initState();
    _loadStatsFromCache().then((_) async {
      if (!_isCacheValid) {
        final authState = context.read<AuthBloc>().state;
        if (authState.auth != null) {
          await _fetchAllUsers();
        } else {
          print('UserStatCard: No auth token, skipping fetch');
        }
      }
    });
  }

  Future<void> _loadStatsFromCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _totalUsers = prefs.getInt('totalUsers') ?? 0;
      _totalThisMonth = prefs.getInt('totalThisMonth') ?? 0;
      _lastMonthTotal = prefs.getInt('lastMonthTotal') ?? 0;
      _isCacheValid = _totalUsers > 0; // Consider cache valid if we have totalUsers
    });
    print('Loaded stats from cache: Total=$_totalUsers, ThisMonth=$_totalThisMonth, LastMonth=$_lastMonthTotal');
  }

  Future<void> _fetchAllUsers() async {
    if (_isFetching) return;
    setState(() {
      _isFetching = true;
    });

    int page = 1;
    const int limit = 100; // Fetch in smaller chunks to avoid memory issues
    List<UserEntity> fetchedUsers = [];
    int totalItems = 0;

    try {
      while (true) {
        context.read<UserBloc>().add(FetchUsersEvent(page: page, limit: limit));
        await Future.delayed(const Duration(milliseconds: 100)); // Wait for state update

        final state = context.read<UserBloc>().state;
        if (state is UserLoaded) {
          fetchedUsers.addAll(state.users);
          totalItems = state.totalItems;

          if (fetchedUsers.length >= totalItems) {
            break; // We've fetched all users
          }
          page++;
        } else if (state is UserError) {
          throw Exception(state.message);
        }
      }

      setState(() {
        _allUsers = fetchedUsers;
        _totalUsers = totalItems;
        _calculateStats();
        _isCacheValid = true;
      });
      await _saveStats(totalItems, _totalThisMonth, _lastMonthTotal);
    } catch (e) {
      print('Error fetching users: $e');
      setState(() {
        _isCacheValid = false;
      });
    } finally {
      setState(() {
        _isFetching = false;
      });
    }
  }

  Future<void> _saveStats(int totalUsers, int totalThisMonth, int lastMonthTotal) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('totalUsers', totalUsers);
    await prefs.setInt('totalThisMonth', totalThisMonth);
    await prefs.setInt('lastMonthTotal', lastMonthTotal);
    print('Saved stats to SharedPreferences: Total=$totalUsers, ThisMonth=$totalThisMonth, LastMonth=$lastMonthTotal');
  }

  void _calculateStats() {
    final now = DateTime(2025, 6, 2); // Current date as per system time
    final currentMonthStart = DateTime(now.year, now.month, 1); // Đầu tháng 6
    final currentMonthEnd =
        DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1)); // Cuối tháng 6
    final lastMonthStart = DateTime(now.year, now.month - 1, 1); // Đầu tháng 5
    final lastMonthEnd = currentMonthStart.subtract(const Duration(days: 1)); // Cuối tháng 5

    _lastMonthTotal = _allUsers.where((user) {
      return user.createdAt.isAfter(lastMonthStart) &&
          user.createdAt.isBefore(lastMonthEnd.add(const Duration(days: 1)));
    }).length;

    _totalThisMonth = _allUsers.where((user) {
      return user.createdAt.isAfter(currentMonthStart) &&
          user.createdAt.isBefore(currentMonthEnd.add(const Duration(days: 1)));
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UserStatsPage()),
        );
      },
      child: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserCreated || state is UserUpdated || state is UserDeleted) {
            final authState = context.read<AuthBloc>().state;
            if (authState.auth != null) {
              _fetchAllUsers();
            }
          }
        },
        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            if (_isFetching && !_isCacheValid) {
              return const SizedBox(
                width: 200,
                height: 120,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            double percentageChange = _lastMonthTotal > 0
                ? ((_totalThisMonth - _lastMonthTotal) / _lastMonthTotal * 100)
                : _totalThisMonth > 0
                    ? 100.0
                    : 0.0;
            String percentageChangeText = percentageChange.isFinite
                ? '${percentageChange.toStringAsFixed(1)}%'
                : '0%';

            Color changeColor = percentageChange < 0 ? Colors.red : Colors.green;

            return StatCard(
              title: 'Tổng số người dùng được tạo',
              value: _totalUsers.toString(),
              percentageChange: percentageChangeText,
              lastMonthTotal: _lastMonthTotal.toString(),
              changeColor: changeColor,
            );
          },
        ),
      ),
    );
  }
}