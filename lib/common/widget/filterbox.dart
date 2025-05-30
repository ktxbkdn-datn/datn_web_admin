import 'package:flutter/material.dart';
import '../constants/colors.dart';

class FilterBox extends StatelessWidget {
  final List<Widget> filters;
  final double spacing;

  const FilterBox({
    Key? key,
    required this.filters,
    this.spacing = 16.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        return Container(
          width: availableWidth, // Fit toàn bộ chiều rộng màn hình
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: filters
                .map((filter) => SizedBox(
              width: 300,
              child: filter,
            ))
                .toList(),
          ),
        );
      },
    );
  }
}