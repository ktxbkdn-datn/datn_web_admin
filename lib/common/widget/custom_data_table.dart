import 'package:flutter/material.dart';
import '../constants/colors.dart';

class GenericDataTable<T> extends StatelessWidget {
  final List<String> headers;
  final List<T> data;
  final List<double>? columnWidths;
  final Widget Function(T item, int columnIndex) cellBuilder;
  final Color? backgroundColor; // Tham số tùy chọn để thay đổi màu nền

  const GenericDataTable({
    Key? key,
    required this.headers,
    required this.data,
    this.columnWidths,
    required this.cellBuilder,
    this.backgroundColor, // Mặc định sẽ dùng AppColors.cardBackground
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        // Tính toán độ rộng cột
        final defaultWidth = (availableWidth - 16) / headers.length;
        final widths = columnWidths != null && columnWidths!.length == headers.length
            ? List<double>.from(columnWidths!)
            : List.filled(headers.length, defaultWidth);

        // Điều chỉnh để luôn fit availableWidth
        final totalWidth = widths.reduce((a, b) => a + b);
        final adjustedWidths = totalWidth != availableWidth
            ? widths
            .map((width) => width * (availableWidth - 32) / totalWidth)
            .toList()
            : widths;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            width: availableWidth,
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: backgroundColor ?? AppColors.cardBackground, // Màu nền đồng bộ
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header row
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  decoration: const BoxDecoration(
                    color: Colors.transparent, // Trong suốt để kế thừa màu Container
                    borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
                  ),
                  child: Table(
                    columnWidths: {
                      for (var i = 0; i < headers.length; i++)
                        i: FixedColumnWidth(adjustedWidths[i]),
                    },
                    children: [
                      TableRow(
                        children: headers.asMap().entries.map((entry) {
                          final index = entry.key;
                          final header = entry.value;
                          return TableCell(
                            child: Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 4.0),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: adjustedWidths[index],
                                ),
                                child: Text(
                                  header,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppColors.textColor,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Data rows or empty state
                if (data.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: const BoxDecoration(
                      color: Colors.transparent, // Trong suốt để kế thừa màu Container
                    ),
                    child: Text(
                      'Không có dữ liệu để hiển thị',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  Table(
                    columnWidths: {
                      for (var i = 0; i < headers.length; i++)
                        i: FixedColumnWidth(adjustedWidths[i]),
                    },
                    children: data.asMap().entries.map((entry) {
                      final item = entry.value;
                      return TableRow(
                        children: headers.asMap().entries.map((headerEntry) {
                          final index = headerEntry.key;
                          return TableCell(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4.0, vertical: 12.0),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: adjustedWidths[index],
                                ),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.transparent, // Trong suốt để kế thừa màu Container
                                    borderRadius: BorderRadius.all(Radius.circular(4)),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: DefaultTextStyle(
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                    ),
                                    child: cellBuilder(item, index),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}