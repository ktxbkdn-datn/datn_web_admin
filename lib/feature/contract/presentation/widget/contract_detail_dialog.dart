import 'package:datn_web_admin/src/core/theme/contract_template.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_html/html.dart' as html;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:convert';
import 'dart:io' show File, Platform;
import 'package:flutter/services.dart' show rootBundle;
import '../../domain/entities/contract_entity.dart';


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
    // Request storage permission only on mobile platforms
    if (!kIsWeb) {
      if (Platform.isAndroid || Platform.isIOS) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          print('Permission denied: Storage access');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Quyền truy cập bộ nhớ bị từ chối')),
          );
          return;
        }
      }
    } else {
      print('Running on web: Skipping storage permission request');
    }

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
              Text('Đang tạo hợp đồng...'),
            ],
          ),
        ),
      ),
    );

    try {
      // Preload fonts
      print('Loading fonts');
      pw.Font regularFont;
      pw.Font boldFont;
      try {
        final regularFontData = await rootBundle.load(kIsWeb ? 'fonts/NotoSerif-Regular.ttf' : 'assets/fonts/NotoSerif-Regular.ttf');
        final boldFontData = await rootBundle.load(kIsWeb ? 'fonts/NotoSerif-Bold.ttf' : 'assets/fonts/NotoSerif-Bold.ttf');
        print('Font data loaded: regular=${regularFontData.lengthInBytes} bytes, bold=${boldFontData.lengthInBytes} bytes');
        regularFont = pw.Font.ttf(regularFontData);
        boldFont = pw.Font.ttf(boldFontData);
      } catch (e) {
        print('Failed to load custom fonts: $e');
        // Fallback to default fonts
        regularFont = pw.Font.helvetica();
        boldFont = pw.Font.helveticaBold();
        print('Using fallback fonts: Helvetica');
      }
      print('Fonts loaded');

      // Generate PDF
      print('Generating PDF');
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return ContractTemplate.buildContract(
              contractNumber: 'HD${contract.createdAt.replaceAll('-', '')}',
              roomName: contract.roomName,
              areaName: contract.areaName ?? '',
              fullname: contract.fullname ?? '',
              userEmail: contract.userEmail,
              phone: contract.phone,
              cccd: contract.cccd,
              className: contract.className,
              dateOfBirth: contract.dateOfBirth,
              status: _getStatusText(contract.status),
              contractType: _getContractTypeText(contract.contractType),
              startDate: contract.startDate,
              endDate: contract.endDate,
              createdAt: _formatCreatedAt(contract.createdAt),
              regularFont: regularFont,
              boldFont: boldFont,
            );
          },
        ),
      );
      print('PDF generated');

      // Handle saving based on platform
      final fileName = 'contract_${contract.createdAt.replaceAll('-', '')}.pdf';
      String? filePath;
      if (kIsWeb) {
        // On web: Trigger a browser download
        print('Saving PDF on web');
        final bytes = await pdf.save();
        final base64 = base64Encode(bytes);
        final uri = 'data:application/pdf;base64,$base64';
        final anchor = html.AnchorElement(href: uri)
          ..setAttribute('download', fileName)
          ..click();
        print('Browser download triggered');
      } else {
        // On mobile/desktop: Use file_picker to choose save location
        print('Opening file picker');
        filePath = await FilePicker.platform.saveFile(
          dialogTitle: 'Chọn nơi lưu hợp đồng',
          fileName: fileName,
          allowedExtensions: ['pdf'],
          type: FileType.custom,
        );

        if (filePath == null) {
          print('User cancelled file picker');
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã hủy lưu hợp đồng')),
          );
          return;
        }

        print('Saving PDF to: $filePath');
        final file = File(filePath);
        await file.writeAsBytes(await pdf.save());
        print('PDF saved successfully');
      }

      // Close progress dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            kIsWeb ? 'Hợp đồng đã được tải xuống dưới dạng PDF.' : 'Hợp đồng đã được lưu tại: $filePath',
          ),
        ),
      );

      // Open the file using openFilePlus (skip on web)
      if (!kIsWeb && filePath != null) {
        print('Opening PDF with openFilePlus');
        await openFilePlus(filePath);
      } else {
        print('Skipping openFilePlus on web');
      }
    } catch (e, stackTrace) {
      print('Error during export: $e');
      print('Stack trace: $stackTrace');
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xuất hợp đồng: $e')),
      );
    }
  }

  // Placeholder for your openFilePlus method
  Future<void> openFilePlus(String filePath) async {
    // TODO: Replace with your actual openFilePlus implementation
    throw UnimplementedError('openFilePlus not implemented');
  }
}