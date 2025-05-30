import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../../common/widget/custom_data_table.dart';
import '../../../../../common/widget/filter_tab.dart';
import '../../../../../common/widget/pagination_controls.dart';
import '../../../../../common/widget/search_bar.dart';
import '../../../../../common/constants/colors.dart';
import '../../../domain/entities/notification_type_entity.dart';
import '../../bloc/noti_type/notification_type_bloc.dart';
import '../../bloc/noti_type/notification_type_event.dart';
import '../../bloc/noti_type/notification_type_state.dart';
import 'create_notification_type_dialog.dart';
import 'edit_notification_type_dialog.dart';

class NotificationTypeListTab extends StatefulWidget {
  const NotificationTypeListTab({Key? key}) : super(key: key);

  @override
  _NotificationTypeListTabState createState() => _NotificationTypeListTabState();
}

class _NotificationTypeListTabState extends State<NotificationTypeListTab> with AutomaticKeepAliveClientMixin {
  int _currentPage = 1;
  static const int _limit = 12;
  String _searchQuery = '';
  List<NotificationType> _notificationTypes = [];
  bool _isInitialLoad = true;
  final List<double> _columnWidths = [300.0, 80.0]; // Tên Loại Thông báo, Hành động

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadLocalData();
  }

  Future<void> _loadLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _currentPage = prefs.getInt('notificationTypeCurrentPage') ?? 1;
    _searchQuery = prefs.getString('notificationTypeSearchQuery') ?? '';
    String? notificationTypesJson = prefs.getString('notificationTypes');
    if (notificationTypesJson != null) {
      List<dynamic> notificationTypesList = jsonDecode(notificationTypesJson);
      setState(() {
        _notificationTypes = notificationTypesList.map((json) => NotificationType.fromJson(json)).toList();
        _isInitialLoad = false;
      });
    } else {
      _fetchNotificationTypes();
    }
  }

  Future<void> _saveLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notificationTypeCurrentPage', _currentPage);
    await prefs.setString('notificationTypeSearchQuery', _searchQuery);
    await prefs.setString('notificationTypes', jsonEncode(_notificationTypes.map((type) => type.toJson()).toList()));
  }

  void _fetchNotificationTypes() {
    context.read<NotificationTypeBloc>().add(const GetAllNotificationTypesEvent(page: 1, limit: 1000));
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
              body: BlocListener<NotificationTypeBloc, NotificationTypeState>(
                listener: (context, state) {
                  if (state is NotificationTypeError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi: ${state.message}')),
                    );
                  } else if (state is NotificationTypeDeleted) {
                    setState(() {
                      _notificationTypes.removeWhere((type) => type.typeId == state.typeId);
                    });
                    _saveLocalData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Xóa loại thông báo thành công!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } else if (state is NotificationTypeCreated) {
                    setState(() {
                      _notificationTypes.add(state.type);
                    });
                    _saveLocalData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tạo loại thông báo thành công!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } else if (state is NotificationTypeUpdated) {
                    setState(() {
                      final index = _notificationTypes.indexWhere((type) => type.typeId == state.type.typeId);
                      if (index != -1) {
                        _notificationTypes[index] = state.type;
                      }
                    });
                    _saveLocalData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cập nhật loại thông báo thành công!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } else if (state is NotificationTypesLoaded) {
                    setState(() {
                      _notificationTypes = state.types;
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
                                      label: 'Tất cả loại thông báo (${_notificationTypes.length})',
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
                                      hintText: 'Tìm kiếm loại thông báo...',
                                      initialValue: _searchQuery,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Row(
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: _fetchNotificationTypes,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        icon: const Icon(Icons.refresh),
                                        label: const Text('Refresh'),
                                      ),
                                      const SizedBox(width: 10),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => const CreateNotificationTypeDialog(),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        icon: const Icon(Icons.add),
                                        label: const Text('Thêm Loại Thông báo'),
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
                          child: BlocBuilder<NotificationTypeBloc, NotificationTypeState>(
                            builder: (context, state) {
                              bool isLoading = state is NotificationTypeLoading;
                              String? errorMessage;

                              if (state is NotificationTypeError) {
                                errorMessage = state.message;
                              }

                              List<NotificationType> filteredNotificationTypes = _notificationTypes.where((type) {
                                bool matchesSearch = _searchQuery.isEmpty ||
                                    type.name.toLowerCase().contains(_searchQuery.toLowerCase());
                                return matchesSearch;
                              }).toList();

                              int startIndex = (_currentPage - 1) * _limit;
                              int endIndex = startIndex + _limit;
                              if (endIndex > filteredNotificationTypes.length) endIndex = filteredNotificationTypes.length;
                              List<NotificationType> paginatedNotificationTypes = startIndex < filteredNotificationTypes.length
                                  ? filteredNotificationTypes.sublist(startIndex, endIndex)
                                  : [];

                              return isLoading && _isInitialLoad
                                  ? const Center(child: CircularProgressIndicator())
                                  : errorMessage != null
                                  ? Center(child: Text('Lỗi: $errorMessage'))
                                  : paginatedNotificationTypes.isEmpty
                                  ? const Center(child: Text('Không có loại thông báo nào'))
                                  : Column(
                                children: [
                                  GenericDataTable<NotificationType>(
                                    headers: const ['Tên Loại Thông báo', ''],
                                    data: paginatedNotificationTypes,
                                    columnWidths: _columnWidths,
                                    cellBuilder: (notificationType, index) {
                                      switch (index) {
                                        case 0:
                                          return Text(
                                            notificationType.name,
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
                                                    builder: (context) => EditNotificationTypeDialog(notificationType: notificationType),
                                                  );
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete, color: Colors.black),
                                                onPressed: () {
                                                  context.read<NotificationTypeBloc>().add(DeleteNotificationTypeEvent(typeId: notificationType.typeId!));
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
                                    totalItems: filteredNotificationTypes.length,
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