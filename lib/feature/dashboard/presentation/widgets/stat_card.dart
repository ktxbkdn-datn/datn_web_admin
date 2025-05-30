// lib/src/features/dashboard/presentation/widgets/stat_card.dart
import 'package:flutter/material.dart';
import '../../../../../common/constants/colors.dart'; // Import AppColors

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String percentageChange;
  final String lastMonthTotal;
  final Color changeColor;

  const StatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.percentageChange,
    required this.lastMonthTotal,
    required this.changeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Glassmorphism Background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.glassmorphismStart, AppColors.glassmorphismEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.25,
          height: MediaQuery.of(context).size.height * 0.2,
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title == 'Total Contracts' ? 'Tổng hợp đồng' : title,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      percentageChange,
                      style: TextStyle(color: changeColor, fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tháng trước: $lastMonthTotal',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}