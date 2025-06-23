import 'package:datn_web_admin/common/constants/colors.dart';
import 'package:datn_web_admin/feature/bill/domain/entities/bill_detail_entity.dart';
import 'package:datn_web_admin/feature/bill/domain/entities/monthly_bill_entity.dart';
import 'package:flutter/material.dart';


class BillListItem extends StatelessWidget {
  final BillDetail billDetail;
  final bool isSelected;
  final bool isCreatedAndPaid;
  final VoidCallback? onToggleSelection;
  final VoidCallback? onViewHistory;
  final VoidCallback? onDelete;
  final String? areaName;
  final String? roomName;
  final String? submitterName;
  final MonthlyBill? monthlyBill;

  const BillListItem({
    Key? key,
    required this.billDetail,
    required this.isSelected,
    required this.isCreatedAndPaid,
    this.onToggleSelection,
    this.onViewHistory,
    this.onDelete,
    this.areaName,
    this.roomName,
    this.submitterName,
    this.monthlyBill,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalWidth = MediaQuery.of(context).size.width - 48; // Trừ padding/margin ngoài
    // Chia đều cho 9 cột (checkbox + 7 info + action)
    final colWidths = [
      0.07, // Checkbox
      0.07, // Khu vực
      0.07, // Phòng
      0.17, // Người gửi
      0.08, // Chỉ số hiện tại
      0.1, // Tháng hóa đơn
      0.1, // Ngày gửi
      0.13, // Trạng thái
      0.07, // Thao tác
    ].map((f) => totalWidth * f).toList();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isCreatedAndPaid
              ? AppColors.buttonSuccess.withOpacity(0.5)
              : AppColors.borderColor.withOpacity(0.5),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: colWidths[0],
            child: Tooltip(
              message: isSelected ? 'Bỏ chọn' : 'Chọn',
              child: Checkbox(
                value: isSelected,
                onChanged: onToggleSelection != null ? (_) => onToggleSelection!() : null,
                activeColor: AppColors.buttonPrimaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          SizedBox(width: colWidths[1], child: _buildInfoCell(icon: Icons.location_city, label: areaName ?? 'N/A', tooltip: 'Khu vực')),
          SizedBox(width: colWidths[2], child: _buildInfoCell(icon: Icons.meeting_room, label: roomName ?? 'N/A', tooltip: 'Phòng')),
          SizedBox(width: colWidths[3], child: _buildInfoCell(icon: Icons.person, label: submitterName ?? 'N/A', tooltip: 'Người gửi')),
          SizedBox(width: colWidths[4], child: _buildInfoCell(icon: Icons.speed, label: billDetail.submittedBy != null ? (billDetail.currentReading?.toStringAsFixed(2) ?? 'N/A') : 'N/A', tooltip: 'Chỉ số hiện tại')),
          SizedBox(width: colWidths[5], child: _buildInfoCell(icon: Icons.calendar_month, label: formatMonthYear(billDetail.billMonth), tooltip: 'Tháng hóa đơn')),
          SizedBox(width: colWidths[6], child: _buildInfoCell(icon: Icons.send, label: billDetail.submittedAt != null ? formatDate(billDetail.submittedAt!) : 'Chưa gửi', tooltip: 'Ngày gửi')),
          SizedBox(width: colWidths[7], child: _buildStatusBadge(context)),
          SizedBox(width: colWidths[8], child: Row(
            children: [
              Tooltip(
                message: 'Xem lịch sử chỉ số',
                child: IconButton(
                  icon: const Icon(Icons.history, size: 20),
                  color: AppColors.buttonPrimaryColor,
                  onPressed: onViewHistory,
                ),
              ),
              if (!isCreatedAndPaid && onDelete != null)
                Tooltip(
                  message: 'Xóa chỉ số',
                  child: IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    color: AppColors.buttonError,
                    onPressed: onDelete,
                  ),
                ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildInfoCell({required IconData icon, required String label, required String tooltip}) {
    return Tooltip(
      message: tooltip,
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary.withOpacity(0.7)),
          const SizedBox(width: 4),
          SizedBox(
            width: 80,
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => const SizedBox(width: 10);

  Widget _buildStatusBadge(BuildContext context) {
    final isCreated = billDetail.monthlyBillId != null && billDetail.monthlyBillId != -1;
    final isPaid = isCreatedAndPaid;
    Color color;
    String text;
    IconData icon;
    if (!isCreated) {
      color = Colors.orange;
      text = 'Chưa tạo hóa đơn';
      icon = Icons.receipt_long;
    } else if (isPaid) {
      color = Colors.green;
      text = 'Đã thanh toán';
      icon = Icons.verified;
    } else {
      color = Colors.blue;
      text = 'Đã tạo hóa đơn';
      icon = Icons.receipt;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// Helper formatters
String formatMonthYear(DateTime date) {
  return '${date.month.toString().padLeft(2, '0')}/${date.year}';
}
String formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
}
