import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';
import '../../../../../../common/constants/colors.dart';

class NotifyRemindBillDetailDialog extends StatefulWidget {
  final Function(String) onSubmit;
  final String title;
  final String description;
  final String buttonText;

  const NotifyRemindBillDetailDialog({
    Key? key,
    required this.onSubmit,
    this.title = 'Gửi thông báo nhắc nộp chỉ số',
    this.description = 'Chọn tháng cần nhắc nhở nộp chỉ số:',
    this.buttonText = 'Gửi thông báo',
  }) : super(key: key);

  @override
  State<NotifyRemindBillDetailDialog> createState() => _NotifyRemindBillDetailDialogState();
}

class _NotifyRemindBillDetailDialogState extends State<NotifyRemindBillDetailDialog> {
  DateTime? _selectedMonth;
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
    _validateSelectedMonth();
  }

  void _validateSelectedMonth() {
    if (_selectedMonth == null) {
      setState(() {
        _isButtonEnabled = false;
      });
      return;
    }

    // Get current month and previous month
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    final previousMonth = DateTime(
      now.month > 1 ? now.year : now.year - 1,
      now.month > 1 ? now.month - 1 : 12,
      1,
    );

    final selectedYearMonth = DateTime(_selectedMonth!.year, _selectedMonth!.month, 1);
    
    // Only allow current month or previous month
    setState(() {
      _isButtonEnabled = selectedYearMonth.isAtSameMomentAs(currentMonth) || 
                        selectedYearMonth.isAtSameMomentAs(previousMonth);
    });
  }

  @override
  Widget build(BuildContext context) {    return AlertDialog(
      title: Text(widget.title, 
        style: const TextStyle(color: AppColors.textPrimary)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.description,
            style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () async {
              DateTime? pickedDate = await showMonthYearPicker(
                context: context,
                initialDate: _selectedMonth ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null) {
                setState(() {
                  _selectedMonth = pickedDate;
                });
                _validateSelectedMonth();
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 12.0,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderColor),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                _selectedMonth != null
                    ? DateFormat('MM/yyyy').format(_selectedMonth!)
                    : 'Chọn tháng',
                style: TextStyle(
                  color: _selectedMonth != null
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
          if (!_isButtonEnabled && _selectedMonth != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Chỉ được phép nhắc nhở cho tháng hiện tại hoặc tháng trước',
                style: TextStyle(color: AppColors.buttonError, fontSize: 12),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Hủy', style: TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: _isButtonEnabled
              ? () {
                  final formattedMonth = DateFormat('yyyy-MM').format(_selectedMonth!);
                  widget.onSubmit(formattedMonth);
                  Navigator.of(context).pop();
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.glassmorphismStart,
            disabledBackgroundColor: AppColors.disabledButton,
          ),
          child: Text(widget.buttonText, style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
