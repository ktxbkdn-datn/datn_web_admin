// lib/main.dart

import 'package:flutter/material.dart';
import 'app.dart';
import 'src/core/di/injection.dart';

void main() async {
  // Initialize dependency injection
  setup();
  runApp(const App());
}