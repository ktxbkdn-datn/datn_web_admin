import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../common/widget/search_bar.dart';
import '../../../../../common/widget/filter_tab.dart';
import '../../../../../common/widget/pagination_controls.dart';
import '../../../../../common/widget/custom_data_table.dart';
import '../../../../../common/constants/colors.dart';
import '../../../contract/domain/entities/contract_entity.dart';
import '../../../contract/presentation/bloc/contract_bloc.dart';
import '../../../contract/presentation/bloc/contract_event.dart';
import '../../../contract/presentation/bloc/contract_state.dart';
import '../../../contract/presentation/widget/contract_detail_dialog.dart';
import '../../../contract/presentation/widget/create_contract_dialog.dart';
import '../../../room/domain/entities/area_entity.dart';
import '../../../room/presentations/bloc/area_bloc/area_bloc.dart';
import '../../../room/presentations/bloc/area_bloc/area_event.dart';
import '../../../room/presentations/bloc/area_bloc/area_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ContractListPage extends StatefulWidget {
  final bool showExpired;
  final bool showAll;
  final Function({required bool showAll, required bool showExpired}) onTabChanged;

  const ContractListPage({
    Key? key,
    this.showExpired = false,
    this.showAll = false,
    required this.onTabChanged,
  }) : super(key: key);

  @override
  _ContractListPageState createState() => _ContractListPageState();
}

class _ContractListPageState extends State<ContractListPage> with AutomaticKeepAliveClientMixin {
  int _currentPage = 1;
  static const int _limit = 12;
  int? _selectedAreaId;
  String _searchQuery = '';
  List<Contract> _allContracts = [];
  List<Contract> _contracts = [];
  bool _isInitialLoad = true;
  final List<double> _columnWidths = [150.0, 150.0, 150.0, 150.0, 150.0, 100.0];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadLocalData();
    context.read<AreaBloc>().add(FetchAreasEvent(page: 1, limit: 100));
    _fetchContracts();
  }

  Future<void> _loadLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _currentPage = prefs.getInt('contractCurrentPage') ?? 1;
    _selectedAreaId = prefs.getInt('contractSelectedAreaId');
    _searchQuery = prefs.getString('contractSearchQuery') ?? '';
    String? contractsJson = prefs.getString('contracts');
    if (contractsJson != null) {
      List<dynamic> contractsList = jsonDecode(contractsJson);
      setState(() {
        _allContracts = contractsList.map((json) => Contract.fromJson(json)).toList();
        _applyFilters();
      });
    }
  }

  Future<void> _saveLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('contractCurrentPage', _currentPage);
    if (_selectedAreaId != null) {
      await prefs.setInt('contractSelectedAreaId', _selectedAreaId!);
    } else {
      await prefs.remove('contractSelectedAreaId');
    }
    await prefs.setString('contractSearchQuery', _searchQuery);
    await prefs.setString('contracts', jsonEncode(_allContracts.map((contract) => contract.toJson()).toList()));
  }

  void _fetchContracts() {
    context.read<ContractBloc>().add(const FetchAllContractsEvent());
  }

  void _applyFilters() {
    setState(() {
      _contracts = _allContracts.where((contract) {
        bool matchesStatus = widget.showAll
            ? true
            : widget.showExpired
            ? _isExpiringSoon(contract.endDate)
            : contract.status == 'ACTIVE';
        bool matchesSearch = _searchQuery.isEmpty ||
            contract.roomName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            contract.userEmail.toLowerCase().contains(_searchQuery.toLowerCase());
        return matchesStatus && matchesSearch;
      }).toList();
    });
  }

  bool _isExpiringSoon(String endDate) {
    DateTime end = DateTime.parse(endDate);
    DateTime now = DateTime.now();
    DateTime fifteenDaysFromNow = now.add(const Duration(days: 15));
    return end.isAfter(now) && end.isBefore(fifteenDaysFromNow);
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
                  BlocListener<ContractBloc, ContractState>(
                    listener: (context, state) {
                      if (state is ContractError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Lỗi: ${state.errorMessage}'),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      } else if (state is ContractDeleted) {
                        setState(() {
                          _allContracts.removeWhere((contract) => contract.contractId == state.contractId);
                          _applyFilters();
                        });
                        _saveLocalData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.successMessage),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      } else if (state is ContractListLoaded) {
                        setState(() {
                          _allContracts = state.contracts;
                          _isInitialLoad = false;
                          _applyFilters();
                        });
                        _saveLocalData();
                      } else if (state is ContractStatusUpdated) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.successMessage),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 2),
                          ),
                        );
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
                                      label: 'Tất cả (${_allContracts.length})',
                                      isSelected: widget.showAll,
                                      onTap: () {
                                        widget.onTabChanged(showAll: true, showExpired: false);
                                      },
                                    ),
                                    const SizedBox(width: 10),
                                    FilterTab(
                                      label: 'Còn hiệu lực (${_allContracts.where((contract) => contract.status == 'ACTIVE').length})',
                                      isSelected: !widget.showExpired && !widget.showAll,
                                      onTap: () {
                                        widget.onTabChanged(showAll: false, showExpired: false);
                                      },
                                    ),
                                    const SizedBox(width: 10),
                                    FilterTab(
                                      label: 'Sắp đáo hạn (${_allContracts.where((contract) => _isExpiringSoon(contract.endDate)).length})',
                                      isSelected: widget.showExpired,
                                      onTap: () {
                                        widget.onTabChanged(showAll: false, showExpired: true);
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
                                            hintText: 'tìm kiếm theo tên phòng hoặc email người dùng',
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
                                        onPressed: () => context.read<ContractBloc>().add(const FetchAllContractsEvent()),
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
                                          context.read<ContractBloc>().add(UpdateContractStatusEvent());
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        icon: const Icon(Icons.update),
                                        label: const Text('Cập nhật trạng thái'),
                                      ),
                                      const SizedBox(width: 10),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => const CreateContractDialog(),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        icon: const Icon(Icons.add),
                                        label: const Text('Add a new contract'),
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
                          child: BlocBuilder<ContractBloc, ContractState>(
                            builder: (context, state) {
                              bool isLoading = state is ContractLoading;
                              String? errorMessage;

                              if (state is ContractError) {
                                errorMessage = state.errorMessage;
                              }

                              int startIndex = (_currentPage - 1) * _limit;
                              int endIndex = startIndex + _limit;
                              if (endIndex > _contracts.length) endIndex = _contracts.length;
                              List<Contract> paginatedContracts =
                              startIndex < _contracts.length ? _contracts.sublist(startIndex, endIndex) : [];

                              return isLoading && _isInitialLoad
                                  ? const Center(child: CircularProgressIndicator())
                                  : errorMessage != null
                                  ? Center(child: Text('Lỗi: $errorMessage'))
                                  : paginatedContracts.isEmpty
                                  ? const Center(child: Text('Không có hợp đồng nào'))
                                  : Column(
                                children: [
                                  GenericDataTable<Contract>(
                                    headers: const [
                                      'Tên phòng',
                                      'Tên người dùng',
                                      'Ngày bắt đầu',
                                      'Ngày kết thúc',
                                      'Trạng thái',
                                      '',
                                    ],
                                    data: paginatedContracts,
                                    columnWidths: _columnWidths,
                                    cellBuilder: (contract, index) {
                                      switch (index) {
                                        case 0:
                                          return Text(
                                            contract.roomName,
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                          );
                                        case 1:
                                          return Text(
                                            contract.fullname ?? 'Chưa có',
                                            style: const TextStyle(color: Colors.grey),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                          );
                                        case 2:
                                          return Text(
                                            contract.startDate,
                                            style: const TextStyle(color: Colors.grey),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                          );
                                        case 3:
                                          return Text(
                                            contract.endDate,
                                            style: const TextStyle(color: Colors.grey),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                          );
                                        case 4:
                                          return Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(contract.status),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              _getStatusText(contract.status),
                                              style: const TextStyle(color: Colors.white),
                                              textAlign: TextAlign.center,
                                            ),
                                          );
                                        case 5:
                                          return Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.visibility),
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder: (dialogContext) =>
                                                        ContractDetailDialog(contract: contract),
                                                  );
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete),
                                                onPressed: () {
                                                  context
                                                      .read<ContractBloc>()
                                                      .add(DeleteContractEvent(contract.contractId));
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
                                    totalItems: _contracts.length,
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

  String _getStatusText(String status) {
    switch (status) {
      case 'ACTIVE':
        return 'Còn hiệu lực';
      case 'PENDING':
        return 'Chưa có hiệu lực';
      case 'EXPIRED':
        return 'Hết hạn';
      case 'TERMINATED':
        return 'Đã chấm dứt';
      default:
        return 'Không xác định';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return Colors.green;
      case 'PENDING':
        return Colors.yellow;
      case 'EXPIRED':
        return Colors.red;
      case 'TERMINATED':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}