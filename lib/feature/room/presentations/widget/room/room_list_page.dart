import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../common/widget/search_bar.dart';
import '../../../../../common/widget/custom_data_table.dart';
import '../../../../../common/widget/filter_tab.dart';
import '../../../../../common/widget/pagination_controls.dart';
import '../../../../../common/constants/colors.dart';
import '../../../domain/entities/area_entity.dart';
import '../../../domain/entities/room_entity.dart';
import '../../bloc/area_bloc/area_bloc.dart';
import '../../bloc/area_bloc/area_event.dart';
import '../../bloc/area_bloc/area_state.dart';
import '../../bloc/room_bloc/room_bloc.dart';
import '../../bloc/room_image_bloc/room_image_bloc.dart';
import 'create_room_dialog.dart';
import 'edit_room_dialog.dart';
import 'room_detail_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class RoomListPage extends StatefulWidget {
  const RoomListPage({Key? key}) : super(key: key);

  @override
  _RoomListPageState createState() => _RoomListPageState();
}

class _RoomListPageState extends State<RoomListPage> with AutomaticKeepAliveClientMixin {
  int _currentPage = 1;
  static const int _limit = 12;
  int? _selectedAreaId;
  String _filterStatus = 'All';
  String _searchQuery = '';
  List<RoomEntity> _allRooms = [];
  List<RoomEntity> _rooms = [];
  bool _isInitialLoad = true;
  List<int> _selectedRoomIds = [];
  final List<double> _columnWidths = [50.0, 300.0, 200.0, 200.0, 100.0];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadLocalData();
    context.read<AreaBloc>().add(FetchAreasEvent(page: 1, limit: 100));
    _fetchRooms();
  }

  Future<void> _loadLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _currentPage = prefs.getInt('roomCurrentPage') ?? 1;
    _selectedAreaId = prefs.getInt('selectedAreaId');
    _filterStatus = prefs.getString('roomFilterStatus') ?? 'All';
    _searchQuery = prefs.getString('roomSearchQuery') ?? '';
    String? roomsJson = prefs.getString('rooms');
    if (roomsJson != null) {
      List<dynamic> roomsList = jsonDecode(roomsJson);
      setState(() {
        _allRooms = roomsList.map((json) => RoomEntity.fromJson(json)).toList();
        _applyFilters();
      });
    }
  }

  Future<void> _saveLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('roomCurrentPage', _currentPage);
    if (_selectedAreaId != null) {
      await prefs.setInt('selectedAreaId', _selectedAreaId!);
    } else {
      await prefs.remove('selectedAreaId');
    }
    await prefs.setString('roomFilterStatus', _filterStatus);
    await prefs.setString('roomSearchQuery', _searchQuery);
    await prefs.setString('rooms', jsonEncode(_allRooms.map((room) => room.toJson()).toList()));
  }

  void _fetchRooms() {
    context.read<RoomBloc>().add(const GetAllRoomsEvent(page: 1, limit: 1000, areaId: null));
  }

  void _applyFilters() {
    setState(() {
      _rooms = _allRooms.where((room) {
        bool matchesStatus = _filterStatus == 'All' || room.status == _filterStatus;
        bool matchesSearch = _searchQuery.isEmpty ||
            room.name.toLowerCase().contains(_searchQuery.toLowerCase());
        bool matchesArea = _selectedAreaId == null || room.areaId == _selectedAreaId;
        return matchesStatus && matchesSearch && matchesArea;
      }).toList();
      _selectedRoomIds.removeWhere((id) => !_rooms.any((room) => room.roomId == id));
    });
  }

  void _toggleSelection(int roomId) {
    setState(() {
      if (_selectedRoomIds.contains(roomId)) {
        _selectedRoomIds.remove(roomId);
      } else {
        _selectedRoomIds.add(roomId);
      }
    });
  }

  void _deleteSelected() {
    if (_selectedRoomIds.isNotEmpty) {
      for (int roomId in _selectedRoomIds) {
        context.read<RoomBloc>().add(DeleteRoomEvent(roomId));
      }
      setState(() {
        _selectedRoomIds.clear();
      });
    }
  }

  // Helper method to get translated status text for display
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

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final screenWidth = MediaQuery.of(context).size.width;
    final paddingHorizontal = screenWidth > 1200 ? screenWidth * 0.1 : 8.0;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.glassmorphismStart, AppColors.glassmorphismEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        SafeArea(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 960,
              minHeight: 600,
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: MultiBlocListener(
                listeners: [
                  BlocListener<AreaBloc, AreaState>(
                    listener: (context, areaState) {
                      if (areaState.areas.isNotEmpty) {
                        bool isValidAreaId = _selectedAreaId == null ||
                            areaState.areas.any((area) => area.areaId == _selectedAreaId);
                        if (!isValidAreaId) {
                          setState(() {
                            _selectedAreaId = null;
                          });
                          _saveLocalData();
                          _applyFilters();
                        }
                      }
                    },
                  ),
                  BlocListener<RoomBloc, RoomState>(
                    listener: (context, state) {
                      if (state is RoomError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${state.message}')),
                        );
                      } else if (state is RoomDeleted) {
                        setState(() {
                          _allRooms.removeWhere((room) => room.roomId == state.roomId);
                          _applyFilters();
                        });
                        _saveLocalData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Xóa phòng thành công!'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else if (state is RoomLoaded) {
                        setState(() {
                          _allRooms = state.rooms;
                          _isInitialLoad = false;
                          _applyFilters();
                        });
                        _saveLocalData();
                      }
                    },
                  ),
                ],
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: 16.0),
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    FilterTab(
                                      label: 'Tất cả phòng (${_allRooms.length})',
                                      isSelected: _filterStatus == 'All',
                                      onTap: () {
                                        setState(() {
                                          _filterStatus = 'All';
                                          _currentPage = 1;
                                          _saveLocalData();
                                          _applyFilters();
                                        });
                                      },
                                    ),
                                    const SizedBox(width: 10),
                                    FilterTab(
                                      label: 'Phòng còn trống (${_allRooms.where((room) => room.status == 'AVAILABLE').length})',
                                      isSelected: _filterStatus == 'AVAILABLE',
                                      onTap: () {
                                        setState(() {
                                          _filterStatus = 'AVAILABLE';
                                          _currentPage = 1;
                                          _saveLocalData();
                                          _applyFilters();
                                        });
                                      },
                                    ),
                                    const SizedBox(width: 10),
                                    FilterTab(
                                      label: 'Phòng hết chỗ (${_allRooms.where((room) => room.status == 'OCCUPIED').length})',
                                      isSelected: _filterStatus == 'OCCUPIED',
                                      onTap: () {
                                        setState(() {
                                          _filterStatus = 'OCCUPIED';
                                          _currentPage = 1;
                                          _saveLocalData();
                                          _applyFilters();
                                        });
                                      },
                                    ),
                                    const SizedBox(width: 10),
                                    FilterTab(
                                      label: 'Phòng đang bảo trì (${_allRooms.where((room) => room.status == 'MAINTENANCE').length})',
                                      isSelected: _filterStatus == 'MAINTENANCE',
                                      onTap: () {
                                        setState(() {
                                          _filterStatus = 'MAINTENANCE';
                                          _currentPage = 1;
                                          _saveLocalData();
                                          _applyFilters();
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        BlocBuilder<AreaBloc, AreaState>(
                                          builder: (context, areaState) {
                                            List<AreaEntity> uniqueAreas = [];
                                            Set<int> seenAreaIds = {};
                                            for (var area in areaState.areas) {
                                              if (!seenAreaIds.contains(area.areaId)) {
                                                seenAreaIds.add(area.areaId);
                                                uniqueAreas.add(area);
                                              }
                                            }

                                            if (_selectedAreaId != null &&
                                                !uniqueAreas.any((area) => area.areaId == _selectedAreaId)) {
                                              _selectedAreaId = null;
                                            }

                                            return Expanded(
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: Colors.grey),
                                                  borderRadius: BorderRadius.circular(8.0),
                                                ),
                                                child: DropdownButton<int>(
                                                  hint: const Text('Tất cả khu vực'),
                                                  value: _selectedAreaId,
                                                  isExpanded: true,
                                                  underline: const SizedBox(),
                                                  items: [
                                                    const DropdownMenuItem<int>(
                                                      value: null,
                                                      child: Text('Tất cả khu vực'),
                                                    ),
                                                    ...uniqueAreas.map((area) => DropdownMenuItem<int>(
                                                          value: area.areaId,
                                                          child: Text(area.name),
                                                        )),
                                                  ],
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _selectedAreaId = value;
                                                      _currentPage = 1;
                                                      _saveLocalData();
                                                      _applyFilters();
                                                    });
                                                  },
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: SearchBarTab(
                                            onChanged: (value) {
                                              setState(() {
                                                _searchQuery = value;
                                                _currentPage = 1;
                                                _saveLocalData();
                                                _applyFilters();
                                              });
                                            },
                                            hintText: 'Tìm kiếm phòng...',
                                            initialValue: _searchQuery,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Row(
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: _selectedRoomIds.isEmpty ? null : _deleteSelected,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        icon: const Icon(Icons.delete),
                                        label: const Text('Xoá phòng đã chọn'),
                                      ),
                                      const SizedBox(width: 10),
                                      ElevatedButton.icon(
                                        onPressed: () => context.read<RoomBloc>().add(const GetAllRoomsEvent(page: 1, limit: 1000)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        icon: const Icon(Icons.refresh),
                                        label: const Text('Làm mới'),
                                      ),
                                      const SizedBox(width: 10),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => const CreateRoomDialog(),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        icon: const Icon(Icons.add),
                                        label: const Text('Thêm phòng mới'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: MediaQuery.of(context).size.height - 200,
                        child: SingleChildScrollView(
                          child: BlocBuilder<RoomBloc, RoomState>(
                            builder: (context, state) {
                              bool isLoading = state is RoomLoading;
                              String? errorMessage;

                              if (state is RoomError) {
                                errorMessage = state.message;
                              }

                              int startIndex = (_currentPage - 1) * _limit;
                              int endIndex = startIndex + _limit;
                              if (endIndex > _rooms.length) endIndex = _rooms.length;
                              List<RoomEntity> paginatedRooms = startIndex < _rooms.length
                                  ? _rooms.sublist(startIndex, endIndex)
                                  : [];

                              return isLoading && _isInitialLoad
                                  ? const Center(child: CircularProgressIndicator())
                                  : errorMessage != null
                                      ? Center(child: Text('Lỗi: $errorMessage'))
                                      : paginatedRooms.isEmpty
                                          ? const Center(child: Text('Không có phòng nào'))
                                          : Column(
                                              children: [
                                                GenericDataTable<RoomEntity>(
                                                  headers: const [
                                                    '',
                                                    'Tên phòng',
                                                    'Số người / Sức chứa',
                                                    'Trạng thái',
                                                    '',
                                                  ],
                                                  data: paginatedRooms,
                                                  columnWidths: _columnWidths,
                                                  cellBuilder: (room, index) {
                                                    switch (index) {
                                                      case 0:
                                                        return Checkbox(
                                                          value: _selectedRoomIds.contains(room.roomId),
                                                          onChanged: (value) {
                                                            _toggleSelection(room.roomId);
                                                          },
                                                        );
                                                      case 1:
                                                        return Text(
                                                          room.name,
                                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                                          textAlign: TextAlign.center,
                                                          overflow: TextOverflow.ellipsis,
                                                        );
                                                      case 2:
                                                        return Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            const Icon(Icons.person, size: 16),
                                                            const SizedBox(width: 4),
                                                            Text('${room.currentPersonNumber}/${room.capacity}'),
                                                          ],
                                                        );
                                                      case 3:
                                                        return Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                          decoration: BoxDecoration(
                                                            color: _getStatusColor(room.status),
                                                            borderRadius: BorderRadius.circular(12),
                                                          ),
                                                          child: Text(
                                                            _getStatusDisplayText(room.status), // Use translated text
                                                            style: const TextStyle(color: Colors.white),
                                                            textAlign: TextAlign.center,
                                                          ),
                                                        );
                                                      case 4:
                                                        return Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            IconButton(
                                                              icon: const Icon(Icons.visibility),
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
                                                            IconButton(
                                                              icon: const Icon(Icons.edit),
                                                              onPressed: () {
                                                                showDialog(
                                                                  context: context,
                                                                  builder: (context) => EditRoomDialog(room: room),
                                                                );
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                      default:
                                                        return const SizedBox();
                                                    }
                                                  },
                                                ),
                                                PaginationControls(
                                                  currentPage: _currentPage,
                                                  totalItems: _rooms.length,
                                                  limit: _limit,
                                                  onPageChanged: (page) {
                                                    setState(() {
                                                      _currentPage = page;
                                                      _saveLocalData();
                                                    });
                                                  },
                                                ),
                                              ],
                                            );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'AVAILABLE':
        return Colors.green;
      case 'OCCUPIED':
        return Colors.blue;
      case 'RESERVED':
        return Colors.yellow;
      case 'MAINTENANCE':
        return Colors.red;
      case 'DISABLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}