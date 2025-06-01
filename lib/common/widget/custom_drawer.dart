// lib/src/common/widget/custom_drawer.dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class CustomDrawer extends StatefulWidget {
  final String title;
  final IconData headerIcon;
  final List<DrawerItem> items;
  final int selectedIndex;
  final Function(int) onTap;
  final TabController? tabController;
  final Function(bool)? onExpansionChanged;

  const CustomDrawer({
    Key? key,
    required this.title,
    required this.headerIcon,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
    this.tabController,
    this.onExpansionChanged,
  }) : super(key: key);

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthAnimation;
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350), // Tăng thời gian để mượt hơn
      vsync: this,
    );
    _widthAnimation = Tween<double>(
      begin: 200.0, // Chiều rộng mở rộng
      end: 60.0, // Chiều rộng thu nhỏ
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut, // Curve mượt
      ),
    );
    // Khởi tạo trạng thái ban đầu
    if (!_isExpanded) {
      _controller.value = 1.0; // Drawer bắt đầu ở trạng thái thu nhỏ
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
      widget.onExpansionChanged?.call(_isExpanded);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: _widthAnimation.value,
          color: Colors.blueGrey[900],
          child: Column(
            children: [
              // Header
              GestureDetector(
                onTap: _toggleExpansion,
                child: Container(
                  height: 120,
                  color: Colors.blueGrey[800],
                  child: Center(
                    child: _isExpanded
                        ?  Text(
                            // Sử dụng const để tối ưu
                            widget.title, // Thay bằng widget.title nếu cần động
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : Icon(
                            widget.headerIcon,
                            color: Colors.white,
                            size: 30,
                          ),
                  ),
                ),
              ),
              // Drawer items
              Expanded(
                child: ListView.builder(
                  itemCount: widget.items.length,
                  itemBuilder: (context, index) {
                    final item = widget.items[index];
                    return ListTile(
                      leading: Icon(
                        item.icon,
                        color: Colors.white,
                      ),
                      title: _isExpanded
                          ? Text(
                              item.title,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            )
                          : null,
                      selected: widget.selectedIndex == index,
                      selectedTileColor: Colors.blueGrey[700],
                      onTap: () {
                        widget.onTap(index);
                        if (item.route != null) {
                          Navigator.pushNamed(context, item.route!);
                        } else if (widget.tabController != null) {
                          widget.tabController!.animateTo(index);
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class DrawerItem {
  final String title;
  final IconData icon;
  final String? route;

  DrawerItem({
    required this.title,
    required this.icon,
    this.route,
  });
}