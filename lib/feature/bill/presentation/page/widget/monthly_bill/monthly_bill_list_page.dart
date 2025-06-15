import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:datn_web_admin/common/widget/search_bar.dart';
import 'package:datn_web_admin/common/widget/pagination_controls.dart';
import 'package:datn_web_admin/feature/bill/data/models/monthly_bill_model.dart';
import 'package:datn_web_admin/feature/bill/domain/entities/bill_detail_entity.dart';
import 'package:datn_web_admin/feature/bill/domain/entities/monthly_bill_entity.dart';
import 'package:datn_web_admin/feature/bill/presentation/bloc/bill_bloc.dart';
import 'package:datn_web_admin/feature/bill/presentation/bloc/bill_event.dart';
import 'package:datn_web_admin/feature/room/domain/entities/area_entity.dart';
import 'package:datn_web_admin/feature/room/domain/entities/room_entity.dart';
import 'package:datn_web_admin/feature/room/presentations/bloc/area_bloc/area_bloc.dart';
import 'package:datn_web_admin/feature/room/presentations/bloc/area_bloc/area_event.dart';
import 'package:datn_web_admin/feature/room/presentations/bloc/area_bloc/area_state.dart';
import 'package:datn_web_admin/feature/room/presentations/bloc/room_bloc/room_bloc.dart';
import 'package:datn_web_admin/feature/bill/presentation/page/widget/monthly_bill/monthly_bill_detail_dialog.dart';
import 'package:datn_web_admin/feature/service/data/models/service_model.dart';
import 'package:datn_web_admin/feature/service/domain/entities/service_entity.dart';
import 'package:datn_web_admin/feature/service/presentation/bloc/service_bloc.dart';
import 'package:datn_web_admin/feature/service/presentation/bloc/service_event.dart';
import 'package:datn_web_admin/feature/service/presentation/bloc/service_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:ui';

import '../../../../../../common/constants/colors.dart';
import '../../../../../../common/widget/custom_data_table.dart';
import '../../../bloc/bill_state.dart';

class BillListPage extends StatefulWidget {
  const BillListPage({Key? key}) : super(key: key);

  @override
  _BillListPageState createState() => _BillListPageState();
}

class _BillListPageState extends State<BillListPage> with AutomaticKeepAliveClientMixin {
  int _currentPage = 1;
  static const int _limit = 12;
  String _searchQuery = '';
  List<MonthlyBillModel> _allBillModels = [];
  List<BillDetail> _allBillDetails = [];
  List<MonthlyBill> _bills = [];
  List<ServiceModel> _services = [];
  List<AreaEntity> _areas = [];
  List<RoomEntity> _rooms = [];
  bool _isInitialLoad = true;
  String _filterStatus = 'All';
  String _filterArea = 'All';
  String _filterService = 'All';
  String _filterMonthYear = 'All';
  String _filterBillStatus = 'All';
  DateTime? _selectedMonthYear;
  final List<double> _columnWidths = [150.0, 120.0, 120.0, 120.0, 120.0, 40.0, 40.0];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _selectedMonthYear = DateTime.now();
    _loadLocalData();
    _fetchBills();
    _fetchBillDetails();
    _fetchServices();
    _fetchAreas();
    _fetchRooms();
  }

  Future<void> _loadLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _currentPage = prefs.getInt('billCurrentPage') ?? 1;
    _searchQuery = prefs.getString('billSearchQuery') ?? '';
    _filterStatus = prefs.getString('billFilterStatus') ?? 'All';
    _filterArea = prefs.getString('billFilterArea') ?? 'All';
    _filterService = prefs.getString('billFilterService') ?? 'All';
    _filterMonthYear = prefs.getString('billFilterMonthYear') ?? 'All';
    _filterBillStatus = prefs.getString('billFilterBillStatus') ?? 'All';
    String? billsJson = prefs.getString('bills');
    String? billDetailsJson = prefs.getString('billDetails');
    String? servicesJson = prefs.getString('services');
    String? areasJson = prefs.getString('areas');
    String? roomsJson = prefs.getString('rooms');
    if (billsJson != null) {
      try {
        List<dynamic> billsList = jsonDecode(billsJson);
        setState(() {
          _allBillModels = billsList.map((json) => MonthlyBillModel.fromJson(json)).toList();
          _bills = _allBillModels.map((model) => model.toEntity()).toList();
          _applyFilters();
        });
      } catch (e) {
        print('Error loading local bills: $e');
        await prefs.remove('bills');
        _fetchBills();
      }
    }
    if (billDetailsJson != null) {
      try {
        List<dynamic> billDetailsList = jsonDecode(billDetailsJson);
        setState(() {
          _allBillDetails = billDetailsList.map((json) => BillDetail.fromJson(json)).toList();
        });
      } catch (e) {
        print('Error loading local bill details: $e');
        await prefs.remove('billDetails');
        _fetchBillDetails();
      }
    }
    if (servicesJson != null) {
      try {
        List<dynamic> servicesList = jsonDecode(servicesJson);
        setState(() {
          _services = servicesList.map((json) => ServiceModel.fromJson(json)).toList();
        });
      } catch (e) {
        print('Error loading local services: $e');
        await prefs.remove('services');
        _fetchServices();
      }
    }
    if (areasJson != null) {
      try {
        List<dynamic> areasList = jsonDecode(areasJson);
        setState(() {
          _areas = areasList.map((json) => AreaEntity.fromJson(json)).toList();
        });
      } catch (e) {
        print('Error loading local areas: $e');
        await prefs.remove('areas');
        _fetchAreas();
      }
    }
    if (roomsJson != null) {
      try {
        List<dynamic> roomsList = jsonDecode(roomsJson);
        setState(() {
          _rooms = roomsList.map((json) => RoomEntity.fromJson(json)).toList();
        });
      } catch (e) {
        print('Error loading local rooms: $e');
        await prefs.remove('rooms');
        _fetchRooms();
      }
    }
  }

  Future<void> _saveLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('billCurrentPage', _currentPage);
    await prefs.setString('billSearchQuery', _searchQuery);
    await prefs.setString('billFilterStatus', _filterStatus);
    await prefs.setString('billFilterArea', _filterArea);
    await prefs.setString('billFilterService', _filterService);
    await prefs.setString('billFilterMonthYear', _filterMonthYear);
    await prefs.setString('billFilterBillStatus', _filterBillStatus);
    await prefs.setString('bills', jsonEncode(_allBillModels.map((billModel) => billModel.toJson()).toList()));
    await prefs.setString('billDetails', jsonEncode(_allBillDetails.map((detail) => detail.toJson()).toList()));
    await prefs.setString('services', jsonEncode(_services.map((service) => service.toJson()).toList()));
    await prefs.setString('areas', jsonEncode(_areas.map((area) => area.toJson()).toList()));
    await prefs.setString('rooms', jsonEncode(_rooms.map((room) => room.toJson()).toList()));
  }

  void _fetchBills() {
    context.read<BillBloc>().add(const FetchAllMonthlyBills(page: 1, limit: 1000));
  }

  void _fetchBillDetails() {
    context.read<BillBloc>().add(const FetchAllBillDetails(page: 1, limit: 1000));
  }

  void _fetchServices() {
    context.read<ServiceBloc>().add(const FetchServices(page: 1, limit: 1000));
  }

  void _fetchAreas() {
    context.read<AreaBloc>().add(FetchAreasEvent(page: 1, limit: 1000));
  }

  void _fetchRooms() {
    context.read<RoomBloc>().add(GetAllRoomsEvent(page: 1, limit: 1000));
  }

  void _applyFilters() {
    setState(() {
      _bills = _allBillModels.where((billModel) {
        final bill = billModel.toEntity();

        BillDetail? billDetail;
        if (bill.detailId != null) {
          billDetail = _allBillDetails.firstWhere(
                (detail) => detail.detailId == bill.detailId,
            orElse: () => BillDetail(
              detailId: -1,
              roomId: bill.roomId,
              billMonth: bill.billMonth,
              price: 0.0,
              submittedBy: null,
              submittedAt: null,
              submitterDetails: null,
              rateDetails: null,
              rateId: -1,
              monthlyBillId: -1,
              previousReading: 0.0,
              currentReading: 0.0,
            ),
          );
        }

        int? serviceId = billDetail?.rateDetails?.serviceId;
        String serviceName = 'N/A';
        if (serviceId != null) {
          var service = _services.firstWhere(
                (s) => s.serviceId == serviceId,
            orElse: () => ServiceModel(
              serviceId: -1,
              name: 'Không xác định',
              unit: '',
            ),
          );
          serviceName = service.name;
        }

        bool matchesArea = true;
        if (_filterArea != 'All') {
          RoomEntity? room;
          for (var r in _rooms) {
            if (r.roomId == bill.roomId) {
              room = r;
              break;
            }
          }
          if (room != null) {
            for (var area in _areas) {
              if (area.areaId == room.areaId && area.name == _filterArea) {
                matchesArea = true;
                break;
              }
              matchesArea = false;
            }
          } else {
            matchesArea = false;
          }
        }

        bool matchesStatus = true;
        if (_filterStatus != 'All') {
          matchesStatus = bill.paymentStatus == _filterStatus;
        }

        bool matchesService = true;
        if (_filterService != 'All') {
          matchesService = serviceName == _filterService;
        }

        bool matchesMonthYear = true;
        if (_filterMonthYear != 'All' && _selectedMonthYear != null) {
          final monthYear = DateFormat('MM/yyyy').format(bill.billMonth);
          final selectedMonthYear = DateFormat('MM/yyyy').format(_selectedMonthYear!);
          matchesMonthYear = monthYear == selectedMonthYear;
        }

        bool matchesBillStatus = true;
        if (_filterBillStatus != 'All') {
          bool isCreated = billDetail?.monthlyBillId != null && billDetail?.monthlyBillId != -1;
          if (_filterBillStatus == 'CREATED') {
            matchesBillStatus = isCreated;
          } else if (_filterBillStatus == 'NOT_CREATED') {
            matchesBillStatus = !isCreated;
          }
        }

        bool matchesSearch = _searchQuery.isEmpty ||
            (bill.roomDetails?.name.toLowerCase() ?? '').contains(_searchQuery.toLowerCase());
        return matchesStatus && matchesArea && matchesService && matchesMonthYear && matchesBillStatus && matchesSearch;
      }).map((model) => model.toEntity()).toList();

      // Sort bills: PENDING first when _filterStatus is 'All', then by createdAt descending
      _bills.sort((a, b) {
        if (_filterStatus == 'All') {
          if (a.paymentStatus == 'PENDING' && b.paymentStatus != 'PENDING') {
            return -1;
          } else if (a.paymentStatus != 'PENDING' && b.paymentStatus == 'PENDING') {
            return 1;
          }
        }
        return b.createdAt.compareTo(a.createdAt);
      });
    });
  }

  void _deleteMonthlyBill(int billId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa hóa đơn này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<BillBloc>().add(DeleteMonthlyBillEvent(billId));
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

    List<String> uniqueStatuses = ['All', 'PENDING', 'PAID'];
    List<String> uniqueAreas = ['All'];
    List<String> uniqueServices = ['All'];
    List<String> billStatuses = ['All', 'CREATED', 'NOT_CREATED'];

    if (_allBillModels.isNotEmpty) {
      print('Danh sách trạng thái của các hóa đơn:');
      for (var bill in _allBillModels) {
        print('Hóa đơn ID: ${bill.billId}, Trạng thái: ${bill.paymentStatus}');
      }
    }

    Set<String> seenAreas = {};
    for (var area in _areas) {
      if (!seenAreas.contains(area.name)) {
        seenAreas.add(area.name);
        uniqueAreas.add(area.name);
      }
    }
    uniqueAreas.sort();

    Set<String> seenServices = {};
    for (var billModel in _allBillModels) {
      if (billModel.detailId != null) {
        var billDetail = _allBillDetails.firstWhere(
              (detail) => detail.detailId == billModel.detailId,
          orElse: () => BillDetail(
            detailId: -1,
            roomId: billModel.roomId,
            billMonth: billModel.billMonth,
            price: 0.0,
            submittedBy: null,
            submittedAt: null,
            submitterDetails: null,
            rateDetails: null,
            rateId: -1,
            monthlyBillId: -1,
            previousReading: 0.0,
            currentReading: 0.0,
          ),
        );
        int? serviceId = billDetail.rateDetails?.serviceId;
        if (serviceId != null) {
          var service = _services.firstWhere(
                (s) => s.serviceId == serviceId,
            orElse: () => ServiceModel(
              serviceId: -1,
              name: 'Không xác định',
              unit: '',
            ),
          );
          if (!seenServices.contains(service.name) && service.name != 'Không xác định') {
            seenServices.add(service.name);
            uniqueServices.add(service.name);
          }
        }
      }
    }
    uniqueServices.sort();

    if (_filterStatus != 'All' && !uniqueStatuses.contains(_filterStatus)) {
      _filterStatus = 'All';
    }
    if (_filterArea != 'All' && !uniqueAreas.contains(_filterArea)) {
      _filterArea = 'All';
    }
    if (_filterService != 'All' && !uniqueServices.contains(_filterService)) {
      _filterService = 'All';
    }
    if (_filterBillStatus != 'All' && !billStatuses.contains(_filterBillStatus)) {
      _filterBillStatus = 'All';
    }

    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: Stack(
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
          MultiBlocListener(
            listeners: [
              BlocListener<BillBloc, BillState>(
                listener: (context, state) {
                  if (state is BillError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.buttonError,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  } else if (state is MonthlyBillsLoaded) {
                    setState(() {
                      _allBillModels = state.monthlyBills.map((bill) => MonthlyBillModel(
                        billId: bill.billId,
                        userId: bill.userId,
                        detailId: bill.detailId,
                        roomId: bill.roomId,
                        billMonth: bill.billMonth,
                        totalAmount: bill.totalAmount,
                        paymentStatus: bill.paymentStatus,
                        createdAt: bill.createdAt,
                        paymentMethodAllowed: bill.paymentMethodAllowed,
                        paidAt: bill.paidAt,
                        transactionReference: bill.transactionReference,
                        userDetails: bill.userDetails != null
                            ? UserDetailsModel(
                          userId: bill.userDetails!.userId,
                          fullname: bill.userDetails!.fullname,
                          email: bill.userDetails!.email,
                        )
                            : null,
                        roomDetails: bill.roomDetails != null
                            ? RoomDetailsModel(
                          roomId: bill.roomDetails!.roomId,
                          name: bill.roomDetails!.name,
                        )
                            : null,
                        billDetailId: bill.billDetailId,
                      )).toList();
                      _isInitialLoad = false;
                      _applyFilters();
                    });
                    _saveLocalData();
                  } else if (state is BillDetailsLoaded) {
                    setState(() {
                      _allBillDetails = state.billDetails;
                      _applyFilters();
                    });
                    _saveLocalData();
                  } else if (state is MonthlyBillDeleted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.buttonSuccess,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                    _fetchBills();
                  } else if (state is MonthlyBillsCreated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.buttonSuccess,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                    _fetchBills();
                  }
                },
              ),
              BlocListener<ServiceBloc, ServiceState>(
                listener: (context, state) {
                  if (state is ServiceError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi khi lấy danh sách dịch vụ: ${state.message}')),
                    );
                  } else if (state is ServicesLoaded) {
                    setState(() {
                      _services = state.services.map((service) => ServiceModel(
                        serviceId: service.serviceId,
                        name: service.name,
                        unit: service.unit,
                      )).toList();
                      _applyFilters();
                    });
                    _saveLocalData();
                  }
                },
              ),
              BlocListener<AreaBloc, AreaState>(
                listener: (context, state) {
                  if (state.error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi khi lấy danh sách khu vực: ${state.error!}')),
                    );
                  } else {
                    setState(() {
                      _areas = state.areas;
                      _applyFilters();
                    });
                    _saveLocalData();
                  }
                },
              ),
              BlocListener<RoomBloc, RoomState>(
                listener: (context, state) {
                  if (state is RoomError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi khi lấy danh sách phòng: ${state.message}')),
                    );
                  } else if (state is RoomLoaded) {
                    setState(() {
                      _rooms = state.rooms;
                      _applyFilters();
                    });
                    _saveLocalData();
                  }
                },
              ),
            ],
            child: LayoutBuilder(
              builder: (context, constraints) {
                double paddingHorizontal = 8.0;
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16.0),
                              margin: const EdgeInsets.symmetric(horizontal: 8.0),
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(
                                    color: AppColors.shadowColor,
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            const Text(
                                              'Khu vực:',
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: Colors.grey),
                                                  borderRadius: BorderRadius.circular(8.0),
                                                ),
                                                child: DropdownButton<String>(
                                                  hint: const Text('Tất cả khu vực'),
                                                  value: _filterArea,
                                                  isExpanded: true,
                                                  underline: const SizedBox(),
                                                  items: uniqueAreas.map((area) => DropdownMenuItem<String>(
                                                    value: area,
                                                    child: Text(area == 'All' ? 'Tất cả' : area),
                                                  )).toList(),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _filterArea = value ?? 'All';
                                                      _currentPage = 1;
                                                      _saveLocalData();
                                                      _applyFilters();
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            const Text(
                                              'Trạng thái:',
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: Colors.grey),
                                                  borderRadius: BorderRadius.circular(8.0),
                                                ),
                                                child: DropdownButton<String>(
                                                  hint: const Text('Tất cả trạng thái'),
                                                  value: _filterStatus,
                                                  isExpanded: true,
                                                  underline: const SizedBox(),
                                                  items: uniqueStatuses.map((status) => DropdownMenuItem<String>(
                                                    value: status,
                                                    child: Text(
                                                      status == 'PENDING'
                                                          ? 'Chưa thanh toán'
                                                          : status == 'PAID'
                                                          ? 'Đã thanh toán'
                                                          : 'Tất cả',
                                                    ),
                                                  )).toList(),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _filterStatus = value ?? 'All';
                                                      _currentPage = 1;
                                                      _saveLocalData();
                                                      _applyFilters();
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            const Text(
                                              'Dịch vụ:',
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: Colors.grey),
                                                  borderRadius: BorderRadius.circular(8.0),
                                                ),
                                                child: DropdownButton<String>(
                                                  hint: const Text('Tất cả dịch vụ'),
                                                  value: _filterService,
                                                  isExpanded: true,
                                                  underline: const SizedBox(),
                                                  items: uniqueServices.map((service) => DropdownMenuItem<String>(
                                                    value: service,
                                                    child: Text(service == 'All' ? 'Tất cả' : service),
                                                  )).toList(),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _filterService = value ?? 'All';
                                                      _currentPage = 1;
                                                      _saveLocalData();
                                                      _applyFilters();
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            const Text(
                                              'Tháng hóa đơn:',
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () async {
                                                  DateTime? pickedDate = await showDatePicker(
                                                    context: context,
                                                    initialDate: _selectedMonthYear ?? DateTime.now(),
                                                    firstDate: DateTime(2000),
                                                    lastDate: DateTime(2100),
                                                    initialDatePickerMode: DatePickerMode.year,
                                                  );
                                                  if (pickedDate != null) {
                                                    setState(() {
                                                      _selectedMonthYear = pickedDate;
                                                      _filterMonthYear = DateFormat('MM/yyyy').format(pickedDate);
                                                      _currentPage = 1;
                                                      _saveLocalData();
                                                      _applyFilters();
                                                    });
                                                  }
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(color: Colors.grey),
                                                    borderRadius: BorderRadius.circular(8.0),
                                                  ),
                                                  child: Text(
                                                    _selectedMonthYear != null
                                                        ? DateFormat('MM/yyyy').format(_selectedMonthYear!)
                                                        : 'Chọn tháng',
                                                    style: TextStyle(
                                                      color: _selectedMonthYear != null ? AppColors.textPrimary : AppColors.textSecondary,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            const Text(
                                              'Trạng thái hóa đơn:',
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: Colors.grey),
                                                  borderRadius: BorderRadius.circular(8.0),
                                                ),
                                                child: DropdownButton<String>(
                                                  hint: const Text('Tất cả trạng thái'),
                                                  value: _filterBillStatus,
                                                  isExpanded: true,
                                                  underline: const SizedBox(),
                                                  items: billStatuses.map((status) => DropdownMenuItem<String>(
                                                    value: status,
                                                    child: Text(
                                                      status == 'CREATED'
                                                          ? 'Đã tạo hóa đơn'
                                                          : status == 'NOT_CREATED'
                                                          ? 'Chưa tạo hóa đơn'
                                                          : 'Tất cả',
                                                    ),
                                                  )).toList(),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _filterBillStatus = value ?? 'All';
                                                      _currentPage = 1;
                                                      _saveLocalData();
                                                      _applyFilters();
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      const Expanded(child: SizedBox()),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: SearchBarTab(
                                      onChanged: (value) {
                                        setState(() {
                                          _searchQuery = value;
                                          _currentPage = 1;
                                          _saveLocalData();
                                          _applyFilters();
                                        });
                                      },
                                      hintText: 'Tìm kiếm hóa đơn...',
                                      initialValue: _searchQuery,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton.icon(
                                  onPressed: _fetchBills,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.buttonSuccess,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Làm mới'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: MediaQuery.of(context).size.height - 200,
                        child: SingleChildScrollView(
                          child: BlocBuilder<BillBloc, BillState>(
                            builder: (context, state) {
                              bool isLoading = state is BillLoading;

                              int startIndex = (_currentPage - 1) * _limit;
                              int endIndex = startIndex + _limit;
                              if (endIndex > _bills.length) endIndex = _bills.length;
                              List<MonthlyBill> paginatedBills = startIndex < _bills.length
                                  ? _bills.sublist(startIndex, endIndex)
                                  : [];

                              return Column(
                                children: [
                                  if (isLoading && _isInitialLoad)
                                    const Center(child: CircularProgressIndicator())
                                  else if (paginatedBills.isEmpty && !isLoading)
                                    const Center(child: Text('Không có hóa đơn nào'))
                                  else
                                    GenericDataTable<MonthlyBill>(
                                      headers: const [
                                        'Phòng',
                                        'Dịch vụ',
                                        'Tổng tiền',
                                        'Trạng thái',
                                        'Ngày tạo',
                                        '',
                                        ''
                                      ],
                                      data: paginatedBills,
                                      columnWidths: _columnWidths,
                                      cellBuilder: (bill, index) {
                                        if (index >= 7) {
                                          return const SizedBox();
                                        }

                                        BillDetail? billDetail;
                                        if (bill.detailId != null) {
                                          billDetail = _allBillDetails.firstWhere(
                                                (detail) => detail.detailId == bill.detailId,
                                            orElse: () => BillDetail(
                                              detailId: -1,
                                              roomId: bill.roomId,
                                              billMonth: bill.billMonth,
                                              price: 0.0,
                                              submittedBy: null,
                                              submittedAt: null,
                                              submitterDetails: null,
                                              rateDetails: null,
                                              rateId: -1,
                                              monthlyBillId: -1,
                                              previousReading: 0.0,
                                              currentReading: 0.0,
                                            ),
                                          );
                                        }

                                        int? serviceId = billDetail?.rateDetails?.serviceId;
                                        String serviceName = 'N/A';
                                        if (serviceId != null) {
                                          var service = _services.firstWhere(
                                                (s) => s.serviceId == serviceId,
                                            orElse: () => ServiceModel(
                                              serviceId: -1,
                                              name: 'Không xác định',
                                              unit: '',
                                            ),
                                          );
                                          serviceName = service.name;
                                        }

                                        switch (index) {
                                          case 0:
                                            return Text(
                                              bill.roomDetails?.name ?? 'N/A',
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                            );
                                          case 1:
                                            return Text(
                                              serviceName,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                            );
                                          case 2:
                                            return Text(
                                              '${bill.totalAmount.toStringAsFixed(2)} VNĐ',
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                            );
                                          case 3:
                                            return Text(
                                              bill.paymentStatus == 'PENDING' ? 'Chưa thanh toán' : 'Đã thanh toán',
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: bill.paymentStatus == 'PAID'
                                                    ? AppColors.buttonSuccess
                                                    : AppColors.textPrimary,
                                              ),
                                            );
                                          case 4:
                                            return Text(
                                              DateFormat('dd/MM/yyyy').format(bill.createdAt),
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                            );
                                          case 5:
                                            return IconButton(
                                              icon: const Icon(Icons.visibility),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (dialogContext) => BillDetailDialog(bill: bill),
                                                );
                                              },
                                            );
                                          case 6:
                                            return IconButton(
                                              icon: const Icon(Icons.delete, color: AppColors.buttonError),
                                              onPressed: () {
                                                _deleteMonthlyBill(bill.billId);
                                              },
                                            );
                                          default:
                                            return const SizedBox();
                                        }
                                      },
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                                    child: PaginationControls(
                                      currentPage: _currentPage,
                                      totalItems: _bills.length,
                                      limit: _limit,
                                      onPageChanged: (page) {
                                        setState(() {
                                          _currentPage = page;
                                          _saveLocalData();
                                        });
                                      },
                                    ),
                                  ),
                                ],
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
        ],
      ),
    );
  }
}