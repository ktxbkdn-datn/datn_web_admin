import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../report/presentation/bloc/report/report_bloc.dart';
import '../../../report/presentation/bloc/report/report_state.dart';
import '../../../report/domain/entities/report_entity.dart';
import '../../../report/presentation/page/widget/report_tab/report_detail_dialog.dart';
import '../../../../../common/constants/colors.dart';

class MaintenanceRequestCard extends StatelessWidget {
  final ValueNotifier<int> unassignedCountNotifier;

  const MaintenanceRequestCard({
    super.key,
    required this.unassignedCountNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportBloc, ReportState>(
      builder: (context, state) {
        if (state is ReportLoading) {
          return const CircularProgressIndicator();
        }
        if (state is ReportError) {
          return Text('Lỗi: ${state.message}');
        }
        if (state is ReportsLoaded) {
          final filteredReports = state.reports.where((report) => report.reportTypeId == 4).toList();

          final unassignedReports = filteredReports.where((report) => report.status == "PENDING").toList();
          unassignedCountNotifier.value = unassignedReports.length;

          if (filteredReports.isEmpty) {
            return const Text('Không có báo cáo nào với loại này');
          }

          final pendingReports = filteredReports.where((report) => report.status == "PENDING").toList();
          final nonPendingReports = filteredReports.where((report) => report.status != "PENDING").toList();

          pendingReports.sort((a, b) {
            final aDate = a.createdAt != null ? DateTime.parse(a.createdAt!) : DateTime(0);
            final bDate = b.createdAt != null ? DateTime.parse(b.createdAt!) : DateTime(0);
            return aDate.compareTo(bDate);
          });

          nonPendingReports.sort((a, b) {
            final aDate = a.createdAt != null ? DateTime.parse(a.createdAt!) : DateTime(0);
            final bDate = b.createdAt != null ? DateTime.parse(b.createdAt!) : DateTime(0);
            return bDate.compareTo(aDate);
          });

          final sortedReports = [...pendingReports, ...nonPendingReports];
          final topReports = sortedReports.take(3).toList();

          return Column(
            children: topReports.map((report) {
              final createdAt = report.createdAt != null
                  ? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(report.createdAt!))
                  : 'Không xác định';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => ReportDetailDialog(report: report),
                    );
                  },
                  child: _buildMaintenanceCard(
                    type: report.reportTypeName ?? 'Không xác định',
                    id: report.reportId.toString(),
                    createdAt: createdAt,
                    assignedTo: report.userFullname ?? 'Chưa phân công',
                    status: report.status,
                  ),
                ),
              );
            }).toList(),
          );
        }
        return const Text('Không có dữ liệu');
      },
    );
  }

  Widget _buildMaintenanceCard({
    required String type,
    required String id,
    required String createdAt,
    required String assignedTo,
    required String status,
  }) {
    IconData statusIcon;
    Color statusColor;

    switch (status) {
      case 'PENDING':
        statusIcon = Icons.pending;
        statusColor = Colors.orange;
        break;
      case 'RECEIVED':
        statusIcon = Icons.receipt;
        statusColor = Colors.yellow[700]!;
        break;
      case 'IN_PROGRESS':
        statusIcon = Icons.build;
        statusColor = Colors.blue;
        break;
      case 'RESOLVED':
        statusIcon = Icons.check_circle;
        statusColor = Colors.green;
        break;
      case 'CLOSED':
        statusIcon = Icons.lock;
        statusColor = Colors.grey;
        break;
      default:
        statusIcon = Icons.help;
        statusColor = Colors.grey;
    }

    return Stack(
      children: [
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
          margin: const EdgeInsets.symmetric(vertical: 8.0),
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
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.blueGrey,
                  child: Icon(
                    statusIcon,
                    color: statusColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$type [$id]',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        createdAt,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      assignedTo,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.blueGrey,
                      child: Icon(Icons.person, color: Colors.white, size: 20),
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