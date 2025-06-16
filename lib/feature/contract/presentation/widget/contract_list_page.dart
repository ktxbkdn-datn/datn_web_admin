import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart'; // Add GetX import
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
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ContractListPage extends StatefulWidget {
  const ContractListPage({Key? key}) : super(key: key);

  @override
  _ContractListPageState createState() => _ContractListPageState();
}

class _ContractListPageState extends State<ContractListPage> with AutomaticKeepAliveClientMixin {
  int _currentPage = 1;
  static const int _limit = 10;
  String _searchQuery = '';
  List<Contract> _contracts = [];
  bool _isInitialLoad = true;
  int _totalItems = 0;
  bool _isSearching = false;
  final List<double> _columnWidths = [150.0, 150.0, 150.0, 150.0, 150.0, 100.0];

  // Thay thế các tham số truyền vào bằng state nội bộ
  bool _showAll = true;
  bool _showExpired = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadLocalData();
    _fetchContracts();
  }

  Future<void> _loadLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _currentPage = prefs.getInt('contractCurrentPage') ?? 1;
    _searchQuery = prefs.getString('contractSearchQuery') ?? '';
    String? contractsJson = prefs.getString('contracts');
    if (contractsJson != null) {
      List<dynamic> contractsList = jsonDecode(contractsJson);
      setState(() {
        _contracts = contractsList.map((json) => Contract.fromJson(json)).toList();
      });
    }
  }

  Future<void> _saveLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('contractCurrentPage', _currentPage);
    await prefs.setString('contractSearchQuery', _searchQuery);
    await prefs.setString('contracts', jsonEncode(_contracts.map((contract) => contract.toJson()).toList()));
  }

  void _fetchContracts({String? status}) {
    context.read<ContractBloc>().add(FetchAllContractsEvent(
      page: _currentPage,
      limit: _limit,
      email: _searchQuery.isNotEmpty ? _searchQuery : null,
      status: status,
    ));
  }

  bool _isExpiringSoon(String endDate) {
    DateTime end = DateTime.parse(endDate);
    DateTime now = DateTime.now();
    DateTime fifteenDaysFromNow = now.add(const Duration(days: 15));
    return end.isAfter(now) && end.isBefore(fifteenDaysFromNow);
  }

  void _onTabChanged({required bool showAll, required bool showExpired}) {
    setState(() {
      _showAll = showAll;
      _showExpired = showExpired;
      _currentPage = 1;
    });
    _fetchContracts(status: showAll ? null : showExpired ? null : 'ACTIVE');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final screenWidth = MediaQuery.of(context).size.width;
    final paddingHorizontal = screenWidth > 1200 ? screenWidth * 0.1 : 8.0;

    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
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
                  BlocListener<ContractBloc, ContractState>(
                    listener: (context, state) {
                      if (state is ContractError) {
                        if (!_isSearching) {
                          Get.snackbar(
                            'Lỗi',
                            state.errorMessage,
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            margin: const EdgeInsets.all(16),
                            duration: const Duration(seconds: 1),
                          );
                        }
                      } else if (state is ContractDeleted) {
                        setState(() {
                          _contracts = state.contracts;
                        });
                        _saveLocalData();
                        Get.snackbar(
                          'Thành công',
                          state.successMessage,
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                          margin: const EdgeInsets.all(16),
                          duration: const Duration(seconds: 2),
                        );
                        _fetchContracts(status: _showAll ? null : _showExpired ? null : 'ACTIVE');
                      } else if (state is ContractListLoaded) {
                        setState(() {
                          _contracts = state.contracts;
                          _totalItems = state.totalItems;
                          _isInitialLoad = false;
                        });
                        _saveLocalData();
                      } else if (state is ContractStatusUpdated) {
                        Get.snackbar(
                          'Thành công',
                          state.successMessage,
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                          margin: const EdgeInsets.all(16),
                          duration: const Duration(seconds: 2),
                        );
                        _fetchContracts();
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
                                      label: 'Tất cả ($_totalItems)',
                                      isSelected: _showAll,
                                      onTap: () {
                                        _onTabChanged(showAll: true, showExpired: false);
                                      },
                                    ),
                                    const SizedBox(width: 10),
                                    FilterTab(
                                      label: 'Còn hiệu lực',
                                      isSelected: !_showExpired && !_showAll,
                                      onTap: () {
                                        _onTabChanged(showAll: false, showExpired: false);
                                      },
                                    ),
                                    const SizedBox(width: 10),
                                    FilterTab(
                                      label: 'Sắp đáo hạn',
                                      isSelected: _showExpired,
                                      onTap: () {
                                        _onTabChanged(showAll: false, showExpired: true);
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
                                    child: SearchBarTab(
                                      onChanged: (value) {
                                        setState(() {
                                          _searchQuery = value;
                                          _currentPage = 1;
                                          _isSearching = true;
                                          _saveLocalData();
                                        });
                                        _fetchContracts();
                                      },
                                      hintText: 'Tìm kiếm theo email người dùng',
                                      initialValue: _searchQuery,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Row(
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () => _fetchContracts(),
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
                                        label: const Text('Tạo hợp đồng'),
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
                                errorMessage = "Tải lại dữ liệu";
                              }

                              List<Contract> displayContracts = _contracts;
                              if (_showExpired) {
                                displayContracts = _contracts.where((contract) => _isExpiringSoon(contract.endDate)).toList();
                              }

                              List<Contract> filteredContracts = displayContracts.where((contract) {
                                bool matchesSearch = _searchQuery.isEmpty ||
                                    (contract.userEmail?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
                                return matchesSearch;
                              }).toList();

                              return isLoading && _isInitialLoad
                                  ? const Center(child: CircularProgressIndicator())
                                  : errorMessage != null
                                      ? const SizedBox()
                                      : filteredContracts.isEmpty
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
                                                  data: filteredContracts,
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
                                                  totalItems: _totalItems,
                                                  limit: _limit,
                                                  onPageChanged: (page) {
                                                    setState(() {
                                                      _currentPage = page;
                                                      _saveLocalData();
                                                    });
                                                    _fetchContracts(status: _showAll ? null : _showExpired ? null : 'ACTIVE');
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