import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:datn_web_admin/feature/bill/domain/entities/bill_detail_entity.dart';
import 'package:datn_web_admin/feature/bill/presentation/bloc/bill_bloc.dart';
import 'package:datn_web_admin/feature/bill/presentation/bloc/bill_event.dart';
import 'package:datn_web_admin/feature/bill/presentation/bloc/bill_state.dart';
import 'package:intl/intl.dart';

class BillDetailsDialog extends StatefulWidget {
  final int billId;
  final DateTime month; // Thêm dòng này

  const BillDetailsDialog({Key? key, required this.billId, required this.month}) : super(key: key);

  @override
  _BillDetailsDialogState createState() => _BillDetailsDialogState();
}

class _BillDetailsDialogState extends State<BillDetailsDialog> {
  List<BillDetail> _billDetails = [];

  // Ánh xạ serviceId tới tên dịch vụ (giả định)
  final Map<int, String> _serviceNames = {
    1: 'Điện',
    2: 'Nước',
    3: 'Internet',
  };

  @override
  void initState() {
    super.initState();
    final monthStr = DateFormat('yyyy-MM').format(widget.month);
    context.read<BillBloc>().add(FetchAllBillDetails(
      page: 1,
      limit: 20,
      month: monthStr, // Truyền đúng tháng của hóa đơn
    ));
  }

  // Hàm lấy tên dịch vụ từ serviceId
  String _getServiceName(int? serviceId) {
    return _serviceNames[serviceId] ?? 'Không xác định';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BillBloc, BillState>(
      listener: (context, state) {
        if (state is BillError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(' ${state.message}'), backgroundColor: Colors.red),
          );
        }
      },
      child: Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.6,
          height: MediaQuery.of(context).size.height * 0.6,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Chi tiết hóa đơn', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Tải lại',
                        onPressed: () {
                          final monthStr = DateFormat('yyyy-MM').format(widget.month);
                          context.read<BillBloc>().add(FetchAllBillDetails(
                            page: 1,
                            limit: 20,
                            month: monthStr,
                          ));
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: BlocBuilder<BillBloc, BillState>(
                  builder: (context, state) {
                    if (state is BillLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is BillDetailsLoaded) {
                      final billDetails = state.billDetails
                          .where((detail) => detail.monthlyBillId == widget.billId)
                          .toList();
                      if (billDetails.isEmpty) {
                        return const Center(child: Text('Không có chi tiết hóa đơn nào.'));
                      }
                      return ListView.builder(
                        itemCount: billDetails.length,
                        itemBuilder: (context, index) {
                          final detail = billDetails[index];
                          return Card(
                            child: ListTile(
                              title: Text('Giá: ${detail.price?.toStringAsFixed(2)} VNĐ'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Phòng: ${detail.roomId}'),
                                  Text('Tháng hóa đơn: ${DateFormat('MM/yyyy').format(detail.billMonth)}'),
                                  Text('Người gửi: ${detail.submitterDetails?.fullname ?? 'N/A'}'),
                                  Text('Dịch vụ: ${_getServiceName(detail.rateDetails?.serviceId)}'),
                                  Text('Đơn giá 1 đơn vị: ${detail.rateDetails?.unitPrice.toStringAsFixed(2) ?? 'N/A'} VNĐ'),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                    // Khi chưa load xong hoặc đang ở state khác, chỉ hiển thị loading
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}