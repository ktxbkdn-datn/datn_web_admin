import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_saver/file_saver.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

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

import 'create_room_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'room_list_item.dart';

class RoomListPage extends StatefulWidget {
  const RoomListPage({Key? key}) : super(key: key);

  @override
  _RoomListPageState createState() => _RoomListPageState();
}

class _RoomListPageState extends State<RoomListPage> with AutomaticKeepAliveClientMixin {
  // Biến trạng thái và bộ lọc
  int _currentPage = 1;
  static const int _limit = 12;
  int? _selectedAreaId;
  String _filterStatus = 'All';
  String _searchQuery = '';
  
  // Giá và sức chứa cho bộ lọc nâng cao (có thể thêm UI để điều chỉnh)
  double? _minPrice;
  double? _maxPrice;
  int? _minCapacity;
  int? _maxCapacity;
  
  // Danh sách phòng và trạng thái
  List<RoomEntity> _rooms = [];
  int _totalRooms = 0;
  bool _isLoading = false;
  List<int> _selectedRoomIds = [];
  final List<double> _columnWidths = [50.0, 300.0, 200.0, 200.0, 100.0];

  // Thêm biến trạng thái mới cho tìm kiếm người dùng
  String _searchUserQuery = '';

  // Thêm biến chứa khoảng giá tối đa và sức chứa tối đa
  final double _maxPriceValue = 5000000; // 5 triệu đồng
  final int _maxCapacityValue = 10; // 10 người

  // Thêm biến RangeValues để lưu giá trị slider - khởi tạo trong initState
  late RangeValues _priceRange;
  late RangeValues _capacityRange;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Khởi tạo giá trị mặc định cho các slider
    _priceRange = RangeValues(0, _maxPriceValue);
    _capacityRange = RangeValues(0, _maxCapacityValue.toDouble());
    
    _loadLocalData();
    context.read<AreaBloc>().add(FetchAreasEvent(page: 1, limit: 100));
    _fetchRoomsFromBackend();
  }

  // Tải dữ liệu từ local storage
  Future<void> _loadLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentPage = prefs.getInt('roomCurrentPage') ?? 1;
      _selectedAreaId = prefs.getInt('selectedAreaId');
      _searchQuery = prefs.getString('roomSearchQuery') ?? '';
      _searchUserQuery = prefs.getString('roomSearchUserQuery') ?? '';
      
      // Tải các bộ lọc giá và sức chứa
      _minPrice = prefs.getDouble('roomMinPrice');
      _maxPrice = prefs.getDouble('roomMaxPrice');
      _minCapacity = prefs.getInt('roomMinCapacity');
      _maxCapacity = prefs.getInt('roomMaxCapacity');
      
      // Cập nhật giá trị cho slider sau khi đã tải dữ liệu
      _priceRange = RangeValues(
        _minPrice ?? 0,
        _maxPrice ?? _maxPriceValue,
      );
      
      _capacityRange = RangeValues(
        (_minCapacity ?? 0).toDouble(),
        (_maxCapacity ?? _maxCapacityValue).toDouble(),
      );
    });
  }

  // Lưu trạng thái hiện tại vào local storage
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
    await prefs.setString('roomSearchUserQuery', _searchUserQuery); // Thêm mới
    
    // Lưu các bộ lọc giá và sức chứa
    if (_minPrice != null) await prefs.setDouble('roomMinPrice', _minPrice!);
    else await prefs.remove('roomMinPrice');
    
    if (_maxPrice != null) await prefs.setDouble('roomMaxPrice', _maxPrice!);
    else await prefs.remove('roomMaxPrice');
    
    if (_minCapacity != null) await prefs.setInt('roomMinCapacity', _minCapacity!);
    else await prefs.remove('roomMinCapacity');
    
    if (_maxCapacity != null) await prefs.setInt('roomMaxCapacity', _maxCapacity!);
    else await prefs.remove('roomMaxCapacity');
  }

  // Chuyển đổi trạng thái filter sang available cho API
  bool? _getAvailableFromStatus(String status) {
    switch (status) {
      case 'AVAILABLE':
        return true;
      case 'OCCUPIED':
        return false;
      default:
        return null; // Trạng thái khác không lọc theo available
    }
  }

  // Lấy dữ liệu từ backend với tất cả tham số lọc
  void _fetchRoomsFromBackend() {
    setState(() {
      _isLoading = true;
    });
    
    context.read<RoomBloc>().add(GetAllRoomsEvent(
      page: _currentPage,
      limit: _limit,
      areaId: _selectedAreaId,
      search: _searchQuery.isNotEmpty ? _searchQuery : null,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      minCapacity: _minCapacity,
      maxCapacity: _maxCapacity,
      searchUser: _searchUserQuery.isNotEmpty ? _searchUserQuery : null,
    ));
  }

  // Xử lý khi người dùng chọn/bỏ chọn phòng
  void _toggleSelection(int roomId) {
    setState(() {
      if (_selectedRoomIds.contains(roomId)) {
        _selectedRoomIds.remove(roomId);
      } else {
        _selectedRoomIds.add(roomId);
      }
    });
  }

  // Xóa các phòng đã chọn
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

  // Reset tất cả bộ lọc
  void _resetAllFilters() {
    setState(() {
      _currentPage = 1;
      _selectedAreaId = null;
      _searchQuery = '';
      _searchUserQuery = '';
      _minPrice = null;
      _maxPrice = null;
      _minCapacity = null;
      _maxCapacity = null;
      
      // Reset giá trị slider
      _priceRange = RangeValues(0, _maxPriceValue);
      _capacityRange = RangeValues(0, _maxCapacityValue.toDouble());
    });
    _saveLocalData();
    _fetchRoomsFromBackend();
  }

  // Thêm phương thức để định dạng giá tiền
  String _formatCurrency(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    } else {
      return value.toStringAsFixed(0);
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
                          _fetchRoomsFromBackend();
                        }
                      }
                    },
                  ),
                  BlocListener<RoomBloc, RoomState>(
                    listener: (context, state) {
                      if (state is RoomError) {
                        setState(() {
                          _isLoading = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${state.message}')),
                        );
                      } else if (state is RoomDeleted) {
                        // Tải lại dữ liệu sau khi xóa
                        _fetchRoomsFromBackend();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Xóa phòng thành công!'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else if (state is RoomLoaded) {
                        setState(() {
                          _rooms = state.rooms;
                          _totalRooms = state.totalItems;
                          _isLoading = false;
                        });
                        _saveLocalData();
                      } else if (state is ExportFileReady) {
                        try {
                          FileSaver.instance.saveFile(
                            name: state.filename,
                            bytes: state.fileBytes,
                            ext: 'xlsx',
                            mimeType: MimeType.microsoftExcel,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã tải xuống file Excel thành công!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Lỗi khi tải file: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
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
                                                    });
                                                    _saveLocalData();
                                                    _fetchRoomsFromBackend();
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
                                              });
                                            },
                                            onSearch: (value) {
                                              setState(() {
                                                _searchQuery = value;
                                                _currentPage = 1;
                                              });
                                              _saveLocalData();
                                              _fetchRoomsFromBackend();
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
                                        onPressed: _resetAllFilters,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.purple,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        icon: const Icon(Icons.filter_alt_off),
                                        label: const Text('Xóa bộ lọc'),
                                      ),
                                      const SizedBox(width: 10),
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
                                        onPressed: _fetchRoomsFromBackend,
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
                                          ).then((_) => _fetchRoomsFromBackend()); // Tải lại sau khi tạo phòng
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
                              // Có thể thêm bộ lọc nâng cao ở đây
                              ExpansionTile(
                                title: const Text('Bộ lọc nâng cao', 
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Tìm kiếm người dùng
                                        const Text('Tìm kiếm theo người dùng:', 
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 8),
                                        SearchBarTab(
                                          onChanged: (value) {
                                            setState(() {
                                              _searchUserQuery = value;
                                            });
                                          },
                                          onSearch: (value) {
                                            setState(() {
                                              _searchUserQuery = value;
                                              _currentPage = 1;
                                            });
                                            _saveLocalData();
                                            _fetchRoomsFromBackend();
                                          },
                                          hintText: 'Tìm kiếm theo tên, email, mã sinh viên...',
                                          initialValue: _searchUserQuery,
                                        ),
                                        const SizedBox(height: 16),
                                        
                                        // Lọc theo khoảng giá
                                        const Text('Khoảng giá:', style: TextStyle(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 8),
                                        Column(
                                          children: [
                                            SfRangeSlider(
                                              min: 0.0,
                                              max: _maxPriceValue,
                                              values: SfRangeValues(_priceRange.start, _priceRange.end),
                                              interval: 1000000,
                                              showLabels: true,
                                              enableTooltip: true,
                                              activeColor: Colors.deepPurple, // Màu thanh kéo đã chọn
                                              inactiveColor: Colors.deepPurple.shade100, // Màu nền thanh kéo
                          
                                              onChanged: (SfRangeValues values) {
                                                setState(() {
                                                  _priceRange = RangeValues(values.start, values.end);
                                                  _minPrice = values.start == 0 ? null : values.start;
                                                  _maxPrice = values.end == _maxPriceValue ? null : values.end;
                                                });
                                              },
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text('0 VNĐ', style: TextStyle(color: Colors.grey[600])),
                                                Text('${_formatCurrency(_priceRange.start)} VNĐ'),
                                                Text('-'),
                                                Text('${_formatCurrency(_priceRange.end)} VNĐ'),
                                                Text('${_formatCurrency(_maxPriceValue)} VNĐ', style: TextStyle(color: Colors.grey[600])),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 24),
                                        
                                        // Lọc theo sức chứa
                                        const Text('Sức chứa:', style: TextStyle(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 8),
                                        Column(
                                          children: [
                                            RangeSlider(
                                              values: _capacityRange,
                                              min: 0,
                                              max: _maxCapacityValue.toDouble(),
                                              divisions: _maxCapacityValue,
                                              labels: RangeLabels(
                                                '${_capacityRange.start.toInt()} người',
                                                '${_capacityRange.end.toInt()} người',
                                              ),
                                              activeColor: Colors.teal, // Màu thanh kéo đã chọn
                                              inactiveColor: Colors.teal.shade100, // Màu nền thanh kéo
                                              onChanged: (RangeValues values) {
                                                setState(() {
                                                  _capacityRange = values;
                                                  _minCapacity = values.start == 0 ? null : values.start.toInt();
                                                  _maxCapacity = values.end == _maxCapacityValue ? null : values.end.toInt();
                                                });
                                              },
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text('0 người', style: TextStyle(color: Colors.grey[600])),
                                                Text('${_capacityRange.start.toInt()} người'),
                                                Text('-'),
                                                Text('${_capacityRange.end.toInt()} người'),
                                                Text('$_maxCapacityValue người', style: TextStyle(color: Colors.grey[600])),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 24),
                                        
                                        // Nút áp dụng bộ lọc
                                        Center(
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              setState(() {
                                                _currentPage = 1;
                                              });
                                              _saveLocalData();
                                              _fetchRoomsFromBackend();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue,
                                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                            ),
                                            icon: const Icon(Icons.filter_list),
                                            label: const Text('Áp dụng bộ lọc'),
                                          ),
                                        ),
                                      ],
                                    ),
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
                              bool isLoading = state is RoomLoading || _isLoading;
                              String? errorMessage;

                              if (state is RoomError) {
                                errorMessage = state.message;
                              }

                              return isLoading
                                  ? const Center(child: CircularProgressIndicator())
                                  : errorMessage != null
                                      ? Center(child: Text('Lỗi: $errorMessage'))
                                      : _rooms.isEmpty
                                          ? const Center(child: Text('Không có phòng nào phù hợp với bộ lọc'))
                                          : Column(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        'Hiển thị $_limit phòng trên tổng số $_totalRooms phòng',
                                                        style: const TextStyle(fontStyle: FontStyle.italic),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                GenericDataTable<RoomEntity>(
                                                  headers: const [
                                                    '',
                                                    'Tên phòng',
                                                    'Số người / Sức chứa',
                                                    'Trạng thái',
                                                    '',
                                                  ],
                                                  data: _rooms,
                                                  columnWidths: _columnWidths,
                                                  cellBuilder: (room, index) {
                                                    return RoomListItem(
                                                      room: room,
                                                      isSelected: _selectedRoomIds.contains(room.roomId),
                                                      onToggleSelection: _toggleSelection,
                                                      columnIndex: index,
                                                      columnWidth: _columnWidths[index],
                                                    );
                                                  },
                                                ),
                                                PaginationControls(
                                                  currentPage: _currentPage,
                                                  totalItems: _totalRooms,
                                                  limit: _limit,
                                                  onPageChanged: (page) {
                                                    setState(() {
                                                      _currentPage = page;
                                                    });
                                                    _saveLocalData();
                                                    _fetchRoomsFromBackend();
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
}