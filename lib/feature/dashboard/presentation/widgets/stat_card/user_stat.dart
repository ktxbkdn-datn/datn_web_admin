import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../user/domain/entities/user_entity.dart';
import '../../../../user/data/model/user_model.dart'; // Thêm import cho UserModel
import '../../../../user/presentation/bloc/user_bloc.dart';
import '../../../../user/presentation/bloc/user_state.dart';
import '../../../../user/presentation/bloc/user_event.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/widgets/stat_card.dart';

class UserStatCard extends StatefulWidget {
  const UserStatCard({Key? key}) : super(key: key);

  @override
  _UserStatCardState createState() => _UserStatCardState();
}

class _UserStatCardState extends State<UserStatCard> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Gửi FetchUsersEvent ngay khi widget được khởi tạo
    context.read<UserBloc>().add(FetchUsersEvent(page: 1, limit: 1000)); // Lấy tất cả người dùng
  }

  @override
  void initState() {
    super.initState();
    didChangeDependencies();
  }

  // Lưu danh sách người dùng vào bộ nhớ cục bộ
  Future<void> _saveUsers(List<UserEntity> users) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Cast users sang List<UserModel> để gọi toJson
    List<UserModel> userModels = users.map((user) => UserModel(
      userId: user.userId,
      fullname: user.fullname,
      email: user.email,
      phone: user.phone,
      dateOfBirth: user.dateOfBirth,
      cccd: user.cccd,
      className: user.className,
      createdAt: user.createdAt,
      isDeleted: user.isDeleted,
      deletedAt: user.deletedAt,
      version: user.version,
    )).toList();
    String usersJson = jsonEncode(userModels.map((user) => user.toJson()).toList());
    await prefs.setString('users', usersJson);
    print('Saved users to SharedPreferences: ${users.length} users');
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        // Kiểm tra trạng thái và lấy danh sách users một cách an toàn
        List<UserEntity> users = [];
        bool isLoading = state.isLoading;

        // Kiểm tra trực tiếp state.users.isNotEmpty thay vì state is UserLoaded || state is UserUpdated
        if (state.users.isNotEmpty) {
          users = state.users;
          _saveUsers(users); // Lưu danh sách người dùng vào bộ nhớ cục bộ
        }

        // Hiển thị loading nếu đang tải và chưa có dữ liệu
        if (isLoading && users.isEmpty) {
          return const SizedBox(
            width: 200, // Đặt kích thước phù hợp với StatCard
            height: 120,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Tổng số người dùng hiện tại
        final totalUsers = users.length.toString();

        // Xác định tháng hiện tại (tháng 4) và tháng trước (tháng 3)
        final now = DateTime.now();
        final currentMonthStart = DateTime(now.year, now.month, 1); // Đầu tháng 4
        final currentMonthEnd = DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1)); // Cuối tháng 4
        final lastMonthStart = DateTime(now.year, now.month - 1, 1); // Đầu tháng 3
        final lastMonthEnd = currentMonthStart.subtract(const Duration(days: 1)); // Cuối tháng 3

        // Tính tổng số người dùng tháng trước (tháng 3)
        int lastMonthTotal = users.where((user) {
          return user.createdAt.isAfter(lastMonthStart) && user.createdAt.isBefore(lastMonthEnd.add(const Duration(days: 1)));
        }).length;

        // Tính tổng số người dùng tháng này (tháng 4)
        int totalThisMonth = users.where((user) {
          return user.createdAt.isAfter(currentMonthStart) && user.createdAt.isBefore(currentMonthEnd.add(const Duration(days: 1)));
        }).length;

        // Tính phần trăm thay đổi
        double percentageChange = lastMonthTotal > 0
            ? ((totalThisMonth - lastMonthTotal) / lastMonthTotal * 100)
            : totalThisMonth > 0
            ? 100.0 // Nếu tháng trước không có người dùng nhưng tháng này có, thì tăng 100%
            : 0.0; // Nếu cả hai tháng đều không có người dùng, thì 0%
        String percentageChangeText = percentageChange.isFinite
            ? '${percentageChange.toStringAsFixed(1)}%'
            : '0%';

        // Xác định màu thay đổi
        Color changeColor = percentageChange < 0 ? Colors.red : Colors.green;

        return StatCard(
          title: 'Total Users',
          value: totalUsers,
          percentageChange: percentageChangeText,
          lastMonthTotal: lastMonthTotal.toString(),
          changeColor: changeColor,
        );
      },
    );
  }
}