import 'package:datn_web_admin/common/constants/colors.dart';
import 'package:datn_web_admin/common/constants/image_string.dart';
import 'package:datn_web_admin/feature/auth/presentation/bloc/auth_event.dart';
import 'package:datn_web_admin/feature/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:iconsax/iconsax.dart';
import 'package:datn_web_admin/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/widgets/stat_page/room_stat_page.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/widgets/stat_page/user_stat_page.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/widgets/stat_page/report_stat_page.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:async';

// Import các tab con trực tiếp
import '../../../admin/presentation/pages/widgets/current_admin_tab.dart';
import '../../../admin/presentation/pages/admin_list_page.dart';
import '../../../admin/presentation/pages/widgets/create_admin_tab.dart';
import '../../../admin/presentation/pages/widgets/change_password_tab.dart';
import '../../../user/presentation/widgets/user_list_tab.dart';
import '../../../user/presentation/widgets/create_user_tab.dart';
import '../../../room/presentations/widget/room/room_list_page.dart';
import '../../../room/presentations/widget/area/area_list_tab.dart';
import '../../../contract/presentation/widget/contract_list_page.dart';
import '../../../report/presentation/page/widget/report_tab/report_list_page.dart';
import '../../../report/presentation/page/widget/rp_type_tab/report_type_list_tab.dart';
import '../../../register/presentation/widget/registration_list_page.dart';
import '../../../service/presentation/page/widget/service_list_page.dart';
import '../../../bill/presentation/page/widget/monthly_bill/monthly_bill_list_page.dart';
import '../../../bill/presentation/page/widget/bill_meter_details/bill_detail_list_page.dart';
import '../../../notification/presentation/pages/noti_tab/notification_list_page.dart';
import 'dashboard_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SideMenuController _sideMenuController = SideMenuController();
  int _selectedIndex = 0;
  bool _isLoading = false; // Thêm biến loading
  bool _sessionExpired = false;

  late List<Widget> _tabs;

  // Badge state
  int _newRegistrationCount = 0;
  int _newReportCount = 0;
  Timer? _badgeTimer;

  void _updateIndex(int index) {
  setState(() {
    _isLoading = true;
    _selectedIndex = index;
  });
  
  Future.delayed(const Duration(milliseconds: 800), () {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  });
}

void _onTabLoaded() {
  if (mounted) {
    setState(() {
      _isLoading = false;
    });
  }
}

  List<SideMenuItemType> get _menuItems => [
    SideMenuItem(
      title: 'Trang chủ',
      icon: const Icon(Iconsax.home),
      onTap: (index, _) => _updateIndex(0),
    ),
    SideMenuExpansionItem(
      title: 'Quản lý Admin',
      icon: const Icon(Iconsax.user),
      children: [
        SideMenuItem(
          title: 'Thông tin Admin',
          icon: const Icon(Icons.person),
          onTap: (index, _) => _updateIndex(1),
        ),
        SideMenuItem(
          title: 'Danh sách Admin',
          icon: const Icon(Icons.list),
          onTap: (index, _) => _updateIndex(2),
        ),
        SideMenuItem(
          title: 'Tạo Admin',
          icon: const Icon(Icons.add),
          onTap: (index, _) => _updateIndex(3),
        ),
        SideMenuItem(
          title: 'Đổi mật khẩu',
          icon: const Icon(Icons.lock),
          onTap: (index, _) => _updateIndex(4),
        ),
      ],
    ),
    SideMenuExpansionItem(
      title: 'Sinh viên',
      icon: const Icon(Iconsax.people),
      children: [
        SideMenuItem(
          title: 'Danh sách Sinh viên',
          icon: const Icon(Icons.list),
          onTap: (index, _) => _updateIndex(5),
        ),
        SideMenuItem(
          title: 'Tạo Sinh viên',
          icon: const Icon(Icons.add),
          onTap: (index, _) => _updateIndex(6),
        ),
      ],
    ),
    SideMenuExpansionItem(
      title: 'Quản lý Phòng',
      icon: const Icon(Iconsax.home_1),
      children: [
        SideMenuItem(
          title: 'Danh sách Phòng',
          icon: const Icon(Icons.meeting_room),
          onTap: (index, _) => _updateIndex(7),
        ),
        SideMenuItem(
          title: 'Quản lý Khu vực',
          icon: const Icon(Icons.location_city),
          onTap: (index, _) => _updateIndex(8),
        ),
      ],
    ),
    SideMenuItem(
      title: 'Hợp đồng',
      icon: const Icon(Iconsax.document),
      onTap: (index, _) => _updateIndex(9),
    ),
    SideMenuItem(
      title: 'Đăng ký',
      icon: const Icon(Iconsax.path),
      onTap: (index, _) => _updateIndex(10),
    ),
    SideMenuExpansionItem(
      title: 'Báo cáo',
      icon: const Icon(Iconsax.ticket),
      children: [
        SideMenuItem(
          title: 'Danh sách Báo cáo',
          icon: const Icon(Iconsax.message_text),
          onTap: (index, _) => _updateIndex(11),
        ),
        SideMenuItem(
          title: 'Tạo Loại Báo cáo',
          icon: const Icon(Iconsax.message_add),
          onTap: (index, _) => _updateIndex(12),
        ),
      ],
    ),
    SideMenuItem(
      title: 'Thông báo',
      icon: const Icon(Iconsax.notification),
      onTap: (index, _) => _updateIndex(13),
    ),
    SideMenuExpansionItem(
      title: 'Hoá đơn tháng',
      icon: const Icon(Iconsax.receipt_1),
      children: [
        SideMenuItem(
          title: 'Danh sách Hoá đơn tháng',
          icon: const Icon(Iconsax.money),
          onTap: (index, _) => _updateIndex(15),
        ),
        SideMenuItem(
          title: 'Chi tiết chỉ số điện nước',
          icon: const Icon(Iconsax.paperclip),
          onTap: (index, _) => _updateIndex(16),
        ),
      ],
    ),
    SideMenuExpansionItem(
      title: 'Thống kê',
      icon: const Icon(Icons.bar_chart),
      children: [
        SideMenuItem(
          title: 'Thống kê phòng',
          icon: const Icon(Icons.house),
          onTap: (index, _) => _updateIndex(17),
        ),
        SideMenuItem(
          title: 'Tỉ lệ lấp đầy',
          icon: const Icon(Icons.people),
          onTap: (index, _) => _updateIndex(18),
        ),
        SideMenuItem(
          title: 'Thống kê báo cáo',
          icon: const Icon(Icons.report),
          onTap: (index, _) => _updateIndex(19),
        ),
      ],
    ),
    SideMenuItem(
      title: 'Đăng xuất',
      icon: const Icon(Iconsax.logout),
      onTap: (index, _) {
        // Safely handle logout to prevent animation/ticker issues
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Use the current BuildContext to ensure we're accessing the AuthBloc from the widget tree
          final authBloc = context.read<AuthBloc>();
          print('Logout requested from SideMenu');
          authBloc.add(LogoutSubmitted());
        });
      },
    ),
  ];

  @override
  void dispose() {
    _sideMenuController.dispose();
    _badgeTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _tabs = [
    DashboardPage(),                            // 0
    const CurrentAdminTab(),                    // 1
    const AdminListPage(),                      // 2
    CreateAdminTab(),                           // 3
    const ChangePasswordTab(),                  // 4
    UserListTab(),                              // 5
    const CreateUserTab(),                      // 6
    const RoomListPage(),                       // 7
    const AreaListTab(),                        // 8
    const ContractListPage(),                   // 9
    const RegistrationListPage(),               // 10
    const ReportListPage(),                     // 11
    const ReportTypeListTab(),                  // 12
    const NotificationListPage(),               // 13
    const ServiceListPage(),                    // 14
    const BillListPage(),                       // 15
    const BillDetailListPage(),                 // 16
    const RoomStatsPage(),                      // 17
    const UserStatsPage(),                      // 18
    const ReportStatsPage(),                    // 19
  ];
    _sideMenuController.addListener((index) {
      setState(() {
        _selectedIndex = index;
      });
    });
    _fetchBadgeCounts();
    _badgeTimer = Timer.periodic(const Duration(minutes: 5), (_) => _fetchBadgeCounts());
  }

  Future<void> _fetchBadgeCounts() async {
    // TODO: Replace with your actual API/Bloc calls
    // Fake fetch for demo, replace with real logic
    setState(() {
      _newRegistrationCount = 3; // fetch from RegistrationBloc or API
      _newReportCount = 5; // fetch from ReportBloc or API
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Lắng nghe khi hết phiên đăng nhập
        if (state.auth == null &&
            (state.successMessage == "Vui lòng đăng nhập lại" ||
             state.error == "Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.")) {
          setState(() {
            _sessionExpired = true;
          });
        }
      },
      child: _sessionExpired
          ? Center(
              child: Container(
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_outline, size: 64, color: Colors.redAccent),
                    const SizedBox(height: 24),
                    const Text(
                      'Phiên đăng nhập đã hết hạn.\nVui lòng đăng nhập lại!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, color: Colors.black87),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                      },
                      child: const Text('Đến trang đăng nhập'),
                    ),
                  ],
                ),
              ),
            )
          : Scaffold(
              body: Row(
                children: [
                  SideMenu(
                    controller: _sideMenuController,
                    style: SideMenuStyle(
                      displayMode: SideMenuDisplayMode.auto,
                      showHamburger: true,
                      hoverColor: Colors.blueGrey[700],
                      selectedColor: Colors.transparent,
                      selectedTitleTextStyle: const TextStyle(color: Colors.white),
                      selectedIconColor: Colors.white,
                      backgroundColor: Colors.black87,
                      unselectedIconColor: Colors.white,
                      unselectedTitleTextStyle: const TextStyle(color: Colors.white),
                      openSideMenuWidth: 220,
                      compactSideMenuWidth: 60,
                      toggleColor: Colors.black,
                    ),
                    title: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: Text(
                          'Quản lý Ký túc xá',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    items: _menuItems,
                  ),
                  const VerticalDivider(thickness: 1, width: 2, color: Colors.white,),
                  Expanded(
                    child: _isLoading
                        ? Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.glassmorphismStart, AppColors.glassmorphismEnd],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        ktxLogo, // Đường dẫn tới ảnh của bạn
                                        width: 360,
                                        height: 360,
                                        fit: BoxFit.contain,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 32),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      LoadingAnimationWidget.staggeredDotsWave(
                                        color: Colors.white,
                                        size: 180,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                        : _tabs[_selectedIndex],
                  ),
                ],
              ),
            ),
    );
  }
}