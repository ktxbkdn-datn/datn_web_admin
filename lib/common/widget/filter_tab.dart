import 'package:flutter/material.dart';

class FilterTab extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap; // Cho phép onTap là null
  final IconData? icon;
  final Color? selectedColor;
  final Color? unselectedColor;
  final int? count; // Số lượng items trong filter
  final bool showBadge;

  const FilterTab({
    Key? key,
    required this.label,
    required this.isSelected,
    this.onTap, // onTap là optional
    this.icon,
    this.selectedColor,
    this.unselectedColor,
    this.count,
    this.showBadge = false,
  }) : super(key: key);

  @override
  State<FilterTab> createState() => _FilterTabState();
}

class _FilterTabState extends State<FilterTab> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isSelected) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(FilterTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = widget.selectedColor ?? Theme.of(context).primaryColor;
    final unselectedColor = widget.unselectedColor ?? Colors.grey[600] ?? Colors.grey;

    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      onTap: widget.onTap ?? () {}, // Cung cấp giá trị mặc định nếu onTap là null
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: widget.isSelected 
                    ? selectedColor.withOpacity(0.15)
                    : Colors.white, // Nền trắng khi không chọn
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: widget.isSelected 
                      ? selectedColor
                      : selectedColor.withOpacity(0.3), 
                  width: widget.isSelected ? 2 : 1,
                ),
                boxShadow: widget.isSelected
                    ? [
                        BoxShadow(
                          color: selectedColor.withOpacity(0.18),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      size: 18,
                      color: widget.isSelected ? Colors.black87 : Colors.grey[700], // Icon đen khi chọn, xám đậm khi không chọn
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: widget.isSelected ? Colors.black87 : Colors.grey[800], // Chữ đen khi chọn, xám đậm khi không chọn
                      fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  if (widget.showBadge && widget.count != null && widget.count! > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: widget.isSelected ? Colors.white : Colors.grey[300], // Badge trắng khi chọn, xám nhạt khi không chọn
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${widget.count}',
                        style: TextStyle(
                          color: widget.isSelected ? Colors.black87 : Colors.grey[800], // Số badge: đen khi chọn, xám đậm khi không chọn
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Widget wrapper để sử dụng nhiều filter tabs
class FilterTabBar extends StatelessWidget {
  final List<FilterTab> tabs;
  final ScrollController? scrollController;
  final EdgeInsetsGeometry? padding;

  const FilterTabBar({
    Key? key,
    required this.tabs,
    this.scrollController,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs,
        ),
      ),
    );
  }
}