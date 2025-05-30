import 'package:datn_web_admin/common/constants/api_string.dart';
import 'package:datn_web_admin/src/core/di/invidiual_di/bill_injection.dart';
import 'package:datn_web_admin/src/core/di/invidiual_di/notification_injection.dart';
import 'package:datn_web_admin/src/core/di/invidiual_di/report_image_injection.dart';
import 'package:datn_web_admin/src/core/di/invidiual_di/report_injection.dart';
import 'package:datn_web_admin/src/core/di/invidiual_di/report_type_injection.dart';
import 'package:datn_web_admin/src/core/di/invidiual_di/service_Injection.dart';
import 'package:datn_web_admin/src/core/di/invidiual_di/statistics_injection.dart';
import 'package:get_it/get_it.dart';

import '../network/api_client.dart';
import 'invidiual_di/admin_injection.dart';
import 'invidiual_di/auth_injection.dart';
import 'invidiual_di/contract_injection.dart';
import 'invidiual_di/notification_media_injection.dart';
import 'invidiual_di/notification_type_injection.dart';
import 'invidiual_di/registration_injection.dart';
import 'invidiual_di/room_injection.dart';
import 'invidiual_di/user_injection.dart';

final getIt = GetIt.instance;

Future<void> setup() async {
  // Đăng ký ApiService làm singleton
  getIt.registerSingleton<ApiService>(ApiService(baseUrl: APIbaseUrl));

  // Đăng ký dependencies cho từng module
  registerAuthDependencies();
  registerAdminDependencies();
  registerUserDependencies();
  registerRoomDependencies();
  registerRegistrationDependencies();
  registerContractDependencies();
  registerServicesDependencies();
  registerBillDependencies();
  registerReportDependencies();
  registerReportTypeDependencies();
  registerReportImageDependencies();
  registerNotificationDependencies();
  registerNotificationMediaDependencies();
  registerNotificationTypeDependencies();
  registerStatisticsDependencies();
}

