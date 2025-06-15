import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../../common/widget/search_bar.dart';
import '../../../../../common/widget/filter_tab.dart';
import '../../../../../common/widget/pagination_controls.dart';
import '../../../../../common/widget/custom_data_table.dart';
import '../../../../../common/constants/colors.dart';
import '../../../domain/entities/area_entity.dart';
import '../../bloc/area_bloc/area_bloc.dart';
import '../../bloc/area_bloc/area_event.dart';
import '../../bloc/area_bloc/area_state.dart';
import '../area/create_area_dialog.dart';
import '../area/edit_area_dialog.dart';


class AreaListTab extends StatefulWidget {
  const AreaListTab({Key? key}) : super(key: key);

  @override
  _AreaListTabState createState() => _AreaListTabState();
}

class _AreaListTabState extends State<AreaListTab> with AutomaticKeepAliveClientMixin {
  int _currentPage = 1;
  static const int _limit = 12;
  String _filterStatus = 'All';
  String _searchQuery = '';
  List<AreaEntity> _areas = [];
  bool _isInitialLoad = true;
  final List<double> _columnWidths = [200.0, 80.0]; // Tên khu vực, Hành động

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadLocalData();
  }

  Future<void> _loadLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _currentPage = prefs.getInt('area_currentPage') ?? 1;
    _filterStatus = prefs.getString('area_filterStatus') ?? 'All';
    _searchQuery = prefs.getString('area_searchQuery') ?? '';
    String? areasJson = prefs.getString('areas');
    if (areasJson != null) {
      List<dynamic> areasList = jsonDecode(areasJson);
      setState(() {
        _areas = areasList.map((json) => AreaEntity.fromJson(json)).toList();
        _isInitialLoad = false;
      });
    } else {
      _fetchAreas();
    }
  }

  Future<void> _saveLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('area_currentPage', _currentPage);
    await prefs.setString('area_filterStatus', _filterStatus);
    await prefs.setString('area_searchQuery', _searchQuery);
    await prefs.setString('areas', jsonEncode(_areas.map((area) => area.toJson()).toList()));
  }

  void _fetchAreas() {
    context.read<AreaBloc>().add(FetchAreasEvent(page: 1, limit: 1000));
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
              body: BlocListener<AreaBloc, AreaState>(
                listener: (context, state) {
                  if (state.error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(' ${state.error!}')),
                    );
                  } else if (state is AreaDeleted) {
                    setState(() {
                      _areas = state.areas;
                    });
                    _saveLocalData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Xóa khu vực thành công!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } else if (state is AreaCreated || state is AreaUpdated) {
                    setState(() {
                      _areas = state.areas;
                    });
                    _saveLocalData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.successMessage ?? 'Thành công!'),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  } else if (state.areas.isNotEmpty) {
                    setState(() {
                      _areas = state.areas;
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
                                      label: 'Tất cả khu vực (${_areas.length})',
                                      isSelected: _filterStatus == 'All',
                                      onTap: () {
                                        setState(() {
                                          _filterStatus = 'All';
                                          _currentPage = 1;
                                          _saveLocalData();
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
                                    child: SearchBarTab(
                                      onChanged: (value) {
                                        setState(() {
                                          _searchQuery = value;
                                          _currentPage = 1;
                                          _saveLocalData();
                                        });
                                      },
                                      hintText: 'Tìm kiếm khu vực...',
                                      initialValue: _searchQuery,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Row(
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: _fetchAreas,
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
                                            builder: (context) => const CreateAreaDialog(),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        icon: const Icon(Icons.add),
                                        label: const Text('Thêm Khu vực'),
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
                          child: BlocBuilder<AreaBloc, AreaState>(
                            builder: (context, state) {
                              bool isLoading = state.isLoading;
                              String? errorMessage;

                              if (state.error != null) {
                                errorMessage = state.error;
                              }

                              List<AreaEntity> filteredAreas = _areas.where((area) {
                                bool matchesStatus = _filterStatus == 'All';
                                bool matchesSearch = _searchQuery.isEmpty ||
                                    area.name.toLowerCase().contains(_searchQuery.toLowerCase());
                                return matchesStatus && matchesSearch;
                              }).toList();

                              int startIndex = (_currentPage - 1) * _limit;
                              int endIndex = startIndex + _limit;
                              if (endIndex > filteredAreas.length) endIndex = filteredAreas.length;
                              List<AreaEntity> paginatedAreas = startIndex < filteredAreas.length
                                  ? filteredAreas.sublist(startIndex, endIndex)
                                  : [];

                              return isLoading && _isInitialLoad
                                  ? const Center(child: CircularProgressIndicator())
                                  : errorMessage != null
                                  ? Center(child: Text('Lỗi: $errorMessage'))
                                  : paginatedAreas.isEmpty
                                  ? const Center(child: Text('Không có khu vực nào'))
                                  : Column(
                                children: [
                                  GenericDataTable<AreaEntity>(
                                    headers: const ['Tên khu vực', ''],
                                    data: paginatedAreas,
                                    columnWidths: _columnWidths,
                                    cellBuilder: (area, index) {
                                      switch (index) {
                                        case 0:
                                          return Text(
                                            area.name,
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
                                                    builder: (context) => EditAreaDialog(area: area),
                                                  );
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete, color: Colors.black),
                                                onPressed: () {
                                                  context.read<AreaBloc>().add(DeleteAreaEvent(area.areaId));
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
                                    totalItems: filteredAreas.length,
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