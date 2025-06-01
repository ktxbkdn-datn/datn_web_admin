// lib/src/features/dashboard/presentation/widgets/report_stat_card.dart
import 'package:datn_web_admin/feature/dashboard/presentation/widgets/stat_page/report_stat_page.dart';
import 'package:datn_web_admin/feature/report/presentation/bloc/report/report_bloc.dart';
import 'package:datn_web_admin/feature/report/presentation/bloc/report/report_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../common/constants/colors.dart';
import 'package:intl/intl.dart';


class ReportStatCard extends StatelessWidget {
  const ReportStatCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ReportStatsPage()),
        );
      },
      child: BlocBuilder<ReportBloc, ReportState>(
        builder: (context, state) {
          int currentMonthCount = 0;
          int previousMonthCount = 0;
          String percentageChange = '~0%';
          Color changeColor = Colors.grey;

          if (state is ReportsLoaded) {
            final now = DateTime.now();
            final currentMonth = DateFormat('yyyy-MM').format(now);
            final previousMonth = DateFormat('yyyy-MM').format(
              DateTime(now.year, now.month - 1, now.day),
            );

            // Count reports for current month
            currentMonthCount = state.reports.where((report) {
              if (report.createdAt == null) return false;
              final reportDate = DateFormat('yyyy-MM').format(
                DateTime.parse(report.createdAt!),
              );
              return reportDate == currentMonth;
            }).length;

            // Count reports for previous month
            previousMonthCount = state.reports.where((report) {
              if (report.createdAt == null) return false;
              final reportDate = DateFormat('yyyy-MM').format(
                DateTime.parse(report.createdAt!),
              );
              return reportDate == previousMonth;
            }).length;

            // Calculate percentage change
            if (previousMonthCount > 0) {
              final change = ((currentMonthCount - previousMonthCount) / previousMonthCount) * 100;
              percentageChange = '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}%';
              changeColor = change >= 0 ? Colors.green : Colors.red;
            } else if (currentMonthCount > 0) {
              percentageChange = '+100%';
              changeColor = Colors.green;
            }
          }

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
                      const Text(
                        'Tổng báo cáo',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state is ReportsLoaded ? currentMonthCount.toString() : '0',
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
                            'Tháng trước: $previousMonthCount',
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
        },
      ),
    );
  }
}