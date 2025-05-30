import 'package:flutter/material.dart';

class ColumnHeaderRow extends StatelessWidget {
  final List<String> headers;
  final List<double> columnWidths;

  const ColumnHeaderRow({
    Key? key,
    required this.headers,
    required this.columnWidths,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(headers.length, (index) {
          return SizedBox(
            width: columnWidths[index],
            child: Text(
              headers[index],
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          );
        }),
      ),
    );
  }
}