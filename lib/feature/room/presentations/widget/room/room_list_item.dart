import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/room_entity.dart';
import '../../bloc/room_bloc/room_bloc.dart';
import '../../bloc/room_image_bloc/room_image_bloc.dart';
import 'room_detail_dialog.dart';
import 'edit_room_dialog.dart';

class RoomListItem extends StatelessWidget {
  final RoomEntity room;
  final bool isSelected;
  final Function(int) onToggleSelection;
  final int columnIndex;
  final double columnWidth;

  const RoomListItem({
    Key? key,
    required this.room,
    required this.isSelected,
    required this.onToggleSelection,
    required this.columnIndex,
    required this.columnWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (columnIndex) {
      case 0:
        return Checkbox(
          value: isSelected,
          onChanged: (value) {
            onToggleSelection(room.roomId);
          },
        );
      case 1:
        // Cải tiến hiển thị tên phòng với thông tin vị trí
        return _buildRoomNameWithLocation();
      case 2:
        return _buildOccupancyInfo();
      case 3:
        return _buildStatusBadge();
      case 4:
        return _buildActionButtons(context);
      default:
        return const SizedBox();
    }
  }

  Widget _buildRoomNameWithLocation() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            room.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 14,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _getLocationDescription(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOccupancyInfo() {
    final occupancyRate = room.capacity > 0 ? room.currentPersonNumber / room.capacity : 0.0;
    
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person, size: 16),
              const SizedBox(width: 4),
              Text(
                '${room.currentPersonNumber}/${room.capacity}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: occupancyRate,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getOccupancyColor(occupancyRate),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${(occupancyRate * 100).toInt()}%',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(room.status),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor(room.status).withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(room.status),
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            _getStatusDisplayText(room.status),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildActionButton(
            icon: Icons.visibility,
            tooltip: 'Xem chi tiết',
            color: Colors.blue,
            onPressed: () {
              context.read<RoomBloc>().add(GetRoomByIdEvent(room.roomId));
              context.read<RoomImageBloc>().add(GetRoomImagesEvent(room.roomId));
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (dialogContext) => RoomDetailDialog(room: room),
              );
            },
          ),
          const SizedBox(width: 4),
          _buildActionButton(
            icon: Icons.edit,
            tooltip: 'Chỉnh sửa',
            color: Colors.orange,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => EditRoomDialog(room: room),
              );
            },
          ),
          const SizedBox(width: 4),
          _buildActionButton(
            icon: Icons.people,
            tooltip: 'Xem sinh viên',
            color: Colors.green,
            onPressed: () {
              context.read<RoomBloc>().add(GetUsersInRoomEvent(room.roomId));
              showDialog(
                context: context,
                builder: (context) => _buildUsersInRoomDialog(context, room),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: IconButton(
        icon: Icon(icon, size: 18),
        tooltip: tooltip,
        color: color,
        onPressed: onPressed,
        constraints: const BoxConstraints(
          minWidth: 36,
          minHeight: 36,
        ),
      ),
    );
  }

  // Dialog hiển thị danh sách sinh viên trong phòng
  Widget _buildUsersInRoomDialog(BuildContext context, RoomEntity room) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 800,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Danh sách sinh viên - ${room.name}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            BlocBuilder<RoomBloc, RoomState>(
              builder: (context, state) {
                if (state is RoomLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is UsersInRoomLoaded && state.roomId == room.roomId) {
                  if (state.users.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Không có sinh viên nào trong phòng này'),
                    );
                  }
                  return SizedBox(
                    height: 400,
                    child: ListView.builder(
                      itemCount: state.users.length,
                      itemBuilder: (context, index) {
                        final user = state.users[index];
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(user['fullname'][0] ?? '?'),
                          ),
                          title: Text(user['fullname'] ?? 'Không có tên'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('MSSV: ${user['student_code'] ?? 'N/A'}'),
                              Text('Email: ${user['email'] ?? 'N/A'}'),
                            ],
                          ),
                          trailing: Text('Quê: ${user['hometown'] ?? 'N/A'}'),
                        );
                      },
                    ),
                  );
                } else if (state is RoomError) {
                  return Center(child: Text('Lỗi: ${state.message}'));
                }
                return const Center(child: Text('Đang tải dữ liệu...'));
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<RoomBloc>().add(ExportUsersInRoomEvent(room.roomId));
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Xuất Excel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  // Các phương thức hỗ trợ
  String _getLocationDescription() {
    final floor = _extractFloor();
    final building = _extractBuilding();
    return '$building - Tầng $floor';
  }

  String _extractFloor() {
    // Lấy kí tự đầu tiên của tên phòng làm số tầng
    if (room.name.isNotEmpty) {
      String firstChar = room.name[0];
      if (RegExp(r'[0-9]').hasMatch(firstChar)) {
        return firstChar;
      }
    }
    return '1'; // Mặc định tầng 1
  }

  String _extractBuilding() {
    // Lấy thông tin tòa nhà từ area của room
    if (room.areaDetails != null && room.areaDetails!.name.isNotEmpty) {
      return 'Tòa ${room.areaDetails!.name}';
    }
    return 'Tòa A'; // Mặc định
  }

  Color _getOccupancyColor(double rate) {
    if (rate >= 1.0) return Colors.red;
    if (rate >= 0.8) return Colors.orange;
    if (rate >= 0.5) return Colors.yellow[700]!;
    return Colors.green;
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'AVAILABLE':
        return Icons.check_circle;
      case 'OCCUPIED':
        return Icons.people;
      case 'RESERVED':
        return Icons.bookmark;
      case 'MAINTENANCE':
        return Icons.build;
      case 'DISABLED':
        return Icons.block;
      default:
        return Icons.help;
    }
  }

  String _getStatusDisplayText(String status) {
    switch (status) {
      case 'AVAILABLE':
        return 'Còn trống';
      case 'OCCUPIED':
        return 'Hết chỗ';
      case 'RESERVED':
        return 'Đã đặt';
      case 'MAINTENANCE':
        return 'Bảo trì';
      case 'DISABLED':
        return 'Không hoạt động';
      default:
        return 'Không xác định';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'AVAILABLE':
        return Colors.green;
      case 'OCCUPIED':
        return Colors.blue;
      case 'RESERVED':
        return Colors.orange;
      case 'MAINTENANCE':
        return Colors.red;
      case 'DISABLED':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}