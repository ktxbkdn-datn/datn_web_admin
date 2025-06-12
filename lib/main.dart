// lib/main.dart
import 'package:datn_web_admin/src/core/network/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:ntp/ntp.dart';

import 'app.dart';
import 'src/core/di/injection.dart';

void main() async {
  // Initialize dependency injection
  setup();
  try {
    DateTime currentTime = await NTP.now();

  } catch (e) {
    print('Failed to sync time: $e');
  }
  runApp(const App());
}