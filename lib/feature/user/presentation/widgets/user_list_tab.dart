import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../common/widget/custom_data_table.dart';
import '../../../../common/widget/pagination_controls.dart';
import '../../../../common/widget/search_bar.dart';
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
  static const int _limit = 12;
  String _searchQuery = '';
  List<UserModel> _users = [];
  bool _isInitialLoad = true;
  final List<double> _columnWidths = [200.0, 200.0, 100.0]; // Họ và Tên, Email, Hành động

  @override
  void initState() {
    super.initState();
    _loadLocalData();
    context.read<UserBloc>().add(FetchUsersEvent(page: 1, limit: 1000));
  }

  Future<void> _loadLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _currentPage = prefs.getInt('user_currentPage') ?? 1;
    _searchQuery = prefs.getString('user_searchQuery') ?? '';
    String? usersJson = prefs.getString('users');
    if (usersJson != null) {
      List<dynamic> usersList = jsonDecode(usersJson);
      setState(() {
        _users = usersList.map((json) => UserModel.fromJson(json)).toList();
      });
    }
  }

  Future<void> _saveLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_currentPage', _currentPage);
    await prefs.setString('user_searchQuery', _searchQuery);
  }

  void _fetchUsers() {
    context.read<UserBloc>().add(FetchUsersEvent(page: 1, limit: 1000));
  }

  String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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
              body: BlocListener<UserBloc, UserState>(
                listener: (context, state) {
                  // Không cần đóng dialog ở đây, để EditUserDialog tự xử lý
                },
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
                                    hintText: 'Search users...',
                                    initialValue: _searchQuery,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                BlocBuilder<UserBloc, UserState>(
                                  builder: (context, state) {
                                    bool isLoading = state.isLoading;
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
                                          label: const Text('Refresh'),
                                        ),
                                        const SizedBox(width: 10),
                                        ElevatedButton.icon(
                                          onPressed: isLoading
                                              ? null
                                              : () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => const FilterDialog(),
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
                            bool isLoading = state.isLoading;
                            String? errorMessage;

                            if (state.users.isNotEmpty) {
                              _users = state.users.map((user) => UserModel(
                                userId: user.userId,
                                fullname: user.fullname,
                                email: user.email,
                                phone: user.phone,
                                dateOfBirth: user.dateOfBirth,
                                cccd: user.cccd,
                                className: user.className,
                                createdAt: user.createdAt,
                                isDeleted: user.isDeleted,
                                deletedAt: user.deletedAt,
                                version: user.version,
                              )).toList();
                              _isInitialLoad = false;
                              _saveLocalData();
                            } else if (state.error != null) {
                              errorMessage = state.error;
                            }

                            List<UserModel> filteredUsers = _users.where((user) {
                              bool matchesSearch = _searchQuery.isEmpty ||
                                  user.fullname.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                                  user.email.toLowerCase().contains(_searchQuery.toLowerCase());
                              return matchesSearch;
                            }).toList();

                            int startIndex = (_currentPage - 1) * _limit;
                            int endIndex = startIndex + _limit;
                            if (endIndex > filteredUsers.length) endIndex = filteredUsers.length;
                            List<UserModel> paginatedUsers = startIndex < filteredUsers.length
                                ? filteredUsers.sublist(startIndex, endIndex)
                                : [];

                            return isLoading && _isInitialLoad
                                ? const Center(child: CircularProgressIndicator())
                                : errorMessage != null
                                ? Center(child: Text('Lỗi: $errorMessage'))
                                : paginatedUsers.isEmpty
                                ? const Center(child: Text('Không tìm thấy người dùng nào'))
                                : Column(
                              children: [
                                GenericDataTable<UserModel>(
                                  headers: const [
                                    'Họ và Tên',
                                    'Email',
                                    '',
                                  ],
                                  data: paginatedUsers,
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
                                  totalItems: filteredUsers.length,
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
      ],
    );
  }
}