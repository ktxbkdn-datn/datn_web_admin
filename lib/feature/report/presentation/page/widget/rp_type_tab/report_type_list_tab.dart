import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../../../../../common/constants/colors.dart';
import '../../../../../../common/widget/custom_data_table.dart';
import '../../../../../../common/widget/filter_tab.dart';
import '../../../../../../common/widget/pagination_controls.dart';
import '../../../../../../common/widget/search_bar.dart';
import '../../../../domain/entities/report_type_entity.dart';
import '../../../bloc/rp_type/rp_type_bloc.dart';
import '../../../bloc/rp_type/rp_type_event.dart';
import '../../../bloc/rp_type/rp_type_state.dart';
import 'create_report_type_dialog.dart';
import 'edit_report_type_dialog.dart';

class ReportTypeListTab extends StatefulWidget {
  const ReportTypeListTab({Key? key}) : super(key: key);

  @override
  _ReportTypeListTabState createState() => _ReportTypeListTabState();
}

class _ReportTypeListTabState extends State<ReportTypeListTab> with AutomaticKeepAliveClientMixin {
  int _currentPage = 1;
  static const int _limit = 12;
  String _searchQuery = '';
  List<ReportTypeEntity> _reportTypes = [];
  bool _isInitialLoad = true;
  final List<double> _columnWidths = [300.0, 80.0]; // Tên Loại Báo cáo, Hành động

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadLocalData();
  }

  Future<void> _loadLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _currentPage = prefs.getInt('reportTypeCurrentPage') ?? 1;
    _searchQuery = prefs.getString('reportTypeSearchQuery') ?? '';
    String? reportTypesJson = prefs.getString('reportTypes');
    if (reportTypesJson != null) {
      List<dynamic> reportTypesList = jsonDecode(reportTypesJson);
      setState(() {
        _reportTypes = reportTypesList.map((json) => ReportTypeEntity.fromJson(json)).toList();
        _isInitialLoad = false;
      });
    } else {
      _fetchReportTypes();
    }
  }

  Future<void> _saveLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reportTypeCurrentPage', _currentPage);
    await prefs.setString('reportTypeSearchQuery', _searchQuery);
    await prefs.setString('reportTypes', jsonEncode(_reportTypes.map((type) => type.toJson()).toList()));
  }

  void _fetchReportTypes() {
    context.read<ReportTypeBloc>().add(const GetAllReportTypesEvent(page: 1, limit: 1000));
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
              body: BlocListener<ReportTypeBloc, ReportTypeState>(
                listener: (context, state) {
                  if (state is ReportTypeError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi: ${state.message}')),
                    );
                  } else if (state is ReportTypeDeleted) {
                    setState(() {
                      _reportTypes.removeWhere((type) => type.reportTypeId == state.reportTypeId);
                    });
                    _saveLocalData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Xóa loại báo cáo thành công!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } else if (state is ReportTypeCreated) {
                    setState(() {
                      _reportTypes = (state as ReportTypeCreated).reportTypes;
                    });
                    _saveLocalData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tạo loại báo cáo thành công!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } else if (state is ReportTypeUpdated) {
                    setState(() {
                      _reportTypes = (state as ReportTypeUpdated).reportTypes;
                    });
                    _saveLocalData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cập nhật loại báo cáo thành công!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } else if (state is ReportTypesLoaded) {
                    setState(() {
                      _reportTypes = state.reportTypes;
                      _isInitialLoad = false;
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
                                      label: 'Tất cả loại báo cáo (${_reportTypes.length})',
                                      isSelected: true,
                                      onTap: () {},
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
                                          _saveLocalData();
                                        });
                                      },
                                      hintText: 'Tìm kiếm loại báo cáo...',
                                      initialValue: _searchQuery,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Row(
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: _fetchReportTypes,
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
                                            builder: (context) => const CreateReportTypeDialog(),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        icon: const Icon(Icons.add),
                                        label: const Text('Thêm Loại Báo cáo'),
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
                          child: BlocBuilder<ReportTypeBloc, ReportTypeState>(
                            builder: (context, state) {
                              bool isLoading = state is ReportTypeLoading;
                              String? errorMessage;

                              if (state is ReportTypeError) {
                                errorMessage = state.message;
                              }

                              List<ReportTypeEntity> filteredReportTypes = _reportTypes.where((type) {
                                bool matchesSearch = _searchQuery.isEmpty ||
                                    type.name.toLowerCase().contains(_searchQuery.toLowerCase());
                                return matchesSearch;
                              }).toList();

                              int startIndex = (_currentPage - 1) * _limit;
                              int endIndex = startIndex + _limit;
                              if (endIndex > filteredReportTypes.length) endIndex = filteredReportTypes.length;
                              List<ReportTypeEntity> paginatedReportTypes = startIndex < filteredReportTypes.length
                                  ? filteredReportTypes.sublist(startIndex, endIndex)
                                  : [];

                              return isLoading && _isInitialLoad
                                  ? const Center(child: CircularProgressIndicator())
                                  : errorMessage != null
                                  ? Center(child: Text('Lỗi: $errorMessage'))
                                  : paginatedReportTypes.isEmpty
                                  ? const Center(child: Text('Không có loại báo cáo nào'))
                                  : Column(
                                children: [
                                  GenericDataTable<ReportTypeEntity>(
                                    headers: const ['Tên Loại Báo cáo', ''],
                                    data: paginatedReportTypes,
                                    columnWidths: _columnWidths,
                                    cellBuilder: (reportType, index) {
                                      switch (index) {
                                        case 0:
                                          return Text(
                                            reportType.name,
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                          );
                                        case 1:
                                          return Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit, color: Colors.black),
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) => EditReportTypeDialog(reportType: reportType),
                                                  );
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete, color: Colors.black),
                                                onPressed: () {
                                                  context.read<ReportTypeBloc>().add(DeleteReportTypeEvent(reportTypeId: reportType.reportTypeId));
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
                                    totalItems: filteredReportTypes.length,
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