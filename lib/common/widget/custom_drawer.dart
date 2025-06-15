// lib/src/common/widget/custom_drawer.dart
import 'package:flutter/material.dart';


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
  final bool _isExpanded = false; // Luôn thu gọn, không thay đổi

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _widthAnimation = Tween<double>(
      begin: 60.0, // Chỉ dùng chiều rộng thu gọn
      end: 60.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    _controller.value = 1.0; // Luôn ở trạng thái thu nhỏ
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
              // Header (không cho mở rộng nữa)
              Container(
                height: 120,
                color: Colors.blueGrey[800],
                child: Center(
                  child: Icon(
                    widget.headerIcon,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              // Drawer items (chỉ hiện icon)
              Expanded(
                child: ListView.builder(
                  itemCount: widget.items.length,
                  itemBuilder: (context, index) {
                    final item = widget.items[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      leading: Tooltip(
                        message: item.title, // Hiển thị tên khi hover hoặc nhấn giữ
                        child: Icon(
                          item.icon,
                          color: Colors.white,
                        ),
                      ),
                      title: null, // Không hiện text
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