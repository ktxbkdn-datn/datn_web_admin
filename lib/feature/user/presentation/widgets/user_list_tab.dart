import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../common/widget/custom_data_table.dart';
import '../../../../common/widget/pagination_controls.dart';
import '../../../../common/widget/search_bar.dart';
import '../../../../common/widget/filter_tab.dart';
import '../../../../common/constants/colors.dart';
import '../../data/model/user_model.dart';
import '../../domain/entities/user_entity.dart';
import '../bloc/user_bloc.dart';
import '../bloc/user_event.dart';
import '../bloc/user_state.dart';
import '../widgets/edit_user_dialog.dart';
import '../widgets/filter_dialog.dart';

class UserListTab extends StatefulWidget {
  const UserListTab({Key? key}) : super(key: key);

  @override
  _UserListTabState createState() => _UserListTabState();
}

class _UserListTabState extends State<UserListTab> {
  int _currentPage = 1;
  static const int _limit = 10;
  String _searchQuery = '';
  String? _emailFilter;
  String? _fullnameFilter;
  String? _phoneFilter;
  String? _classNameFilter;
  List<UserEntity> _users = [];
  int _totalItems = 0;
  final List<double> _columnWidths = [200.0, 200.0, 100.0];

  @override
  void initState() {
    super.initState();
    _loadLocalData();
    _fetchUsers();
  }

  Future<void> _loadLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentPage = prefs.getInt('user_currentPage') ?? 1;
      _searchQuery = prefs.getString('user_searchQuery') ?? '';
      _emailFilter = prefs.getString('user_emailFilter');
      _fullnameFilter = prefs.getString('user_fullnameFilter');
      _phoneFilter = prefs.getString('user_phoneFilter');
      _classNameFilter = prefs.getString('user_classNameFilter');
    });
    _fetchUsers();
  }

  Future<void> _saveLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_currentPage', _currentPage);
    await prefs.setString('user_searchQuery', _searchQuery);
    if (_emailFilter != null) {
      await prefs.setString('user_emailFilter', _emailFilter!);
    } else {
      await prefs.remove('user_emailFilter');
    }
    if (_fullnameFilter != null) {
      await prefs.setString('user_fullnameFilter', _fullnameFilter!);
    } else {
      await prefs.remove('user_fullnameFilter');
    }
    if (_phoneFilter != null) {
      await prefs.setString('user_phoneFilter', _phoneFilter!);
    } else {
      await prefs.remove('user_phoneFilter');
    }
    if (_classNameFilter != null) {
      await prefs.setString('user_classNameFilter', _classNameFilter!);
    } else {
      await prefs.remove('user_classNameFilter');
    }
  }

  void _fetchUsers() {
    context.read<UserBloc>().add(FetchUsersEvent(
      page: _currentPage,
      limit: _limit,
      email: _emailFilter,
      fullname: _fullnameFilter,
      phone: _phoneFilter,
      className: _classNameFilter,
    ));
  }

  void _applyFilters(String? email, String? fullname, String? phone, String? className) {
    setState(() {
      _emailFilter = email?.isNotEmpty == true ? email : null;
      _fullnameFilter = fullname?.isNotEmpty == true ? fullname : null;
      _phoneFilter = phone?.isNotEmpty == true ? phone : null;
      _classNameFilter = className?.isNotEmpty == true ? className : null;
      _currentPage = 1;
      _saveLocalData();
      _fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  BlocListener<UserBloc, UserState>(
                    listener: (context, state) {
                      if (state is UserError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Lỗi: ${state.message}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } else if (state is UserDeleted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Xóa sinh viên thành công!'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else if (state is UserCreated) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tạo sinh viên thành công!'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else if (state is UserUpdated) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cập nhật sinh viên thành công!'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else if (state is UserLoaded) {
                        setState(() {
                          _users = state.users;
                          _totalItems = state.totalItems;
                        });
                        _saveLocalData();
                      }
                    },
                  ),
                ],
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
                                    label: 'Tất cả sinh viên ($_totalItems)',
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
                                        _fetchUsers();
                                      });
                                    },
                                    hintText: 'Tìm kiếm sinh viên...',
                                    initialValue: _searchQuery,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                BlocBuilder<UserBloc, UserState>(
                                  builder: (context, state) {
                                    bool isLoading = state is UserLoading;
                                    return Row(
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: isLoading ? null : _fetchUsers,
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
                                          onPressed: isLoading
                                              ? null
                                              : () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) => FilterDialog(
                                                      onApply: _applyFilters,
                                                      initialEmail: _emailFilter,
                                                      initialFullname: _fullnameFilter,
                                                      initialPhone: _phoneFilter,
                                                      initialClassName: _classNameFilter,
                                                    ),
                                                  );
                                                },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          icon: const Icon(Icons.filter_list),
                                          label: const Text('Lọc'),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        child: BlocBuilder<UserBloc, UserState>(
                          builder: (context, state) {
                            bool isLoading = state is UserLoading;
                            String? errorMessage;

                            if (state is UserError) {
                              errorMessage = state.message;
                            }

                            return isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : errorMessage != null
                                    ? Center(child: Text('Lỗi: $errorMessage'))
                                    : _users.isEmpty
                                        ? const Center(child: Text('Không tìm thấy người dùng nào'))
                                        : Column(
                                            children: [
                                              GenericDataTable<UserEntity>(
                                                headers: const [
                                                  'Họ và Tên',
                                                  'Email',
                                                  '',
                                                ],
                                                data: _users,
                                                columnWidths: _columnWidths,
                                                cellBuilder: (user, index) {
                                                  switch (index) {
                                                    case 0:
                                                      return Text(
                                                        user.fullname,
                                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                                        overflow: TextOverflow.ellipsis,
                                                        textAlign: TextAlign.center,
                                                      );
                                                    case 1:
                                                      return Text(
                                                        user.email,
                                                        style: const TextStyle(fontSize: 14),
                                                        overflow: TextOverflow.ellipsis,
                                                        textAlign: TextAlign.center,
                                                      );
                                                    case 2:
                                                      return Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          IconButton(
                                                            icon: const Icon(Icons.edit, color: Colors.black),
                                                            onPressed: () {
                                                              showDialog(
                                                                context: context,
                                                                builder: (context) => EditUserDialog(user: user),
                                                              );
                                                            },
                                                          ),
                                                          IconButton(
                                                            icon: const Icon(Icons.delete, color: Colors.black),
                                                            onPressed: () {
                                                              context.read<UserBloc>().add(DeleteUserEvent(user.userId));
                                                            },
                                                          ),
                                                        ],
                                                      );
                                                    default:
                                                      return const SizedBox();
                                                  }
                                                },
                                              ),
                                              const SizedBox(height: 16),
                                              PaginationControls(
                                                currentPage: _currentPage,
                                                totalItems: _totalItems,
                                                limit: _limit,
                                                onPageChanged: (page) {
                                                  setState(() {
                                                    _currentPage = page;
                                                    _saveLocalData();
                                                    _fetchUsers();
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
      ],
    );
  }
}