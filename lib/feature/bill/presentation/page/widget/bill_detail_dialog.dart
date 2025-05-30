import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:datn_web_admin/feature/bill/domain/entities/monthly_bill_entity.dart';
import 'package:datn_web_admin/feature/bill/presentation/bloc/bill_bloc.dart';
import 'package:datn_web_admin/feature/bill/presentation/bloc/bill_event.dart';
import 'package:datn_web_admin/feature/bill/presentation/bloc/bill_state.dart';
import 'package:datn_web_admin/feature/bill/presentation/page/widget/bill_details_dialog.dart';
import 'package:intl/intl.dart';

class BillDetailDialog extends StatefulWidget {
  final MonthlyBill bill;

  const BillDetailDialog({Key? key, required this.bill}) : super(key: key);

  @override
  _BillDetailDialogState createState() => _BillDetailDialogState();
}

class _BillDetailDialogState extends State<BillDetailDialog> {
  // Hàm ánh xạ trạng thái sang tiếng Việt
  String _translatePaymentStatus(String status) {
    switch (status) {
      case 'PENDING':
        return 'Chưa thanh toán';
      case 'PAID':
        return 'Đã thanh toán';
      case 'FAILED':
        return 'Thanh toán thất bại';
      case 'OVERDUE':
        return 'Quá hạn';
      default:
        return status; // Nếu trạng thái không xác định, trả về giá trị gốc
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BillBloc, BillState>(
      listener: (context, state) {
        if (state is BillError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${state.message}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            minWidth: 400,
            minHeight: 200,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 5),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.black),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(Icons.room, 'Phòng:', widget.bill.roomDetails?.name ?? 'N/A', Colors.black),
                        const SizedBox(height: 10),
                        _buildInfoRow(Icons.attach_money, 'Tổng tiền:', '${widget.bill.totalAmount.toStringAsFixed(2)} VNĐ', Colors.black),
                        const SizedBox(height: 10),
                        _buildInfoRow(Icons.payment, 'Trạng thái:', _translatePaymentStatus(widget.bill.paymentStatus), Colors.black),
                        const SizedBox(height: 10),
                        _buildInfoRow(Icons.calendar_today, 'Ngày tạo:', DateFormat('dd/MM/yyyy').format(widget.bill.createdAt), Colors.black),
                        const SizedBox(height: 10),
                        _buildInfoRow(Icons.calendar_today, 'Tháng hóa đơn:', DateFormat('MM/yyyy').format(widget.bill.billMonth), Colors.black),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildInfoRow(Icons.list, 'Chi tiết hóa đơn:', '', Colors.black),
                              IconButton(
                                icon: const Icon(Icons.list, color: Colors.blue),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => BillDetailsDialog(billId: widget.bill.billId),
                                  );
                                },
                                tooltip: 'Xem chi tiết hóa đơn',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color textColor) {
    return Row(
      children: [
        Icon(icon, color: textColor),
        const SizedBox(width: 10),
        Text(
          '$label $value',
          style: TextStyle(fontSize: 16, color: textColor),
          softWrap: true,
        ),
      ],
    );
  }
}