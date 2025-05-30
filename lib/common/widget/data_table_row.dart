import 'package:flutter/material.dart';

class DataTableRow extends StatelessWidget {
  final List<Widget> children;
  final List<double> columnWidths;
  final bool isHeader;
  final Color? backgroundColor;
  final EdgeInsets padding;

  const DataTableRow({
    Key? key,
    required this.children,
    required this.columnWidths,
    this.isHeader = false,
    this.backgroundColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Tính chiều rộng khả dụng sau khi trừ padding
        double availableWidth = constraints.maxWidth - padding.left - padding.right;

        // Tính tổng chiều rộng mong muốn từ columnWidths
        double totalDesiredWidth = columnWidths.fold(0, (sum, width) => sum + width);

        // Tính tỷ lệ co giãn nếu tổng chiều rộng vượt quá khả dụng
        double scale = totalDesiredWidth > availableWidth
            ? availableWidth / totalDesiredWidth
            : 1.0;

        return Container(
          color: isHeader ? (backgroundColor ?? Colors.grey[200]) : backgroundColor,
          padding: padding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(children.length, (index) {
              return SizedBox(
                width: columnWidths[index] * scale, // Áp dụng tỷ lệ co giãn
                child: Align(
                  alignment: index == 0 || index == children.length - 1
                      ? Alignment.center
                      : Alignment.centerLeft,
                  child: children[index],
                ),
              );
            }),
          ),
        );
      },
    );
  }
}