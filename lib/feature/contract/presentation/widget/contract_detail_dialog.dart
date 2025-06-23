import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/contract_entity.dart';
import '../bloc/contract_bloc.dart';

class ContractDetailDialog extends StatelessWidget {
  final Contract contract;

  const ContractDetailDialog({Key? key, required this.contract}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.file_download, color: Colors.black),
                      onPressed: () => _exportContract(context),
                      tooltip: 'Xuất hợp đồng',
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(Icons.description, 'Tên phòng: ${contract.roomName}', Colors.black),
                    _buildInfoRow(Icons.location_on, 'Khu vực: ${contract.areaName ?? 'Chưa có'}', Colors.black),
                    _buildInfoRow(Icons.person, 'Tên người dùng: ${contract.fullname ?? 'Chưa có'}', Colors.black),
                    _buildInfoRow(Icons.email, 'Email: ${contract.userEmail}', Colors.black),
                    if (contract.phone != null)
                      _buildInfoRow(Icons.phone, 'Số điện thoại: ${contract.phone}', Colors.black),
                    if (contract.cccd != null)
                      _buildInfoRow(Icons.badge, 'CCCD: ${contract.cccd}', Colors.black),
                    if (contract.className != null)
                      _buildInfoRow(Icons.class_, 'Lớp học: ${contract.className}', Colors.black),
                    if (contract.dateOfBirth != null)
                      _buildInfoRow(Icons.cake, 'Ngày sinh: ${contract.dateOfBirth}', Colors.black),
                    _buildInfoRow(
                        Icons.info, 'Trạng thái: ${_getStatusText(contract.status)}', _getStatusColor(contract.status)),
                    _buildInfoRow(Icons.label, 'Loại hợp đồng: ${_getContractTypeText(contract.contractType)}', Colors.black),
                    _buildInfoRow(Icons.calendar_today, 'Ngày bắt đầu: ${contract.startDate}', Colors.black),
                    _buildInfoRow(Icons.calendar_today, 'Ngày kết thúc: ${contract.endDate}', Colors.black),
                    _buildInfoRow(Icons.access_time, 'Ngày tạo: ${_formatCreatedAt(contract.createdAt)}', Colors.black),
                    _buildInfoRow(Icons.help, 'Hỗ trợ: Liên hệ quản lý', Colors.black),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16, color: textColor),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'ACTIVE':
        return 'Còn hiệu lực';
      case 'PENDING':
        return 'Chờ duyệt';
      case 'EXPIRED':
        return 'Hết hạn';
      case 'TERMINATED':
        return 'Đã chấm dứt';
      default:
        return 'Không xác định';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return Colors.green;
      case 'PENDING':
        return Colors.yellow;
      case 'EXPIRED':
        return Colors.red;
      case 'TERMINATED':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getContractTypeText(String contractType) {
    switch (contractType) {
      case 'SHORT_TERM':
        return 'Ngắn hạn';
      case 'LONG_TERM':
        return 'Dài hạn';
      default:
        return 'Không xác định';
    }
  }

  String _formatCreatedAt(String createdAt) {
    return createdAt.split('T')[0];
  }
  Future<void> _exportContract(BuildContext context) async {
    // Show progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Dialog(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Đang tải hợp đồng...'),
            ],
          ),
        ),
      ),
    );
    
    try {      // Gọi Bloc để export hợp đồng
      final contractBloc = BlocProvider.of<ContractBloc>(context);
      final pdfResult = await contractBloc.exportPdf(contract.contractId);
      
      // Đóng dialog loading
      Navigator.of(context).pop();
      
      // Xử lý kết quả
      pdfResult.fold(
        (failure) {
          // Hiển thị thông báo lỗi
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi khi export hợp đồng: ${failure.message}')),
          );
        }, 
        (pdfBytes) {
          if (kIsWeb) {
            // Tạo blob từ dữ liệu PDF
            final blob = html.Blob([pdfBytes], 'application/pdf');
            final url = html.Url.createObjectUrlFromBlob(blob);
            
            // Mở PDF trong tab mới
            html.window.open(url, '_blank');
            
            // Giải phóng URL để tránh rò rỉ bộ nhớ
            html.Url.revokeObjectUrl(url);
          } else {
            // Trên mobile/desktop thì hiển thị thông báo thành công
            // Bạn có thể thêm code để lưu file vào bộ nhớ thiết bị ở đây
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã xuất hợp đồng thành công')),
            );
          }
        },
      );
    } catch (e) {
      Navigator.of(context).pop(); // Đóng dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi export hợp đồng: $e')),
      );
    }
  }

  // Placeholder for your openFilePlus method
  Future<void> openFilePlus(String filePath) async {
    // TODO: Replace with your actual openFilePlus implementation
    throw UnimplementedError('openFilePlus not implemented');
  }
}