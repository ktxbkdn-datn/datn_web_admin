import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:datn_web_admin/feature/service/domain/entities/service_rate_entity.dart';
import 'package:datn_web_admin/feature/service/presentation/bloc/service_bloc.dart';
import 'package:datn_web_admin/feature/service/presentation/bloc/service_event.dart';
import 'package:datn_web_admin/feature/service/presentation/bloc/service_state.dart';
import 'package:intl/intl.dart';

class SetServiceRateDialog extends StatefulWidget {
  final int serviceId;

  const SetServiceRateDialog({Key? key, required this.serviceId}) : super(key: key);

  @override
  _SetServiceRateDialogState createState() => _SetServiceRateDialogState();
}

class _SetServiceRateDialogState extends State<SetServiceRateDialog> {
  final _priceController = TextEditingController();
  DateTime? _selectedDate;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Mặc định ngày áp dụng là ngày 1 của tháng tiếp theo
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month + 1, 1);
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final firstAllowedDate = DateTime(now.year, now.month + 1, 1); // Ngày 1 của tháng tiếp theo

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? firstAllowedDate,
      firstDate: firstAllowedDate,
      lastDate: DateTime(2101),
      selectableDayPredicate: (DateTime day) {
        // Chỉ cho phép chọn ngày 1 của các tháng lớn hơn tháng hiện tại
        return day.day == 1 && day.isAfter(firstAllowedDate.subtract(const Duration(days: 1)));
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _createServiceRate() {
    if (_isSubmitting) return;

    final priceText = _priceController.text;
    if (priceText.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập giá và chọn ngày áp dụng.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final price = double.tryParse(priceText);
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Giá phải là một số hợp lệ và lớn hơn 0.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final serviceRate = ServiceRate(
      rateId: null,
      unitPrice: price,
      effectiveDate: _selectedDate!,
      serviceId: widget.serviceId,
    );

    context.read<ServiceBloc>().add(CreateNewServiceRate(serviceRate));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(16.0),
        child: BlocListener<ServiceBloc, ServiceState>(
          listener: (context, state) {
            if (state is ServiceRateCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tạo mức giá mới thành công!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
              Navigator.of(context).pop();
            } else if (state is ServiceError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Lỗi: ${state.message}'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
              setState(() {
                _isSubmitting = false;
              });
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Thêm mức giá mới',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Thông báo quy định
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Mức giá mới chỉ có thể áp dụng từ tháng sau trở đi và phải bắt đầu từ ngày 1 của tháng.',
                  style: TextStyle(fontSize: 14, color: Colors.blue, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              const Text('Ngày áp dụng:'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    controller: TextEditingController(
                      text: _selectedDate != null
                          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                          : '',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Giá (VNĐ):'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                    child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _createServiceRate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text('Lưu', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}