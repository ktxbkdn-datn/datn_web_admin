// lib/src/features/room/presentation/widgets/room_stat_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:datn_web_admin/feature/room/domain/entities/room_entity.dart';
import 'package:datn_web_admin/feature/room/presentations/bloc/room_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../stat_card.dart';

class RoomStatCard extends StatefulWidget {
  const RoomStatCard({Key? key}) : super(key: key);

  @override
  _RoomStatCardState createState() => _RoomStatCardState();
}

class _RoomStatCardState extends State<RoomStatCard> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Gửi FetchRoomsEvent ngay khi widget được khởi tạo
    context.read<RoomBloc>().add(GetAllRoomsEvent(page: 1, limit: 1000)); // Lấy tất cả phòng
  }

  @override
  void initState() {
    super.initState();
    didChangeDependencies();
  }

  // Lưu danh sách phòng vào bộ nhớ cục bộ
  Future<void> _saveRooms(List<RoomEntity> rooms) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String roomsJson = jsonEncode(rooms.map((room) => room.toJson()).toList());
    await prefs.setString('rooms', roomsJson);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoomBloc, RoomState>(
      builder: (context, state) {
        // Kiểm tra trạng thái và lấy danh sách rooms một cách an toàn
        List<RoomEntity> rooms = [];
        bool isLoading = state is RoomLoading;

        if (state is RoomLoaded) {
          rooms = state.rooms;
          _saveRooms(rooms); // Lưu danh sách phòng vào bộ nhớ cục bộ
        }

        // Hiển thị loading nếu đang tải và chưa có dữ liệu
        if (isLoading && rooms.isEmpty) {
          return const SizedBox(
            width: 200, // Đặt kích thước phù hợp với StatCard
            height: 120,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Tổng số phòng
        final totalRooms = rooms.length.toString();

        // Số phòng đã có người ở (OCCUPIED)
        final occupiedRooms = rooms.where((room) => room.status == 'OCCUPIED').length;

        // Tính phần trăm phòng đã có người ở
        double percentageOccupied = rooms.isNotEmpty ? (occupiedRooms / rooms.length) * 100 : 0.0;

        String percentageOccupiedText =
        percentageOccupied.isFinite ? '${percentageOccupied.toStringAsFixed(1)}%' : '0%';

        // Xác định màu thay đổi dựa trên tỷ lệ phòng có người ở
        Color changeColor = percentageOccupied > 50 ? Colors.red : Colors.green;

        return StatCard(
          title: 'Total Available Rooms',
          value: totalRooms,
          percentageChange: percentageOccupiedText, // Phần trăm phòng đã có người ở
          lastMonthTotal: totalRooms, // Gán tổng số phòng vào lastMonthTotal
          changeColor: changeColor,
        );
      },
    );
  }
}