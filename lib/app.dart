// lib/src/app.dart
import 'package:datn_web_admin/feature/admin/presentation/pages/admin_management_page.dart';
import 'package:datn_web_admin/feature/auth/presentation/bloc/auth_state.dart';
import 'package:datn_web_admin/feature/bill/presentation/bloc/bill_bloc.dart';
import 'package:datn_web_admin/feature/bill/presentation/page/bill_management_page.dart';
import 'package:datn_web_admin/feature/contract/presentation/bloc/contract_bloc.dart';
import 'package:datn_web_admin/feature/contract/presentation/page/contract_management_page.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/bloc/statistic_bloc.dart';
import 'package:datn_web_admin/feature/notification/presentation/bloc/noti/notification_bloc.dart';
import 'package:datn_web_admin/feature/notification/presentation/bloc/noti_media/notification_media_bloc.dart';
import 'package:datn_web_admin/feature/notification/presentation/bloc/noti_type/notification_type_bloc.dart';
import 'package:datn_web_admin/feature/notification/presentation/pages/notification_management_page.dart';
import 'package:datn_web_admin/feature/register/presentation/bloc/registration_bloc.dart';
import 'package:datn_web_admin/feature/register/presentation/page/registration_management_page.dart';
import 'package:datn_web_admin/feature/report/presentation/bloc/report/report_bloc.dart';
import 'package:datn_web_admin/feature/report/presentation/bloc/rp_image/rp_image_bloc.dart';
import 'package:datn_web_admin/feature/report/presentation/page/report_management_page.dart';
import 'package:datn_web_admin/feature/room/presentations/bloc/area_bloc/area_bloc.dart';
import 'package:datn_web_admin/feature/room/presentations/bloc/room_bloc/room_bloc.dart';
import 'package:datn_web_admin/feature/room/presentations/bloc/room_image_bloc/room_image_bloc.dart';
import 'package:datn_web_admin/feature/service/presentation/bloc/service_bloc.dart';
import 'package:datn_web_admin/feature/service/presentation/page/service_management_page.dart';
import 'package:datn_web_admin/feature/user/presentation/bloc/user_bloc.dart';
import 'package:datn_web_admin/src/core/di/injection.dart';
import 'package:datn_web_admin/src/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'feature/admin/presentation/bloc/admin_bloc.dart';
import 'feature/auth/presentation/bloc/auth_bloc.dart';
import 'feature/auth/presentation/pages/forgot_password_page.dart';
import 'feature/auth/presentation/pages/login_page.dart';
import 'feature/auth/presentation/pages/reset_password_page.dart';
import 'feature/dashboard/presentation/pages/dashboard_page.dart';
import 'feature/report/presentation/bloc/rp_type/rp_type_bloc.dart';
import 'feature/room/presentations/pages/room_management_page.dart';
import 'feature/user/presentation/pages/user_page.dart';
class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('App build started');
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (ctx) => getIt<AuthBloc>()),
        BlocProvider(create: (_) => getIt<AdminBloc>()),
        BlocProvider(create: (_) => getIt<UserBloc>()),
        BlocProvider(create: (_) => getIt<RoomBloc>()),
        BlocProvider(create: (_) => getIt<AreaBloc>()),
        BlocProvider(create: (_) => getIt<RoomImageBloc>()),
        BlocProvider(create: (_) => getIt<RegistrationBloc>()),
        BlocProvider(create: (_) => getIt<ContractBloc>()),
        BlocProvider(create: (_) => getIt<ServiceBloc>()),
        BlocProvider(create: (_) => getIt<BillBloc>()),
        BlocProvider(create: (_) => getIt<ReportBloc>()),
        BlocProvider(create: (_) => getIt<ReportImageBloc>()),
        BlocProvider(create: (_) => getIt<ReportTypeBloc>()),
        BlocProvider(create: (_) => getIt<NotificationBloc>()),
        BlocProvider(create: (_) => getIt<NotificationMediaBloc>()),
        BlocProvider(create: (_) => getIt<NotificationTypeBloc>()),
        BlocProvider(create: (_) => getIt<StatisticsBloc>()),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.auth == null && state.successMessage == 'Vui lòng đăng nhập lại') {
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Vui lòng đăng nhập lại'), backgroundColor: Colors.red),
            );
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
          }
        },
        child: GetMaterialApp(
          title: 'Quản Lý Ký Túc Xá - DHBK-DHDN',
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          initialRoute: '/login',
          routes: {
            '/login': (_) => const LoginPage(),
            '/forgot-password': (_) => const ForgotPasswordPage(),
            '/reset-password': (_) => const ResetPasswordPage(),
            '/dashboard': (_) => const DashboardPage(),
            '/admin-management': (_) => const AdminManagementPage(),
            '/users': (_) => const UserPage(),
            '/rooms': (_) => const RoomManagementPage(),
            '/registrations': (_) => const RegistrationManagementPage(),
            '/contracts': (_) => const ContractManagementPage(),
            '/services': (_) => const ServiceManagementPage(),
            '/bills': (_) => const BillManagementPage(),
            '/reports': (_) => const ReportManagementPage(),
            '/notifications': (_) => const NotificationManagementPage(),
          },
        ),
      ),
    );
  }
}

