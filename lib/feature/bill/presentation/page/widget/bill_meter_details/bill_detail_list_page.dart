import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:datn_web_admin/common/widget/search_bar.dart';
import 'package:datn_web_admin/common/widget/pagination_controls.dart';
import 'package:datn_web_admin/feature/bill/domain/entities/bill_detail_entity.dart';
import 'package:datn_web_admin/feature/bill/domain/entities/monthly_bill_entity.dart';
import 'package:datn_web_admin/feature/bill/presentation/bloc/bill_bloc.dart';
import 'package:datn_web_admin/feature/bill/presentation/bloc/bill_event.dart';
import 'package:datn_web_admin/feature/bill/presentation/bloc/bill_state.dart';
import 'package:datn_web_admin/feature/room/domain/entities/room_entity.dart';
import 'package:datn_web_admin/feature/service/presentation/bloc/service_bloc.dart';
import 'package:datn_web_admin/feature/service/presentation/bloc/service_event.dart';
import 'package:datn_web_admin/feature/service/presentation/bloc/service_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:month_year_picker/month_year_picker.dart';
import '../../../../../../common/constants/colors.dart';
import '../../../../../../common/widget/custom_data_table.dart';
import '../../../../../../common/widget/filterbox.dart';
import '../../../../../room/domain/entities/area_entity.dart';
import '../../../../../room/presentations/bloc/area_bloc/area_bloc.dart';
import '../../../../../room/presentations/bloc/area_bloc/area_event.dart';
import '../../../../../room/presentations/bloc/area_bloc/area_state.dart';
import '../../../../../room/presentations/bloc/room_bloc/room_bloc.dart';
import '../../../../../service/data/models/service_model.dart';
import '../../../../../service/domain/entities/service_entity.dart';

class BillDetailListPage extends StatefulWidget {
  const BillDetailListPage({Key? key}) : super(key: key);

  @override
  _BillDetailListPageState createState() => _BillDetailListPageState();
}

class _BillDetailListPageState extends State<BillDetailListPage>
    with AutomaticKeepAliveClientMixin {
  int _currentPage = 1;
  static const int _limit = 12;
  String _searchQuery = '';
  List<BillDetail> _billDetails = []; // Chỉ dùng 1 biến này
  List<BillDetail> _selectedBillDetails = [];
  List<MonthlyBill> _allMonthlyBills = [];
  bool _isInitialLoad = true;
  bool _selectAll = false;
  String _filterArea = 'All';
  String _filterSubmissionStatus = 'All';
  String _filterService = 'All';
  String _filterBillStatus = 'All';
  String _filterPaymentStatus = 'All';
  DateTime? _selectedMonthYear;
  List<AreaEntity> _areas = [];
  List<RoomEntity> _rooms = [];
  List<Service> _services = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _selectedMonthYear = DateTime.now();
    _loadAllLocalData();
    _fetchBillDetails(); 
  }

  Future<void> _loadAllLocalData() async {
    await Future.wait([
      _loadLocalData(),
      _loadAreasFromLocal(),
      _loadRoomsFromLocal(),
      _loadServicesFromLocal(),
    ]);
    // Không gọi _applyFilters() nữa
  }

  List<double> _getColumnWidths(double screenWidth) {
    final baseWidths = [40.0, 150.0, 150.0, 150.0, 120.0, 120.0, 150.0, 40.0];
    final totalBaseWidth = baseWidths.reduce((a, b) => a + b);
    final availableWidth = screenWidth - 32; // Trừ margin
    if (totalBaseWidth < availableWidth) {
      final scale = availableWidth / totalBaseWidth;
      return baseWidths.map((width) => width * scale).toList();
    } else if (totalBaseWidth > availableWidth) {
      final scale = availableWidth / totalBaseWidth;
      return baseWidths.map((width) => width * scale).toList();
    }
    return baseWidths;
  }

  Future<void> _loadLocalData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _currentPage = prefs.getInt('billDetailCurrentPage') ?? 1;
      _searchQuery = prefs.getString('billDetailSearchQuery') ?? '';
      _filterArea = prefs.getString('billDetailFilterArea') ?? 'All';
      _filterSubmissionStatus =
          prefs.getString('billDetailFilterSubmissionStatus') ?? 'All';
      _filterService = prefs.getString('billDetailFilterService') ?? 'All';
      _filterBillStatus = prefs.getString('billDetailFilterBillStatus') ?? 'All';
      _filterPaymentStatus =
          prefs.getString('billDetailFilterPaymentStatus') ?? 'All';
      // Không load billDetails từ local nữa, luôn fetch từ BE
      String? monthlyBillsJson = prefs.getString('monthlyBills');
      if (monthlyBillsJson != null) {
        try {
          List<dynamic> monthlyBillsList = jsonDecode(monthlyBillsJson);
          setState(() {
            _allMonthlyBills =
                monthlyBillsList.map((json) => MonthlyBill.fromJson(json)).toList();
          });
        } catch (e) {
          await prefs.remove('monthlyBills');
          _fetchMonthlyBills();
        }
      }
    } catch (e) {
      print('Error in _loadLocalData: $e');
    }
  }

  Future<void> _loadAreasFromLocal() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? areasJson = prefs.getString('areas');
      if (areasJson != null) {
        try {
          List<dynamic> areasList = jsonDecode(areasJson);
          setState(() {
            _areas = areasList.map((json) => AreaEntity.fromJson(json)).toList();
          });
          print('Loaded areas from local: ${_areas.length}');
        } catch (e) {
          print('Error loading local areas: $e');
          await prefs.remove('areas');
        }
      }
      _fetchAreas();
    } catch (e) {
      print('Error in _loadAreasFromLocal: $e');
    }
  }

  Future<void> _loadRoomsFromLocal() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? roomsJson = prefs.getString('rooms');
      if (roomsJson != null) {
        try {
          List<dynamic> roomsList = jsonDecode(roomsJson);
          setState(() {
            _rooms = roomsList.map((json) => RoomEntity.fromJson(json)).toList();
          });
          print('Loaded rooms from local: ${_rooms.length}');
        } catch (e) {
          print('Error loading local rooms: $e');
          await prefs.remove('rooms');
        }
      }
      _fetchRooms();
    } catch (e) {
      print('Error in _loadRoomsFromLocal: $e');
    }
  }

  Future<void> _loadServicesFromLocal() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? servicesJson = prefs.getString('services');
      if (servicesJson != null) {
        try {
          List<dynamic> servicesList = jsonDecode(servicesJson);
          setState(() {
            _services = servicesList
                .map((json) => ServiceModel.fromJson(json).toEntity())
                .toList();
          });
          print('Loaded services from local: ${_services.length}');
        } catch (e) {
          print('Error loading local services: $e');
          await prefs.remove('services');
        }
      }
      _fetchServices();
    } catch (e) {
      print('Error in _loadServicesFromLocal: $e');
    }
  }

  Future<void> _saveLocalData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('billDetailCurrentPage', _currentPage);
      await prefs.setString('billDetailSearchQuery', _searchQuery);
      await prefs.setString('billDetailFilterArea', _filterArea);
      await prefs.setString(
          'billDetailFilterSubmissionStatus', _filterSubmissionStatus);
      await prefs.setString('billDetailFilterService', _filterService);
      await prefs.setString('billDetailFilterBillStatus', _filterBillStatus);
      await prefs.setString('billDetailFilterPaymentStatus', _filterPaymentStatus);
      await prefs.setString(
          'monthlyBills',
          jsonEncode(_allMonthlyBills.map((bill) => bill.toJson()).toList()));
    } catch (e) {
      print('Error saving local data: $e');
    }
  }

  void _fetchBillDetails() {
    context.read<BillBloc>().add(FetchAllBillDetails(
      page: _currentPage,
      limit: _limit,
      area: _filterArea == 'All' ? null : _filterArea,
      service: _filterService == 'All' ? null : _filterService,
      search: _searchQuery.isEmpty ? null : _searchQuery,
      month: _selectedMonthYear != null ? DateFormat('yyyy-MM').format(_selectedMonthYear!) : null,
      submissionStatus: _filterSubmissionStatus == 'All' ? null : _filterSubmissionStatus,
      paymentStatus: _filterPaymentStatus == 'All' ? null : _filterPaymentStatus,
    ));
  }

  void _fetchMonthlyBills() {
    print('Fetching monthly bills...');
    context
        .read<BillBloc>()
        .add(const FetchAllMonthlyBills(page: 1, limit: 1000));
  }

  void _fetchAreas() {
    print('Fetching areas...');
    context.read<AreaBloc>().add(FetchAreasEvent(page: 1, limit: 1000));
  }

  void _fetchServices() {
    print('Fetching services...');
    context.read<ServiceBloc>().add(FetchServices(page: 1, limit: 1000));
  }

  void _fetchRooms() {
    print('Fetching rooms...');
    context.read<RoomBloc>().add(GetAllRoomsEvent(page: 1, limit: 1000));
  }

  void _toggleSelection(BillDetail detail) {
    setState(() {
      if (_selectedBillDetails.contains(detail)) {
        _selectedBillDetails.remove(detail);
      } else {
        _selectedBillDetails.add(detail);
      }
    });
  }

  void _toggleSelectAll() {
    setState(() {
      _selectAll = !_selectAll;
      if (_selectAll) {
        _selectedBillDetails = _billDetails
            .where((detail) =>
                detail.submittedBy != null &&
                (detail.monthlyBillId == null || detail.monthlyBillId == -1))
            .toList();
      } else {
        _selectedBillDetails.clear();
      }
    });
  }

  void _createMonthlyBills() {
    if (_selectedBillDetails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất một chỉ số đã gửi về để tạo hóa đơn'),
          backgroundColor: AppColors.buttonError,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_selectedMonthYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn tháng hóa đơn trước khi tạo'),
          backgroundColor: AppColors.buttonError,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    List<int> roomIds = _selectedBillDetails
        .map((detail) => detail.roomId)
        .whereType<int>()
        .toSet()
        .toList();

    context.read<BillBloc>().add(CreateMonthlyBillsBulk(
          billMonth: _selectedMonthYear!,
          roomIds: roomIds,
        ));

    setState(() {
      _selectedBillDetails.clear();
      _selectAll = false;
    });
  }

  void _deleteBillDetail(int detailId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa chi tiết hóa đơn này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<BillBloc>().add(DeleteBillDetailEvent(detailId));
            },
            child: const Text('Xóa', style: TextStyle(color: AppColors.buttonError)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    List<String> uniqueAreas = ['All'];
    Set<String> seenAreas = {};
    for (var area in _areas) {
      if (!seenAreas.contains(area.name)) {
        seenAreas.add(area.name);
        uniqueAreas.add(area.name);
      }
    }
    uniqueAreas.sort();

    List<String> submissionStatuses = ['All', 'SUBMITTED', 'NOT_SUBMITTED'];
    List<String> billStatuses = ['All', 'CREATED', 'NOT_CREATED'];
    List<String> paymentStatuses = ['All', 'PAID', 'NOT_PAID'];
    List<String> uniqueServices = ['All'];
    for (var service in _services) {
      uniqueServices.add(service.name);
    }
    uniqueServices.sort();

    if (_filterArea != 'All' && !uniqueAreas.contains(_filterArea)) {
      _filterArea = 'All';
    }
    if (_filterSubmissionStatus != 'All' &&
        !submissionStatuses.contains(_filterSubmissionStatus)) {
      _filterSubmissionStatus = 'All';
    }
    if (_filterService != 'All' && !uniqueServices.contains(_filterService)) {
      _filterService = 'All';
    }
    if (_filterBillStatus != 'All' && !billStatuses.contains(_filterBillStatus)) {
      _filterBillStatus = 'All';
    }
    if (_filterPaymentStatus != 'All' &&
        !paymentStatuses.contains(_filterPaymentStatus)) {
      _filterPaymentStatus = 'All';
    }

    return MultiBlocListener(
      listeners: [
        BlocListener<BillBloc, BillState>(
          listener: (context, state) {
            print('BillBloc state: $state');
            if (state is BillError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Lỗi: ${state.message}')),
              );
            } else if (state is BillDetailsLoaded) {
              setState(() {
                _isInitialLoad = false;
                _billDetails = state.billDetails;

                // Lọc theo trạng thái hóa đơn ở FE
                if (_filterBillStatus == 'CREATED') {
                  _billDetails = _billDetails
                      .where((d) => d.monthlyBillId != null && d.monthlyBillId != -1)
                      .toList();
                } else if (_filterBillStatus == 'NOT_CREATED') {
                  _billDetails = _billDetails
                      .where((d) => d.monthlyBillId == null || d.monthlyBillId == -1)
                      .toList();
                }
              });
              _saveLocalData();
            } else if (state is MonthlyBillsLoaded) {
              setState(() {
                _allMonthlyBills = state.monthlyBills;
              });
              _saveLocalData();
              print('Monthly bills loaded: ${_allMonthlyBills.length}');
            } else if (state is MonthlyBillsCreated) {
              String message = state.billsCreated.isNotEmpty
                  ? 'Hóa đơn được tạo thành công '
                  : 'Không có hóa đơn nào được tạo';
              if (state.errors.isNotEmpty) {
                message += '\nLỗi:';
                for (var error in state.errors) {
                  message += '\n- Phòng ${error['room_id']}: ${error['error']}';
                }
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: state.billsCreated.isNotEmpty
                      ? AppColors.buttonSuccess
                      : AppColors.buttonError,
                  duration: const Duration(seconds: 5),
                ),
              );
              _fetchBillDetails();
              _fetchMonthlyBills();
            } else if (state is BillDetailDeleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.buttonSuccess,
                  duration: const Duration(seconds: 3),
                ),
              );
              _fetchBillDetails();
            }
          },
        ),
        BlocListener<AreaBloc, AreaState>(
          listener: (context, state) {
            print('AreaBloc state: $state');
            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Lỗi khi lấy danh sách khu: ${state.error!}'),
                    backgroundColor: AppColors.buttonError),
              );
            } else {
              setState(() {
                _areas = state.areas;
              });
              _saveLocalData();
              print('Areas loaded: ${_areas.length}');
            }
          },
        ),
        BlocListener<RoomBloc, RoomState>(
          listener: (context, state) {
            print('RoomBloc state: $state');
            if (state is RoomError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Lỗi khi lấy danh sách phòng: ${state.message}'),
                    backgroundColor: AppColors.buttonError),
              );
            } else if (state is RoomLoaded) {
              setState(() {
                _rooms = state.rooms;
              });
              _saveLocalData();
              print('Rooms loaded: ${_rooms.length}');
            }
          },
        ),
        BlocListener<ServiceBloc, ServiceState>(
          listener: (context, state) {
            print('ServiceBloc state: $state');
            if (state is ServiceError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text('Lỗi khi lấy danh sách dịch vụ: ${state.message}'),
                    backgroundColor: AppColors.buttonError),
              );
            } else if (state is ServicesLoaded) {
              setState(() {
                _services = state.services;
              });
              _saveLocalData();
              print('Services loaded: ${_services.length}');
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.cardBackground,
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.glassmorphismStart,
                    AppColors.glassmorphismEnd
                  ],
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double paddingHorizontal = 8.0;
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: paddingHorizontal, vertical: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FilterBox(
                                  filters: [
                                    Row(
                                      children: [
                                        const Text(
                                          'Khu vực:',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: AppColors.borderColor),
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            child: DropdownButton<String>(
                                              hint: const Text('Tất cả khu vực'),
                                              value: _filterArea,
                                              isExpanded: true,
                                              underline: const SizedBox(),
                                              items: uniqueAreas
                                                  .map((area) =>
                                                      DropdownMenuItem<String>(
                                                        value: area,
                                                        child: Text(area == 'All' ? 'Tất cả' : area),
                                                      ))
                                                  .toList(),
                                              onChanged: (value) {
                                                setState(() {
                                                  _filterArea = value ?? 'All';
                                                  _currentPage = 1;
                                                  _saveLocalData();
                                                });
                                                _fetchBillDetails(); // Gọi lại BE
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Text(
                                          'Trạng thái gửi:',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: AppColors.borderColor),
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            child: DropdownButton<String>(
                                              hint: const Text('Tất cả trạng thái'),
                                              value: _filterSubmissionStatus,
                                              isExpanded: true,
                                              underline: const SizedBox(),
                                              items: submissionStatuses
                                                  .map((status) =>
                                                      DropdownMenuItem<String>(
                                                        value: status,
                                                        child: Text(
                                                          status == 'SUBMITTED'
                                                              ? 'Đã gửi về'
                                                              : status == 'NOT_SUBMITTED'
                                                                  ? 'Chưa gửi về'
                                                                  : 'Tất cả',
                                                        ),
                                                      ))
                                                  .toList(),
                                              onChanged: (value) {
                                                setState(() {
                                                  _filterSubmissionStatus =
                                                      value ?? 'All';
                                                  _currentPage = 1;
                                                  _saveLocalData();
                                                });
                                                _fetchBillDetails(); // Gọi lại BE
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Text(
                                          'Dịch vụ:',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: AppColors.borderColor),
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            child: DropdownButton<String>(
                                              hint: const Text('Tất cả dịch vụ'),
                                              value: _filterService,
                                              isExpanded: true,
                                              underline: const SizedBox(),
                                              items: uniqueServices
                                                  .map((service) =>
                                                      DropdownMenuItem<String>(
                                                        value: service,
                                                        child: Text(
                                                            service == 'All'
                                                                ? 'Tất cả'
                                                                : service),
                                                      ))
                                                  .toList(),
                                              onChanged: (value) {
                                                setState(() {
                                                  _filterService = value ?? 'All';
                                                  _currentPage = 1;
                                                  _saveLocalData();
                                                });
                                                _fetchBillDetails(); // Gọi lại BE
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Text(
                                          'Tháng hóa đơn:',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () async {
                                              DateTime? pickedDate = await showMonthYearPicker(
                                                context: context,
                                                initialDate: _selectedMonthYear ?? DateTime.now(),
                                                firstDate: DateTime(2000),
                                                lastDate: DateTime(2100),
                                              );
                                              if (pickedDate != null) {
                                                setState(() {
                                                  _selectedMonthYear = pickedDate;
                                                  _currentPage = 1;
                                                  _saveLocalData();
                                                });
                                                _fetchBillDetails();
                                              }
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8.0,
                                                  vertical: 12.0),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: AppColors.borderColor),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              child: Text(
                                                _selectedMonthYear != null
                                                    ? DateFormat('MM/yyyy')
                                                        .format(_selectedMonthYear!)
                                                    : 'Chọn tháng',
                                                style: TextStyle(
                                                  color: _selectedMonthYear != null
                                                      ? AppColors.textPrimary
                                                      : AppColors.textSecondary,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Text(
                                          'Trạng thái hóa đơn:',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: AppColors.borderColor),
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            child: DropdownButton<String>(
                                              hint: const Text('Tất cả trạng thái'),
                                              value: _filterBillStatus,
                                              isExpanded: true,
                                              underline: const SizedBox(),
                                              items: billStatuses
                                                  .map((status) =>
                                                      DropdownMenuItem<String>(
                                                        value: status,
                                                        child: Text(
                                                          status == 'CREATED'
                                                              ? 'Đã tạo hóa đơn'
                                                              : status == 'NOT_CREATED'
                                                                  ? 'Chưa tạo hóa đơn'
                                                                  : 'Tất cả',
                                                        ),
                                                      ))
                                                  .toList(),
                                              onChanged: (value) {
                                                setState(() {
                                                  _filterBillStatus = value ?? 'All';
                                                  _currentPage = 1;
                                                  _saveLocalData();
                                                });
                                                _fetchBillDetails(); // Gọi lại BE
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Text(
                                          'Trạng thái thanh toán:',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: AppColors.borderColor),
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            child: DropdownButton<String>(
                                              hint: const Text('Tất cả trạng thái'),
                                              value: _filterPaymentStatus,
                                              isExpanded: true,
                                              underline: const SizedBox(),
                                              items: paymentStatuses
                                                  .map((status) =>
                                                      DropdownMenuItem<String>(
                                                        value: status,
                                                        child: Text(
                                                          status == 'PAID'
                                                              ? 'Đã thanh toán'
                                                              : status == 'NOT_PAID'
                                                                  ? 'Chưa thanh toán'
                                                                  : 'Tất cả',
                                                        ),
                                                      ))
                                                  .toList(),
                                              onChanged: (value) {
                                                setState(() {
                                                  _filterPaymentStatus =
                                                      value ?? 'All';
                                                  _currentPage = 1;
                                                  _saveLocalData();
                                                });
                                                _fetchBillDetails(); // Gọi lại BE
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: SearchBarTab(
                                          onChanged: (value) {
                                            setState(() {
                                              _searchQuery = value;
                                              _currentPage = 1;
                                              _saveLocalData();
                                            });
                                            _fetchBillDetails(); // Gọi lại BE
                                          },
                                          hintText: 'Tìm kiếm theo tên phòng...',
                                          initialValue: _searchQuery,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        _fetchBillDetails();
                                        _fetchMonthlyBills();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.buttonSuccess,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      icon: const Icon(Icons.refresh,
                                          color: AppColors.cardBackground),
                                      label: const Text('Làm mới',
                                          style: TextStyle(
                                              color: AppColors.cardBackground)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: _createMonthlyBills,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      icon: const Icon(Icons.add,
                                          color: AppColors.cardBackground),
                                      label: const Text('Tạo Hóa Đơn Hàng Tháng',
                                          style: TextStyle(
                                              color: AppColors.cardBackground)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height - 200,
                            child: SingleChildScrollView(
                              child: BlocBuilder<BillBloc, BillState>(
                                builder: (context, state) {
                                  print('Rendering table with state: $state');
                                  if (state is BillLoading && _isInitialLoad) {
                                    return const Center(
                                      child: CircularProgressIndicator(color: AppColors.primaryColor),
                                    );
                                  }

                                  if (state is BillError) {
                                    return Center(
                                      child: Text(
                                        'Lỗi: ${state.message}',
                                        style: const TextStyle(color: AppColors.buttonError, fontSize: 18),
                                      ),
                                    );
                                  }

                                  if (state is BillDetailsLoaded) {
                                    // _billDetails đã được cập nhật ở BlocListener, chỉ cần render
                                    return GenericDataTable<BillDetail>(
                                      data: _billDetails,
                                      headers: const [
                                        '',
                                        'Khu',
                                        'Phòng',
                                        'Người gửi',
                                        'Chỉ số hiện tại',
                                        'Tháng hóa đơn',
                                        'Ngày gửi',
                                        '',
                                      ],
                                      columnWidths: _getColumnWidths(MediaQuery.of(context).size.width),
                                      cellBuilder: (detail, index) {
                                        bool isCreatedAndPaid = false;
                                        if (detail.monthlyBillId != null &&
                                            detail.monthlyBillId != -1) {
                                          MonthlyBill? monthlyBill =
                                              _allMonthlyBills.firstWhere(
                                            (bill) =>
                                                bill.detailId == detail.detailId,
                                            orElse: () => MonthlyBill(
                                              billId: -1,
                                              userId: -1,
                                              detailId: -1,
                                              roomId: -1,
                                              billMonth: DateTime.now(),
                                              totalAmount: 0.0,
                                              paymentStatus: 'PENDING',
                                              createdAt: DateTime.now(),
                                              paymentMethodAllowed: '',
                                              paidAt: null,
                                              transactionReference: null,
                                              userDetails: null,
                                              roomDetails: null,
                                              billDetailId: -1,
                                            ),
                                          );
                                          isCreatedAndPaid =
                                              monthlyBill.paymentStatus == 'PAID';
                                        }

                                        switch (index) {
                                          case 0:
                                            return Checkbox(
                                              value: _selectedBillDetails
                                                  .contains(detail),
                                              onChanged: detail.submittedBy !=
                                                          null &&
                                                      (detail.monthlyBillId ==
                                                              null ||
                                                          detail.monthlyBillId ==
                                                              -1)
                                                  ? (value) {
                                                      _toggleSelection(detail);
                                                    }
                                                  : null,
                                            );
                                          case 1:
                                            String areaName = 'N/A';
                                            RoomEntity? room;
                                            for (var r in _rooms) {
                                              if (r.roomId == detail.roomId) {
                                                room = r;
                                                break;
                                              }
                                            }
                                            if (room != null) {
                                              for (var area in _areas) {
                                                if (area.areaId == room.areaId) {
                                                  areaName = area.name;
                                                  break;
                                                }
                                              }
                                            }
                                            return Text(
                                              areaName,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  color: AppColors.textPrimary),
                                            );
                                          case 2:
                                            return Text(
                                              detail.roomName ?? 'N/A',
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  color: AppColors.textPrimary),
                                            );
                                          case 3:
                                            return Text(
                                              detail.submittedBy != null
                                                  ? (detail.submitterDetails
                                                          ?.fullname ??
                                                      'N/A')
                                                  : 'N/A',
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  color: AppColors.textPrimary),
                                            );
                                          case 4:
                                            return Text(
                                              detail.submittedBy != null
                                                  ? detail.currentReading
                                                      ?.toStringAsFixed(2) ?? 'N/A'
                                                  : 'N/A',
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  color: AppColors.textPrimary),
                                            );
                                          case 5:
                                            return Text(
                                              DateFormat('MM/yyyy')
                                                  .format(detail.billMonth),
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  color: AppColors.textPrimary),
                                            );
                                          case 6:
                                            return Text(
                                              detail.submittedAt != null
                                                  ? DateFormat('dd-MM-yyyy')
                                                      .format(detail.submittedAt!)
                                                  : 'Chưa gửi',
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  color: AppColors.textPrimary),
                                            );
                                          case 7:
                                            return detail.detailId != -1 &&
                                                    !isCreatedAndPaid
                                                ? IconButton(
                                                    icon: const Icon(
                                                        Icons.delete,
                                                        color:
                                                            AppColors.buttonError),
                                                    onPressed: () {
                                                      if (detail.detailId != null) {
                                                        _deleteBillDetail(
                                                            detail.detailId!);
                                                      }
                                                    },
                                                  )
                                                : const SizedBox();
                                          default:
                                            return const SizedBox();
                                        }
                                      },
                                    );
                                  }

                                  // Trường hợp chưa có dữ liệu hoặc state khác
                                  return const Center(
                                    child: Text('Không có dữ liệu', style: TextStyle(color: AppColors.textSecondary)),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}