import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:datn_web_admin/common/constants/colors.dart';
import 'package:datn_web_admin/feature/bill/presentation/bloc/bill_bloc.dart';
import 'package:datn_web_admin/feature/bill/presentation/bloc/bill_event.dart';
import 'package:datn_web_admin/feature/bill/presentation/bloc/bill_state.dart';
import 'package:datn_web_admin/feature/service/domain/entities/service_entity.dart';
import 'package:datn_web_admin/feature/service/presentation/bloc/service_bloc.dart';
import 'package:datn_web_admin/feature/service/presentation/bloc/service_state.dart';
import 'package:datn_web_admin/feature/service/presentation/bloc/service_event.dart';

class MeterHistoryDialog extends StatefulWidget {
  final int roomId;
  final String roomName;

  const MeterHistoryDialog({
    Key? key,
    required this.roomId,
    required this.roomName,
  }) : super(key: key);

  @override
  State<MeterHistoryDialog> createState() => _MeterHistoryDialogState();
}

class _MeterHistoryDialogState extends State<MeterHistoryDialog> with SingleTickerProviderStateMixin {
  int _selectedYear = DateTime.now().year;
  int _selectedServiceId = 1; // Default, will be updated when services are loaded
  bool _isLoading = false;
  List<Service> _services = [];
  TabController? _tabController;

  final List<int> _availableYears = [
    DateTime.now().year - 2,
    DateTime.now().year - 1,
    DateTime.now().year,
  ];  @override
  void initState() {
    super.initState();
    
    // Set default available years
    _availableYears.sort((a, b) => b.compareTo(a)); // Sort in descending order
    
    // Load services first, which will trigger loading bill details after
    _loadServices();
    
    // Ensure we have the ServiceBloc available
    final serviceState = context.read<ServiceBloc>().state;
    if (!(serviceState is ServicesLoaded) || serviceState.services.isEmpty) {
      // If services are not already loaded, fetch them
      context.read<ServiceBloc>().add(const FetchServices(page: 1, limit: 100));
    }
  }void _loadServices() {
    setState(() {
      _isLoading = true;
    });
    
    // Get services from the ServiceBloc
    final serviceState = context.read<ServiceBloc>().state;
    if (serviceState is ServicesLoaded && serviceState.services.isNotEmpty) {
      setState(() {
        _services = serviceState.services;
        if (_services.isNotEmpty) {
          // Set the initial service ID from the first service
          _selectedServiceId = _services.first.serviceId;
          _initTabController();
          
          // Load bill details with the selected service ID
          _loadBillDetails();
        } else {
          _isLoading = false;
        }
      });
    } else {
      // If services are not already loaded, fetch them
      context.read<ServiceBloc>().add(const FetchServices(page: 1, limit: 100));
    }
  }  void _initTabController() {
    if (_services.isNotEmpty && _tabController == null) {
      _tabController = TabController(length: _services.length, vsync: this);
      
      // Find the initial tab index based on the selected service ID
      int initialIndex = _services.indexWhere((s) => s.serviceId == _selectedServiceId);
      if (initialIndex >= 0) {
        _tabController!.index = initialIndex;
      } else {
        // If service ID not found in the list, reset to the first service
        _selectedServiceId = _services.first.serviceId;
      }
      
      _tabController!.addListener(() {
        if (!_tabController!.indexIsChanging) {
          if (_tabController!.index >= 0 && _tabController!.index < _services.length) {
            final newServiceId = _services[_tabController!.index].serviceId;
            if (newServiceId != _selectedServiceId) {
              setState(() {
                _selectedServiceId = newServiceId;
              });
              _loadBillDetails();
            }
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }  // Debug method to log the current state
  void _logDebugInfo(String location) {
    print('[$location] roomId: ${widget.roomId}, serviceId: $_selectedServiceId, year: $_selectedYear');
    if (_services.isNotEmpty) {
      print('Services: ${_services.map((s) => '${s.serviceId}:${s.name}').join(', ')}');
    } else {
      print('No services loaded yet');
    }
    
    if (_tabController != null) {
      print('Tab index: ${_tabController!.index}');
    }
  }
    int get correctServiceId {
    // Safety check to ensure we have a valid service ID
    if (_services.isEmpty) {
      print('Warning: No services loaded, using default service ID 1');
      return 1; // Default value if no services are loaded yet
    }
    
    // Check if current selectedServiceId exists in the services list
    bool serviceExists = _services.any((service) => service.serviceId == _selectedServiceId);
    if (!serviceExists) {
      print('Warning: Selected service ID $_selectedServiceId not found in services list, using first service ID ${_services.first.serviceId}');
      // If not, use the first available service
      return _services.first.serviceId;
    }
    
    return _selectedServiceId;
  }
  void _loadBillDetails() {
    setState(() {
      _isLoading = true;
    });

    // Use the validated service ID
    final serviceId = correctServiceId;
    
    try {
      _logDebugInfo('_loadBillDetails');
      print('Calling API with serviceId: $serviceId');
      
      context.read<BillBloc>().add(GetRoomBillDetailsEvent(
            roomId: widget.roomId,
            year: _selectedYear,
            serviceId: serviceId,
          ));
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      // Show error in a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi tải dữ liệu: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context) {    final size = MediaQuery.of(context).size;
    
    return Container(
      width: size.width * 0.8,
      height: size.height * 0.85,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 10),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [              Text(
                'Lịch sử chỉ số: ${widget.roomName}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Year selection
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: AppColors.buttonPrimaryColor),
                  const SizedBox(width: 12),
                  const Text(
                    'Năm:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedYear,
                        onChanged: (int? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedYear = newValue;
                            });
                            _loadBillDetails();
                          }
                        },
                        items: _availableYears.map<DropdownMenuItem<int>>((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(value.toString()),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),          const SizedBox(height: 16),
          // Service tabs
          BlocConsumer<BillBloc, BillState>(
            listener: (context, state) {              if (state is RoomBillDetailsLoaded) {
                setState(() {
                  _isLoading = false;
                  
                  // Ensure the selected service ID matches the state
                  if (state.serviceId != _selectedServiceId) {
                    print('State service ID (${state.serviceId}) doesn\'t match selected (${_selectedServiceId}) - updating');
                    _selectedServiceId = state.serviceId;
                    
                    // Find the tab index for this service ID
                    final tabIndex = _services.indexWhere((s) => s.serviceId == _selectedServiceId);
                    if (tabIndex >= 0 && _tabController != null && _tabController!.index != tabIndex) {
                      print('Animating tab controller to index $tabIndex');
                      _tabController!.animateTo(tabIndex);
                    }
                  }
                });              } else if (state is BillError) {
                setState(() {
                  _isLoading = false;
                });
                
                // Show error in a SnackBar instead of on screen
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lỗi: ${state.message}'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },            builder: (context, billState) {
              return BlocConsumer<ServiceBloc, ServiceState>(
                listener: (context, serviceState) {
                  if (serviceState is ServicesLoaded && serviceState.services.isNotEmpty) {
                    setState(() {
                      _services = serviceState.services;
                      
                      // If no services were loaded before or if the service IDs changed
                      bool serviceIdsChanged = false;
                      if (_services.isNotEmpty) {
                        // Check if the currently selected service ID exists in the new services list
                        serviceIdsChanged = !_services.any((s) => s.serviceId == _selectedServiceId);
                      }
                      
                      // If this is the first load or if the service ID isn't in the list anymore
                      if (_tabController == null || serviceIdsChanged) {
                        _selectedServiceId = _services.first.serviceId;
                        _initTabController();
                        _loadBillDetails();
                      }
                      
                      _isLoading = false;
                    });
                  } else if (serviceState is ServiceError) {
                    setState(() {
                      _isLoading = false;
                    });
                    
                    // Show error in a SnackBar instead of on screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Lỗi dịch vụ: ${serviceState.message}'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                },
                builder: (context, serviceState) {
                  if ((billState is BillLoading || _isLoading) && _services.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  
                  return Expanded(
                    child: Column(                      children: [
                        // Tabs for services
                        if (_services.isNotEmpty)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            child: TabBar(
                              controller: _tabController,
                              isScrollable: true,
                              labelColor: AppColors.buttonPrimaryColor,
                              unselectedLabelColor: AppColors.textSecondary,
                              indicatorColor: AppColors.buttonPrimaryColor,
                              indicatorWeight: 3,
                              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              unselectedLabelStyle: const TextStyle(fontSize: 14),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              onTap: (index) {
                                // Update service ID when tab is tapped
                                if (index >= 0 && index < _services.length) {
                                  final newServiceId = _services[index].serviceId;
                                  if (newServiceId != _selectedServiceId) {
                                    setState(() {
                                      _selectedServiceId = newServiceId;
                                    });
                                    _loadBillDetails();
                                  }
                                }
                              },
                              tabs: _services.map((service) => Tab(
                                text: service.name,
                                icon: service.serviceId == _selectedServiceId 
                                    ? const Icon(Icons.check_circle, size: 12) 
                                    : null,
                              )).toList(),
                            ),
                          ),                        
                        // Tab content
                        Expanded(
                          child: _isLoading
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.buttonPrimaryColor),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Đang tải dữ liệu...',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: AppColors.textSecondary.withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : billState is RoomBillDetailsLoaded
                                  ? _buildHistoryList(billState.roomBillDetails)
                                  : billState is BillError
                                      ? Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.error_outline,
                                                size: 48,
                                                color: AppColors.buttonError,
                                              ),
                                              const SizedBox(height: 16),
                                              const Text(
                                                'Đã xảy ra lỗi khi tải dữ liệu',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Vui lòng thử lại sau',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: AppColors.textSecondary.withOpacity(0.8),
                                                ),
                                              ),
                                              const SizedBox(height: 24),
                                              ElevatedButton.icon(
                                                onPressed: _loadBillDetails,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: AppColors.buttonPrimaryColor,
                                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                ),
                                                icon: const Icon(Icons.refresh, color: Colors.white),
                                                label: const Text(
                                                  'Thử lại',
                                                  style: TextStyle(color: Colors.white),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : const Center(child: Text('Không có dữ liệu')),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }  Widget _buildHistoryList(List<Map<String, dynamic>> billDetails) {
    if (billDetails.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hourglass_empty,
              size: 60,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Không có dữ liệu cho năm và dịch vụ này',
              style: TextStyle(
                fontSize: 18, 
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vui lòng chọn năm hoặc dịch vụ khác',
              style: TextStyle(
                fontSize: 14, 
                color: AppColors.textSecondary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: billDetails.length,
      itemBuilder: (context, index) {
        final detail = billDetails[index];
        final month = detail['month'] as int?;
            
        final currentReading = detail['current_reading'] != null
            ? (detail['current_reading'] is String 
                ? double.tryParse(detail['current_reading'] as String) 
                : detail['current_reading'] as double?)
            : null;
            
        final submittedAt = detail['submitted_at'] != null
            ? DateTime.parse(detail['submitted_at'] as String)
            : null;        return Card(
          margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 6),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.buttonPrimaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.buttonPrimaryColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        'Tháng ${month ?? 'N/A'}/$_selectedYear',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.buttonPrimaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                  // Only show chỉ số báo cáo with enhanced styling
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.05),
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_upward, color: Colors.green, size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Chỉ số báo cáo',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '${currentReading?.toStringAsFixed(2) ?? 'N/A'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),
                if (submittedAt != null)
                  Text(
                    'Ngày cập nhật: ${DateFormat('dd/MM/yyyy HH:mm').format(submittedAt)}',
                    style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
