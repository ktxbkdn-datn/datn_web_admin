import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/registration_bloc.dart';
import '../bloc/registration_event.dart';
import '../bloc/registration_state.dart';

class SetMeetingDialog extends StatefulWidget {
  final int registrationId;

  const SetMeetingDialog({Key? key, required this.registrationId}) : super(key: key);

  @override
  _SetMeetingDialogState createState() => _SetMeetingDialogState();
}

class _SetMeetingDialogState extends State<SetMeetingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  DateTime? _selectedDateTime;
  String? _selectedLocation;
  bool _isCustomLocation = false;

  @override
  void initState() {
    super.initState();
    _selectedLocation = 'Văn phòng ký túc xá';
    _locationController.text = _selectedLocation!;
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _selectedDateTime != null) {
      context.read<RegistrationBloc>().add(SetMeetingDatetimeEvent(
        id: widget.registrationId,
        meetingDatetime: _selectedDateTime!,
        meetingLocation: _isCustomLocation ? _locationController.text : _selectedLocation,
      ));
    }
  }

  String _translateStatus(String status) {
    switch (status) {
      case 'APPROVED':
        return 'Đã duyệt';
      case 'PENDING':
        return 'Đang chờ';
      case 'REJECTED':
        return 'Từ chối';
      default:
        return status;
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Chọn thời gian';
    final hour = dateTime.hour;
    final period = hour < 12 ? 'Sáng' : 'Chiều';
    final formattedHour = hour % 12 == 0 ? 12 : hour % 12;
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} $formattedHour:${dateTime.minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: BlocListener<RegistrationBloc, RegistrationState>(
          listener: (context, state) {
            if (state is RegistrationUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thiết lập lịch hẹn thành công!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            } else if (state is RegistrationError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Lỗi: ${state.message}'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Thiết lập lịch hẹn',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Thời gian',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  controller: TextEditingController(
                    text: _formatDateTime(_selectedDateTime),
                  ),
                  onTap: () => _selectDateTime(context),
                  validator: (value) => _selectedDateTime == null ? 'Vui lòng chọn thời gian' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Địa điểm',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedLocation,
                  items: const [
                    DropdownMenuItem(value: 'Văn phòng ký túc xá', child: Text('Văn phòng ký túc xá')),
                    DropdownMenuItem(value: 'Khác', child: Text('Khác')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedLocation = value;
                      _isCustomLocation = value == 'Khác';
                      if (!_isCustomLocation) {
                        _locationController.text = value!;
                      } else {
                        _locationController.clear();
                      }
                    });
                  },
                  validator: (value) => value == null ? 'Vui lòng chọn địa điểm' : null,
                ),
                if (_isCustomLocation) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Địa điểm tùy chỉnh',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value!.isEmpty ? 'Vui lòng nhập địa điểm' : null,
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Hủy', style: TextStyle(color: Colors.black)),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Lưu', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
