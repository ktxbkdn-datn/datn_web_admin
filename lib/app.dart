// lib/src/app.dart

import 'package:datn_web_admin/feature/auth/presentation/bloc/auth_state.dart';
import 'package:datn_web_admin/feature/bill/presentation/bloc/bill_bloc.dart';
import 'package:datn_web_admin/feature/contract/presentation/bloc/contract_bloc.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/bloc/statistic_bloc.dart';
import 'package:datn_web_admin/feature/dashboard/presentation/pages/home_page.dart';
import 'package:datn_web_admin/feature/notification/presentation/bloc/noti/notification_bloc.dart';
import 'package:datn_web_admin/feature/notification/presentation/bloc/noti_media/notification_media_bloc.dart';
import 'package:datn_web_admin/feature/notification/presentation/bloc/noti_type/notification_type_bloc.dart';
import 'package:datn_web_admin/feature/register/presentation/bloc/registration_bloc.dart';
import 'package:datn_web_admin/feature/register/presentation/widget/registration_list_page.dart';
import 'package:datn_web_admin/feature/report/presentation/bloc/report/report_bloc.dart';
import 'package:datn_web_admin/feature/report/presentation/bloc/rp_image/rp_image_bloc.dart';
import 'package:datn_web_admin/feature/report/presentation/page/widget/report_tab/report_list_page.dart';
import 'package:datn_web_admin/feature/room/presentations/bloc/area_bloc/area_bloc.dart';
import 'package:datn_web_admin/feature/room/presentations/bloc/room_bloc/room_bloc.dart';
import 'package:datn_web_admin/feature/room/presentations/bloc/room_image_bloc/room_image_bloc.dart';
import 'package:datn_web_admin/feature/service/presentation/bloc/service_bloc.dart';
import 'package:datn_web_admin/feature/user/presentation/bloc/user_bloc.dart';
import 'package:datn_web_admin/src/core/di/injection.dart';
import 'package:datn_web_admin/src/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'feature/admin/presentation/bloc/admin_bloc.dart';
import 'feature/auth/presentation/bloc/auth_bloc.dart';
import 'feature/auth/presentation/pages/forgot_password_page.dart';
import 'feature/auth/presentation/pages/login_page.dart';
import 'feature/auth/presentation/pages/reset_password_page.dart';
import 'feature/report/presentation/bloc/rp_type/rp_type_bloc.dart';

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
      ],      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          final currentRoute = Get.currentRoute;
          
          // Handle both session expiry and manual logout
          if (state.auth == null) {
            // Don't redirect if already on these routes
            if (currentRoute != '/login' && 
                currentRoute != '/forgot-password' && 
                currentRoute != '/reset-password') {
              
              // If it's a logout success message or session expiry
              if (state.successMessage == 'Đăng xuất thành công' ||
                  state.successMessage == 'Vui lòng đăng nhập lại') {
                print('Redirecting to login page after: ${state.successMessage}');
                // Use a safer approach to navigation that ensures proper cleanup
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  // Use Get.offAllNamed instead of Navigator for more consistent navigation
                  Get.offAllNamed('/login');
                });
              }
            }
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
            '/reports': (_) => const ReportListPage(),
            '/registrations': (_) => const RegistrationListPage(),
            '/home': (_) => const HomePage(),
          },
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            MonthYearPickerLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('vi', 'VN'),
            Locale('en', 'US'),
          ],
        ),
      ),
    );
  }
}

