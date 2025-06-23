import 'package:flutter/material.dart';

class SearchBarTab extends StatefulWidget {
  final Function(String)? onChanged; // Cho phép onChanged là null
  final Function(String)? onSearch; // Thêm onSearch callback
  final String hintText;
  final String initialValue;

  const SearchBarTab({
    Key? key,
    this.onChanged, // onChanged là optional
    this.onSearch, // onSearch là optional
    required this.hintText,
    this.initialValue = '',
  }) : super(key: key);

  @override
  _SearchBarTabState createState() => _SearchBarTabState();
}

class _SearchBarTabState extends State<SearchBarTab> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    // Xóa nội dung tìm kiếm và gọi onChanged nếu có
    if (_controller.text.isNotEmpty && widget.onChanged != null) {
      _controller.clear();
      widget.onChanged!('');
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: widget.hintText,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.search),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Nút tìm kiếm (hiển thị nếu có onSearch)
            if (widget.onSearch != null)
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  widget.onSearch!(_controller.text);
                },
              ),
            // Nút xóa
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: widget.onChanged == null
                  ? null // Vô hiệu hóa nếu onChanged là null
                  : () {
                _controller.clear();
                widget.onChanged!('');
                // Gọi onSearch với chuỗi rỗng khi xóa
                if (widget.onSearch != null) {
                  widget.onSearch!('');
                }
              },
            ),
          ],
        ),
      ),
      onChanged: widget.onChanged ?? (value) {}, // Cung cấp giá trị mặc định nếu onChanged là null
      onSubmitted: widget.onSearch, // Gọi onSearch khi nhấn Enter
    );
  }
}