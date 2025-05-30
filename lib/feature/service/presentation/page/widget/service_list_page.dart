import 'package:datn_web_admin/feature/service/presentation/page/widget/service_detail_dialog.dart';
import 'package:datn_web_admin/feature/service/presentation/page/widget/create_service_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../common/widget/search_bar.dart';
import '../../../../../common/widget/filter_tab.dart';
import '../../../../../common/widget/pagination_controls.dart';
import '../../../../../common/widget/custom_data_table.dart';
import '../../../../../common/constants/colors.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../../data/models/service_model.dart';
import '../../../domain/entities/service_entity.dart';
import '../../bloc/service_bloc.dart';
import '../../bloc/service_event.dart';
import '../../bloc/service_state.dart';

class ServiceListPage extends StatefulWidget {
  const ServiceListPage({Key? key}) : super(key: key);

  @override
  _ServiceListPageState createState() => _ServiceListPageState();
}

class _ServiceListPageState extends State<ServiceListPage> with AutomaticKeepAliveClientMixin {
  int _currentPage = 1;
  static const int _limit = 12;
  String _searchQuery = '';
  List<ServiceModel> _allServiceModels = [];
  List<Service> _services = [];
  bool _isInitialLoad = true;
  List<int> _selectedServiceIds = [];
  Map<int, double?> _currentRates = {};
  String _filterRateStatus = 'All';
  String _filterUnit = 'All';
  final List<double> _columnWidths = [40.0, 200.0, 100.0, 150.0, 40.0]; // Checkbox, Tên dịch vụ, Đơn vị tính, Mức giá hiện tại, Hành động

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadLocalData();
    _fetchServices();
  }

  Future<void> _loadLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _currentPage = prefs.getInt('serviceCurrentPage') ?? 1;
    _searchQuery = prefs.getString('serviceSearchQuery') ?? '';
    _filterRateStatus = prefs.getString('serviceFilterRateStatus') ?? 'All';
    _filterUnit = prefs.getString('serviceFilterUnit') ?? 'All';
    String? servicesJson = prefs.getString('services');
    if (servicesJson != null) {
      try {
        List<dynamic> servicesList = jsonDecode(servicesJson);
        setState(() {
          _allServiceModels = servicesList
              .map((json) => ServiceModel.fromJson(json))
              .where((serviceModel) => serviceModel.serviceId != null)
              .toList();
          _services = _allServiceModels.map((model) => model.toEntity()).toList();
          _applyFilters();
        });
      } catch (e) {
        print('Error loading local data: $e');
        await prefs.remove('services');
        _fetchServices();
      }
    }
  }

  Future<void> _saveLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('serviceCurrentPage', _currentPage);
    await prefs.setString('serviceSearchQuery', _searchQuery);
    await prefs.setString('serviceFilterRateStatus', _filterRateStatus);
    await prefs.setString('serviceFilterUnit', _filterUnit);
    await prefs.setString('services', jsonEncode(_allServiceModels.map((serviceModel) => serviceModel.toJson()).toList()));
  }

  void _fetchServices() {
    context.read<ServiceBloc>().add(const FetchServices(page: 1, limit: 1000));
  }

  void _applyFilters() {
    setState(() {
      _services = _allServiceModels.where((serviceModel) {
        bool matchesRateStatus = true;
        if (_filterRateStatus == 'All') {
          matchesRateStatus = true;
        } else if (_filterRateStatus == 'WITH_RATE') {
          matchesRateStatus = _currentRates[serviceModel.serviceId] != null;
        } else if (_filterRateStatus == 'WITHOUT_RATE') {
          matchesRateStatus = _currentRates[serviceModel.serviceId] == null;
        }

        bool matchesUnit = _filterUnit == 'All' || serviceModel.unit == _filterUnit;
        bool matchesSearch = _searchQuery.isEmpty ||
            serviceModel.name.toLowerCase().contains(_searchQuery.toLowerCase());
        return matchesRateStatus && matchesUnit && matchesSearch;
      }).map((model) => model.toEntity()).toList();
      _selectedServiceIds.removeWhere((id) => !_services.any((service) => service.serviceId == id));
    });
  }

  void _toggleSelection(int serviceId) {
    setState(() {
      if (_selectedServiceIds.contains(serviceId)) {
        _selectedServiceIds.remove(serviceId);
      } else {
        _selectedServiceIds.add(serviceId);
      }
    });
  }

  void _deleteSelected() {
    if (_selectedServiceIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất một dịch vụ để xóa'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    for (var serviceId in _selectedServiceIds) {
      context.read<ServiceBloc>().add(DeleteServiceEvent(serviceId));
    }
  }

  void _fetchCurrentRate(int serviceId) {
    context.read<ServiceBloc>().add(FetchCurrentServiceRate(serviceId));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    List<String> uniqueUnits = [];
    Set<String> seenUnits = {};
    for (var service in _allServiceModels) {
      if (!seenUnits.contains(service.unit) && service.unit.isNotEmpty) {
        seenUnits.add(service.unit);
        uniqueUnits.add(service.unit);
      }
    }
    uniqueUnits.sort();

    if (_filterUnit != 'All' && !uniqueUnits.contains(_filterUnit)) {
      _filterUnit = 'All';
    }

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
              body: BlocListener<ServiceBloc, ServiceState>(
                listener: (context, state) {
                  if (state is ServiceError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Lỗi: ${state.message}'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  } else if (state is ServiceDeleted) {
                    setState(() {
                      _allServiceModels.removeWhere((serviceModel) => serviceModel.serviceId == state.deletedId);
                      _applyFilters();
                      _selectedServiceIds.remove(state.deletedId);
                      _currentRates.remove(state.deletedId);
                    });
                    _saveLocalData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message ?? 'Xóa dịch vụ thành công'),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  } else if (state is ServicesLoaded) {
                    setState(() {
                      _allServiceModels = state.services.map((service) => ServiceModel(
                        serviceId: service.serviceId,
                        name: service.name,
                        unit: service.unit,
                      )).toList();
                      _isInitialLoad = false;
                      _applyFilters();
                      for (var service in state.services) {
                        _fetchCurrentRate(service.serviceId);
                      }
                    });
                    _saveLocalData();
                  } else if (state is CurrentServiceRateLoaded) {
                    setState(() {
                      _currentRates[state.serviceRate.serviceId] = state.serviceRate.unitPrice;
                    });
                    _applyFilters();
                  } else if (state is ServiceCreated) {
                    setState(() {
                      _allServiceModels.add(ServiceModel(
                        serviceId: state.service.serviceId,
                        name: state.service.name,
                        unit: state.service.unit,
                      ));
                      _applyFilters();
                      _fetchCurrentRate(state.service.serviceId);
                    });
                    _saveLocalData();
                  }
                },
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
                                      label: 'Tất cả (${_allServiceModels.length})',
                                      isSelected: _filterRateStatus == 'All',
                                      onTap: () {
                                        setState(() {
                                          _filterRateStatus = 'All';
                                          _currentPage = 1;
                                          _saveLocalData();
                                          _applyFilters();
                                        });
                                      },
                                    ),
                                    const SizedBox(width: 10),
                                    FilterTab(
                                      label: 'Có mức giá (${_allServiceModels.where((service) => _currentRates[service.serviceId] != null).length})',
                                      isSelected: _filterRateStatus == 'WITH_RATE',
                                      onTap: () {
                                        setState(() {
                                          _filterRateStatus = 'WITH_RATE';
                                          _currentPage = 1;
                                          _saveLocalData();
                                          _applyFilters();
                                        });
                                      },
                                    ),
                                    const SizedBox(width: 10),
                                    FilterTab(
                                      label: 'Không có mức giá (${_allServiceModels.where((service) => _currentRates[service.serviceId] == null).length})',
                                      isSelected: _filterRateStatus == 'WITHOUT_RATE',
                                      onTap: () {
                                        setState(() {
                                          _filterRateStatus = 'WITHOUT_RATE';
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
                                        Container(
                                          width: 200,
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey),
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                          child: DropdownButton<String>(
                                            hint: const Text('Tất cả đơn vị'),
                                            value: _filterUnit,
                                            isExpanded: true,
                                            underline: const SizedBox(),
                                            items: [
                                              const DropdownMenuItem<String>(
                                                value: 'All',
                                                child: Text('Tất cả đơn vị'),
                                              ),
                                              ...uniqueUnits.map((unit) => DropdownMenuItem<String>(
                                                    value: unit,
                                                    child: Text(unit),
                                                  )),
                                            ],
                                            onChanged: (value) {
                                              setState(() {
                                                _filterUnit = value ?? 'All';
                                                _currentPage = 1;
                                                _saveLocalData();
                                                _applyFilters();
                                              });
                                            },
                                          ),
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
                                            hintText: 'Tìm kiếm dịch vụ...',
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
                                        onPressed: _deleteSelected,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        icon: const Icon(Icons.delete),
                                        label: const Text('Xóa đã chọn'),
                                      ),
                                      const SizedBox(width: 10),
                                      ElevatedButton.icon(
                                        onPressed: _fetchServices,
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
                                            builder: (dialogContext) => const CreateServiceDialog(),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        icon: const Icon(Icons.add),
                                        label: const Text('Thêm dịch vụ'),
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
                          child: BlocBuilder<ServiceBloc, ServiceState>(
                            builder: (context, state) {
                              bool isLoading = state is ServiceLoading;

                              int startIndex = (_currentPage - 1) * _limit;
                              int endIndex = startIndex + _limit;
                              if (endIndex > _services.length) endIndex = _services.length;
                              List<Service> paginatedServices = startIndex < _services.length
                                  ? _services.sublist(startIndex, endIndex)
                                  : [];

                              return isLoading && _isInitialLoad
                                  ? const Center(child: CircularProgressIndicator())
                                  : paginatedServices.isEmpty
                                      ? const Center(child: Text('Không có dịch vụ nào'))
                                      : Column(
                                          children: [
                                            GenericDataTable<Service>(
                                              headers: const [
                                                '',
                                                'Tên dịch vụ',
                                                'Đơn vị tính',
                                                'Mức giá hiện tại',
                                                '',
                                              ],
                                              data: paginatedServices,
                                              columnWidths: _columnWidths,
                                              cellBuilder: (service, index) {
                                                final currentRate = _currentRates[service.serviceId];
                                                switch (index) {
                                                  case 0:
                                                    return Checkbox(
                                                      value: _selectedServiceIds.contains(service.serviceId),
                                                      onChanged: (value) {
                                                        _toggleSelection(service.serviceId);
                                                      },
                                                    );
                                                  case 1:
                                                    return Text(
                                                      service.name,
                                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                                      overflow: TextOverflow.ellipsis,
                                                      textAlign: TextAlign.center,
                                                    );
                                                  case 2:
                                                    return Text(
                                                      service.unit,
                                                      overflow: TextOverflow.ellipsis,
                                                      textAlign: TextAlign.center,
                                                    );
                                                  case 3:
                                                    return Text(
                                                      currentRate != null
                                                          ? '${currentRate.toStringAsFixed(2)} VNĐ'
                                                          : 'N/A',
                                                      overflow: TextOverflow.ellipsis,
                                                      textAlign: TextAlign.center,
                                                    );
                                                  case 4:
                                                    return IconButton(
                                                      icon: const Icon(Icons.visibility),
                                                      onPressed: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (dialogContext) => ServiceDetailDialog(service: service),
                                                        );
                                                      },
                                                    );
                                                  default:
                                                    return const SizedBox();
                                                }
                                              },
                                            ),
                                            PaginationControls(
                                              currentPage: _currentPage,
                                              totalItems: _services.length,
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
}