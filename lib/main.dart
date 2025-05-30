// lib/main.dart
import 'package:datn_web_admin/src/core/network/api_client.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'src/core/di/injection.dart';

void main()  {
  // Initialize dependency injection
  setup();
  
  runApp(const App());
}