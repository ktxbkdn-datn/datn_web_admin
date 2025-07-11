import 'package:datn_web_admin/common/widget/search_bar.dart';
import 'package:datn_web_admin/feature/register/presentation/widget/registration_detail_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../common/constants/colors.dart';
import '../../../../common/widget/custom_data_table.dart';
import '../../../../common/widget/filter_tab.dart';
import '../../../../common/widget/pagination_controls.dart';
import '../../../room/presentations/bloc/area_bloc/area_bloc.dart';
import '../../../room/presentations/bloc/area_bloc/area_event.dart';
import '../../../room/presentations/bloc/area_bloc/area_state.dart';
import '../../domain/entity/register_entity.dart';
import '../bloc/registration_bloc.dart';
import '../bloc/registration_event.dart';
import '../bloc/registration_state.dart';

class RegistrationListPage extends StatefulWidget {
  const RegistrationListPage({Key? key}) : super(key: key);

  @override
  _RegistrationListPageState createState() => _RegistrationListPageState();
}

class _RegistrationListPageState extends State<RegistrationListPage> with AutomaticKeepAliveClientMixin {
  int _currentPage = 1;
  static const int _limit = 10;
  String _filterStatus = 'All';
  String _filterArea = 'All';
  String _searchQuery = '';
  List<Registration> _filteredRegistrations = [];
  List<int> _selectedRegistrationIds = [];
  final List<double> _baseColumnWidths = [50.0, 200.0, 200.0, 200.0, 200.0, 200.0, 200.0, 100.0];
  int _totalItems = 0;
  final Map<int, List<Registration>> _pageCache = {};
  static const int _maxCachedPages = 5;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadLocalData();
    context.read<AreaBloc>().add(FetchAreasEvent(page: 1, limit: 100));
    _fetchRegistrations();
  }

  List<double> _getColumnWidths(double screenWidth) {
    final totalBaseWidth = _baseColumnWidths.reduce((a, b) => a + b);
    final availableWidth = screenWidth - 32;
    final scale = availableWidth / totalBaseWidth;
    return _baseColumnWidths.map((width) => width * scale).toList();
  }

  Future<void> _loadLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _currentPage = prefs.getInt('registrationCurrentPage') ?? 1;
        _filterStatus = prefs.getString('registrationFilterStatus') ?? 'All';
        _filterArea = prefs.getString('registrationFilterArea') ?? 'All';
        _searchQuery = prefs.getString('registrationSearchQuery') ?? '';
      });
      _fetchRegistrations();
    } catch (e) {
      print('Error loading local data: $e');
      _fetchRegistrations();
    }
  }

  Future<void> _saveLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('registrationCurrentPage', _currentPage);
      await prefs.setString('registrationFilterStatus', _filterStatus);
      await prefs.setString('registrationFilterArea', _filterArea);
      await prefs.setString('registrationSearchQuery', _searchQuery);
    } catch (e) {
      print('Error saving local data: $e');
    }
  }

  void _fetchRegistrations() {
    if (_pageCache.containsKey(_currentPage)) {
      setState(() {
        _applyLocalFilters(_pageCache[_currentPage]!);
      });
      return;
    }

    String? apiStatus;
    if (_filterStatus == 'PENDING' || _filterStatus == 'APPROVED' || _filterStatus == 'REJECTED') {
      apiStatus = _filterStatus;
    }
    context.read<RegistrationBloc>().add(FetchRegistrations(
      page: _currentPage,
      limit: _limit,
      status: apiStatus,
      nameStudent: _searchQuery.isNotEmpty ? _searchQuery : null,
    ));
  }

  void _cachePage(int page, List<Registration> registrations) {
    setState(() {
      _pageCache[page] = registrations;
      if (_pageCache.length > _maxCachedPages) {
        final oldestPage = _pageCache.keys.reduce((a, b) => a < b ? a : b);
        _pageCache.remove(oldestPage);
      }
    });
  }

  void _clearCache() {
    setState(() {
      _pageCache.clear();
    });
  }

  void _applyLocalFilters(List<Registration> registrations) {
    setState(() {
      _filteredRegistrations = registrations.where((reg) {
        final matchesStatus = _filterStatus == 'All' ||
            (_filterStatus == 'PENDING' && reg.status == 'PENDING') ||
            (_filterStatus == 'APPROVED' && reg.status == 'APPROVED') ||
            (_filterStatus == 'REJECTED' && reg.status == 'REJECTED') ||
            (_filterStatus == 'UNSET_TIME' && reg.meetingDatetime == null) ||
            (_filterStatus == 'MET' && reg.meetingDatetime != null && reg.meetingDatetime!.isBefore(DateTime.now()));
        final matchesArea = _filterArea == 'All' || reg.areaName == _filterArea;
        return matchesStatus && matchesArea;
      }).toList();
      _selectedRegistrationIds.removeWhere((id) => !_filteredRegistrations.any((reg) => reg.registrationId == id));
    });
  }

  void _toggleSelection(int registrationId) {
    setState(() {
      if (_selectedRegistrationIds.contains(registrationId)) {
        _selectedRegistrationIds.remove(registrationId);
      } else {
        _selectedRegistrationIds.add(registrationId);
      }
    });
  }

  void _deleteSelected() {
    if (_selectedRegistrationIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất một đăng ký để xóa'), backgroundColor: Colors.red),
      );
      return;
    }
    context.read<RegistrationBloc>().add(DeleteRegistrationsBatchEvent(_selectedRegistrationIds));
  }

  String _translateStatus(String status) {
    switch (status) {
      case 'APPROVED':
        return 'Đã duyệt';
      case 'PENDING':
        return 'Đang chờ';
      case 'REJECTED':
        return 'Từ chối';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final uniqueAreaNames = ['All', ...context.watch<AreaBloc>().state.areas.map((area) => area.name).toSet()]..sort();
    if (_filterArea != 'All' && !uniqueAreaNames.contains(_filterArea)) {
      setState(() {
        _filterArea = 'All';
        _saveLocalData();
      });
    }

    return Scaffold(
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
          SafeArea(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 960, minHeight: 600),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            margin: const EdgeInsets.symmetric(horizontal: 8.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: BlocBuilder<RegistrationBloc, RegistrationState>(
                                    builder: (context, state) {
                                      int total = _totalItems;
                                      List<Registration> allRegistrations = [];
                                      if (state is RegistrationsLoaded) {
                                        total = state.total;
                                        allRegistrations = state.registrations;
                                      }
                                      return Row(
                                        children: [
                                          FilterTab(
                                            label: 'Tất cả ($total)',
                                            isSelected: _filterStatus == 'All',
                                            onTap: () {
                                              setState(() {
                                                _filterStatus = 'All';
                                                _currentPage = 1;
                                                _clearCache();
                                                _fetchRegistrations();
                                                _saveLocalData();
                                              });
                                            },
                                          ),
                                          const SizedBox(width: 10),
                                          FilterTab(
                                            label: 'Đang chờ (${allRegistrations.where((reg) => reg.status == 'PENDING').length})',
                                            isSelected: _filterStatus == 'PENDING',
                                            onTap: () {
                                              setState(() {
                                                _filterStatus = 'PENDING';
                                                _currentPage = 1;
                                                _clearCache();
                                                _fetchRegistrations();
                                                _saveLocalData();
                                              });
                                            },
                                          ),
                                          const SizedBox(width: 10),
                                          FilterTab(
                                            label: 'Đã duyệt (${allRegistrations.where((reg) => reg.status == 'APPROVED').length})',
                                            isSelected: _filterStatus == 'APPROVED',
                                            onTap: () {
                                              setState(() {
                                                _filterStatus = 'APPROVED';
                                                _currentPage = 1;
                                                _clearCache();
                                                _fetchRegistrations();
                                                _saveLocalData();
                                              });
                                            },
                                          ),
                                          const SizedBox(width: 10),
                                          FilterTab(
                                            label: 'Từ chối (${allRegistrations.where((reg) => reg.status == 'REJECTED').length})',
                                            isSelected: _filterStatus == 'REJECTED',
                                            onTap: () {
                                              setState(() {
                                                _filterStatus = 'REJECTED';
                                                _currentPage = 1;
                                                _clearCache();
                                                _fetchRegistrations();
                                                _saveLocalData();
                                              });
                                            },
                                          ),
                                          const SizedBox(width: 10),
                                          FilterTab(
                                            label: 'Chưa hẹn gặp (${allRegistrations.where((reg) => reg.meetingDatetime == null).length})',
                                            isSelected: _filterStatus == 'UNSET_TIME',
                                            onTap: () {
                                              setState(() {
                                                _filterStatus = 'UNSET_TIME';
                                                _currentPage = 1;
                                                _clearCache();
                                                _fetchRegistrations();
                                                _saveLocalData();
                                              });
                                            },
                                          ),
                                          const SizedBox(width: 10),
                                          FilterTab(
                                            label: 'Đã gặp mặt (${allRegistrations.where((reg) => reg.meetingDatetime != null && reg.meetingDatetime!.isBefore(DateTime.now())).length})',
                                            isSelected: _filterStatus == 'MET',
                                            onTap: () {
                                              setState(() {
                                                _filterStatus = 'MET';
                                                _currentPage = 1;
                                                _clearCache();
                                                _fetchRegistrations();
                                                _saveLocalData();
                                              });
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          const Text('Khu vực:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                                                items: uniqueAreaNames.map((areaName) => DropdownMenuItem<String>(
                                                  value: areaName,
                                                  child: Text(areaName == 'All' ? 'Tất cả' : areaName),
                                                )).toList(),
                                                onChanged: (value) {
                                                  setState(() {
                                                    _filterArea = value ?? 'All';
                                                    _currentPage = 1;
                                                    _clearCache();
                                                    _fetchRegistrations();
                                                    _saveLocalData();
                                                  });
                                                },
                                              ),
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
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          icon: const Icon(Icons.delete),
                                          label: const Text('Xóa đã chọn'),
                                        ),
                                        const SizedBox(width: 10),
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            _clearCache();
                                            _fetchRegistrations();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          icon: const Icon(Icons.refresh),
                                          label: const Text('Làm mới'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          SearchBarTab(
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                                _currentPage = 1;
                                _clearCache();
                                _fetchRegistrations();
                                _saveLocalData();
                              });
                            },
                            hintText: 'Tìm kiếm đăng ký...',
                            initialValue: _searchQuery,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: constraints.maxHeight - 100, // Tăng thêm 200
                            child: BlocConsumer<RegistrationBloc, RegistrationState>(
                              listener: (context, state) {
                                if (state is RegistrationsLoaded) {
                                  setState(() {
                                    _totalItems = state.total;
                                    _cachePage(_currentPage, state.registrations);
                                    _applyLocalFilters(state.registrations..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
                                  });
                                } else if (state is RegistrationError) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                                  );
                                } else if (state is RegistrationsDeleted) {
                                  setState(() {
                                    _selectedRegistrationIds.clear();
                                    _clearCache();
                                    _fetchRegistrations();
                                  });
                                  if (state.message != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(state.message!), backgroundColor: Colors.green),
                                    );
                                  }
                                } else if (state is RegistrationUpdated) {
                                  _clearCache();
                                  _fetchRegistrations();
                                }
                              },
                              builder: (context, state) {
                                final isLoading = state is RegistrationLoading;
                                if (isLoading && _filteredRegistrations.isEmpty) {
                                  return const Center(child: CircularProgressIndicator());
                                } else if (_filteredRegistrations.isEmpty && state is! RegistrationLoading) {
                                  return const Center(child: Text('Không có đăng ký nào'));
                                }

                                return Column(
                                  children: [
                                    Expanded(
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.vertical,
                                        child: GenericDataTable<Registration>(
                                          headers: const [
                                            '',
                                            'Tên sinh viên',
                                            'Email',
                                            'Số điện thoại',
                                            'Tên phòng',
                                            'Tên khu vực',
                                            'Trạng thái',
                                            '',
                                          ],
                                          data: _filteredRegistrations,
                                          columnWidths: _getColumnWidths(MediaQuery.of(context).size.width),
                                          cellBuilder: (registration, index) {
                                            switch (index) {
                                              case 0:
                                                return Checkbox(
                                                  value: _selectedRegistrationIds.contains(registration.registrationId),
                                                  onChanged: (value) {
                                                    if (registration.registrationId != null) {
                                                      _toggleSelection(registration.registrationId!);
                                                    }
                                                  },
                                                );
                                              case 1:
                                                return Text(
                                                  registration.nameStudent,
                                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                                  overflow: TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                );
                                              case 2:
                                                return Text(
                                                  registration.email,
                                                  overflow: TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                );
                                              case 3:
                                                return Text(
                                                  registration.phoneNumber,
                                                  overflow: TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                );
                                              case 4:
                                                return Text(
                                                  registration.roomName ?? 'N/A',
                                                  overflow: TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                );
                                              case 5:
                                                return Text(
                                                  registration.areaName ?? 'N/A',
                                                  overflow: TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                );
                                              case 6:
                                                return Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: _getStatusColor(registration.status),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    _translateStatus(registration.status),
                                                    style: const TextStyle(color: Colors.white),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                );
                                              case 7:
                                                return IconButton(
                                                  icon: const Icon(Icons.visibility),
                                                  onPressed: registration.registrationId != null
                                                      ? () {
                                                          context.read<RegistrationBloc>().add(FetchRegistrationById(registration.registrationId!));
                                                          showDialog(
                                                            context: context,
                                                            barrierDismissible: false,
                                                            builder: (dialogContext) => RegistrationDetailDialog(registration: registration),
                                                          );
                                                        }
                                                      : null,
                                                );
                                              default:
                                                return const SizedBox();
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    PaginationControls(
                                      currentPage: _currentPage,
                                      totalItems: _totalItems,
                                      limit: _limit,
                                      onPageChanged: (page) {
                                        setState(() {
                                          _currentPage = page;
                                          _fetchRegistrations();
                                          _saveLocalData();
                                        });
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.yellow;
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}