import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ContractTemplate {
  static pw.Widget buildContract({
    required String contractNumber,
    required String roomName,
    required String areaName,
    required String fullname,
    required String userEmail,
    required String? phone,
    required String? cccd,
    required String? className,
    required String? dateOfBirth,
    required String status,
    required String contractType,
    required String startDate,
    required String endDate,
    required String createdAt,
    required pw.Font regularFont,
    required pw.Font boldFont,
  }) {
    // Placeholder for fields that are null or empty
    const String placeholder = '............................................';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        // Header: Socialist Republic of Vietnam
        pw.Text(
          'CỘNG HÒA XÃ HỘI CHỦ NGHĨA VIỆT NAM',
          style: pw.TextStyle(fontSize: 12, font: boldFont, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          'Độc lập - Tự do - Hạnh phúc',
          style: pw.TextStyle(fontSize: 12, font: regularFont),
        ),
        pw.SizedBox(height: 10),
        pw.Divider(),
        pw.SizedBox(height: 10),

        // Contract Title
        pw.Text(
          'HỢP ĐỒNG CHO THUÊ PHÒNG TRỌ',
          style: pw.TextStyle(fontSize: 16, font: boldFont, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          'Số: $contractNumber/HĐCT',
          style: pw.TextStyle(fontSize: 12, font: regularFont),
        ),
        pw.SizedBox(height: 20),

        // Lessor Info
        pw.Align(
          alignment: pw.Alignment.centerLeft,
          child: pw.Text(
            'BÊN CHO THUÊ (BÊN A):',
            style: pw.TextStyle(fontSize: 14, font: boldFont, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Align(
          alignment: pw.Alignment.centerLeft,
          child: pw.Text(
            'Ký Túc Xá Trường Đại học Bách Khoa Đại Học Đà Nẵng',
            style: pw.TextStyle(fontSize: 12, font: regularFont),
          ),
        ),
        pw.Align(
          alignment: pw.Alignment.centerLeft,
          child: pw.Text(
            'Địa chỉ: 60 Ngô Sỹ Liên, Hoà Khánh Bắc, Liên Chiểu, Đà Nẵng',
            style: pw.TextStyle(fontSize: 12, font: regularFont),
          ),
        ),
        pw.Align(
          alignment: pw.Alignment.centerLeft,
          child: pw.Text(
            'Số điện thoại: 0236 3736 936 - 0913 402 314',
            style: pw.TextStyle(fontSize: 12, font: regularFont),
          ),
        ),
        pw.SizedBox(height: 20),

        // Lessee Info
        pw.Align(
          alignment: pw.Alignment.centerLeft,
          child: pw.Text(
            'BÊN THUÊ (BÊN B):',
            style: pw.TextStyle(fontSize: 14, font: boldFont, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Align(
          alignment: pw.Alignment.centerLeft,
          child: pw.Text(
            'Họ và tên: ${fullname.isEmpty ? placeholder : fullname}',
            style: pw.TextStyle(fontSize: 12, font: regularFont),
          ),
        ),
        pw.Align(
          alignment: pw.Alignment.centerLeft,
          child: pw.Text(
            'Ngày sinh: ${dateOfBirth ?? placeholder}',
            style: pw.TextStyle(fontSize: 12, font: regularFont),
          ),
        ),
        pw.Align(
          alignment: pw.Alignment.centerLeft,
          child: pw.Text(
            'CCCD: ${cccd ?? placeholder}',
            style: pw.TextStyle(fontSize: 12, font: regularFont),
          ),
        ),
        pw.Align(
          alignment: pw.Alignment.centerLeft,
          child: pw.Text(
            'Địa chỉ email: ${userEmail.isEmpty ? placeholder : userEmail}',
            style: pw.TextStyle(fontSize: 12, font: regularFont),
          ),
        ),
        pw.Align(
          alignment: pw.Alignment.centerLeft,
          child: pw.Text(
            'Số điện thoại: ${phone ?? placeholder}',
            style: pw.TextStyle(fontSize: 12, font: regularFont),
          ),
        ),
        pw.Align(
          alignment: pw.Alignment.centerLeft,
          child: pw.Text(
            'Lớp học: ${className ?? placeholder}',
            style: pw.TextStyle(fontSize: 12, font: regularFont),
          ),
        ),
        pw.SizedBox(height: 20),

        // Room Info
        pw.Align(
          alignment: pw.Alignment.centerLeft,
          child: pw.Text(
            'THÔNG TIN PHÒNG TRỌ:',
            style: pw.TextStyle(fontSize: 14, font: boldFont, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Align(
          alignment: pw.Alignment.centerLeft,
          child: pw.Text(
            'Tên phòng: $roomName',
            style: pw.TextStyle(fontSize: 12, font: regularFont),
          ),
        ),
        pw.Align(
          alignment: pw.Alignment.centerLeft,
          child: pw.Text(
            'Khu vực: ${areaName.isEmpty ? placeholder : areaName}',
            style: pw.TextStyle(fontSize: 12, font: regularFont),
          ),
        ),
        pw.Align(
          alignment: pw.Alignment.centerLeft,
          child: pw.Text(
            'Loại hợp đồng: $contractType',
            style: pw.TextStyle(fontSize: 12, font: regularFont),
          ),
        ),
        pw.Align(
          alignment: pw.Alignment.centerLeft,
          child: pw.Text(
            'Thời gian bắt đầu: $startDate',
            style: pw.TextStyle(fontSize: 12, font: regularFont),
          ),
        ),
        pw.Align(
          alignment: pw.Alignment.centerLeft,
          child: pw.Text(
            'Thời gian kết thúc: $endDate',
            style: pw.TextStyle(fontSize: 12, font: regularFont),
          ),
        ),
        pw.Align(
          alignment: pw.Alignment.centerLeft,
          child: pw.Text(
            'Trạng thái: $status',
            style: pw.TextStyle(fontSize: 12, font: regularFont),
          ),
        ),
        pw.Align(
          alignment: pw.Alignment.centerLeft,
          child: pw.Text(
            'Ngày tạo hợp đồng: $createdAt',
            style: pw.TextStyle(fontSize: 12, font: regularFont),
          ),
        ),
        pw.SizedBox(height: 20),

        // Terms
        pw.Align(
          alignment: pw.Alignment.centerLeft,
          child: pw.Text(
            'ĐIỀU KHOẢN HỢP ĐỒNG:',
            style: pw.TextStyle(fontSize: 14, font: boldFont, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Align(
          alignment: pw.Alignment.centerLeft,
          child: pw.Text(
            'Điều 1: Bên thuê đồng ý thanh toán tiền thuê phòng đúng hạn.',
            style: pw.TextStyle(fontSize: 12, font: regularFont),
          ),
        ),
        pw.Align(
          alignment: pw.Alignment.centerLeft,
          child: pw.Text(
            'Điều 2: Bên cho thuê cam kết cung cấp phòng trọ đúng như mô tả.',
            style: pw.TextStyle(fontSize: 12, font: regularFont),
          ),
        ),
        pw.Align(
          alignment: pw.Alignment.centerLeft,
          child: pw.Text(
            'Điều 3: Các điều khoản khác theo thỏa thuận hai bên.',
            style: pw.TextStyle(fontSize: 12, font: regularFont),
          ),
        ),
        pw.SizedBox(height: 40),

        // Signatures
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              children: [
                pw.Text(
                  'ĐẠI DIỆN BÊN A',
                  style: pw.TextStyle(fontSize: 12, font: boldFont, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 40),
                pw.Text(
                  '(Ký, ghi rõ họ tên)',
                  style: pw.TextStyle(fontSize: 12, font: regularFont),
                ),
              ],
            ),
            pw.Column(
              children: [
                pw.Text(
                  'ĐẠI DIỆN BÊN B',
                  style: pw.TextStyle(fontSize: 12, font: boldFont, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 40),
                pw.Text(
                  '(Ký, ghi rõ họ tên)',
                  style: pw.TextStyle(fontSize: 12, font: regularFont),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}