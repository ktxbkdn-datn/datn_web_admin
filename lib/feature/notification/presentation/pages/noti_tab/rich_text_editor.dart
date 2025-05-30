import 'package:flutter/material.dart';

// Widget cho trình soạn thảo văn bản đơn giản
class SimpleRichTextEditor extends StatefulWidget {
  final Function(String) onContentChanged;

  const SimpleRichTextEditor({
    Key? key,
    required this.onContentChanged,
  }) : super(key: key);

  @override
  _SimpleRichTextEditorState createState() => _SimpleRichTextEditorState();
}

class _SimpleRichTextEditorState extends State<SimpleRichTextEditor> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    _controller.addListener(() {
      // Chuyển nội dung thành HTML cơ bản với thẻ <p>
      final content = _controller.text.isNotEmpty
          ? '<p>${_controller.text}</p>'
          : '';
      widget.onContentChanged(content);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: SingleChildScrollView(
        child: SizedBox(
          height: 300, // Cố định chiều cao của TextField bằng SizedBox
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            maxLines: null,
            expands: true, // Cho phép TextField mở rộng để lấp đầy chiều cao
            textAlignVertical: TextAlignVertical.top, // Căn chỉnh con trỏ và hintText ở phía trên cùng
            style: const TextStyle(fontSize: 16),
            decoration: const InputDecoration(
              hintText: 'Nhập nội dung thông báo...',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(top: 8, bottom: 15, left: 10),
            ),
          ),
        ),
      ),
    );
  }
}