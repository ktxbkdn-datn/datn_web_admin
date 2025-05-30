import 'package:flutter/material.dart';

// Color Constants for the App
class AppColors {
  // Glassmorphism Gradient Colors
  static const Color glassmorphismStart = Color(0xFF90CAF9); // Colors.blue.shade200
  static const Color glassmorphismEnd = Color(0xFFF48FB1); // Colors.pink.shade200

  // Common UI Colors
  static const Color cardBackground = Colors.white;
  static const Color shadowColor = Color(0x1F000000); // Colors.black12
  static const Color textPrimary = Color(0xFF333333); // Dark text color
  static const Color textSecondary = Color(0xFF666666); // Grey text color
  static const Color primaryColor = Colors.blue; // Previously buttonPrimary
  static const Color buttonPrimaryColor = Colors.blue; // Previously buttonPrimary
  static const Color buttonSuccess = Colors.green;
  static const Color buttonError = Colors.red;
  static const Color inputFill = Color(0x1A000000); // Colors.grey.withOpacity(0.1)
  static const Color infoBackground = Color(0xFFEBF5FF); // Colors.blue.shade50

  // Additional colors for search_bar and custom_data_table
  static const Color borderColor = Color(0xFF666666); // Same as textSecondary
  static const Color iconColor = Color(0xFF666666); // Same as textSecondary
  static const Color textColor = Color(0xFF333333); // Same as textPrimary
  static const Color headerBackground = Color(0xFFF5F5F5); // Light grey for table header
}