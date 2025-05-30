import 'package:datn_web_admin/feature/register/presentation/widget/set_meeting_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entity/register_entity.dart';
import '../bloc/registration_bloc.dart';
import '../bloc/registration_event.dart';
import '../bloc/registration_state.dart';

class RegistrationDetailDialog extends StatefulWidget {
  final Registration registration;

  const RegistrationDetailDialog({Key? key, required this.registration}) : super(key: key);

  @override
  _RegistrationDetailDialogState createState() => _RegistrationDetailDialogState();
}

class _RegistrationDetailDialogState extends State<RegistrationDetailDialog> {
  String? _selectedStatus;
  final _rejectionReasonController = TextEditingController();
  bool _showRejectionReason = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.registration.status;
    _showRejectionReason = _selectedStatus == 'REJECTED';
  }

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }

  void _updateStatus() {
    if (_selectedStatus != null && widget.registration.registrationId != null) {
      context.read<RegistrationBloc>().add(UpdateRegistrationStatusEvent(
        id: widget.registration.registrationId!,
        status: _selectedStatus!, // Gửi trạng thái tiếng Anh về API
        rejectionReason: _selectedStatus == 'REJECTED' ? _rejectionReasonController.text : null,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể cập nhật trạng thái: ID đăng ký không hợp lệ.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Hàm dịch trạng thái sang tiếng Việt để hiển thị
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 5),
          ],
        ),
        child: BlocListener<RegistrationBloc, RegistrationState>(
          listener: (context, state) {
            if (state is RegistrationUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cập nhật trạng thái thành công!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
              // Không đóng dialog ngay, để người dùng tiếp tục thao tác
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(Icons.person, 'Tên: ${widget.registration.nameStudent}', Colors.black),
                      const SizedBox(height: 10),
                      _buildInfoRow(Icons.email, 'Email: ${widget.registration.email}', Colors.black),
                      const SizedBox(height: 10),
                      _buildInfoRow(Icons.phone, 'Số điện thoại: ${widget.registration.phoneNumber}', Colors.black),
                      const SizedBox(height: 10),
                      _buildInfoRow(Icons.meeting_room, 'Phòng: ${widget.registration.roomName ?? 'N/A'}', Colors.black),
                      const SizedBox(height: 10),
                      _buildInfoRow(Icons.location_city, 'Khu vực: ${widget.registration.areaName ?? 'N/A'}', Colors.black),
                      const SizedBox(height: 10),
                      _buildInfoRow(Icons.group, 'Số người: ${widget.registration.numberOfPeople?.toString() ?? 'N/A'}', Colors.black),
                      const SizedBox(height: 10),
                      _buildInfoRow(Icons.info, 'Trạng thái: ${_translateStatus(widget.registration.status)}', _getStatusColor(widget.registration.status)),
                      const SizedBox(height: 10),
                      _buildInfoRow(Icons.calendar_today, 'Thời gian gặp: ${widget.registration.meetingDatetime?.toString() ?? 'Chưa thiết lập'}', Colors.black),
                      const SizedBox(height: 10),
                      _buildInfoRow(Icons.location_on, 'Địa điểm gặp: ${widget.registration.meetingLocation ?? 'Chưa thiết lập'}', Colors.black),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Cập nhật trạng thái',
                                border: OutlineInputBorder(),
                              ),
                              value: _selectedStatus,
                              items: const [
                                DropdownMenuItem(value: 'PENDING', child: Text('Đang chờ')),
                                DropdownMenuItem(value: 'APPROVED', child: Text('Đã duyệt')),
                                DropdownMenuItem(value: 'REJECTED', child: Text('Từ chối')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedStatus = value;
                                  _showRejectionReason = value == 'REJECTED';
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: _selectedStatus == widget.registration.status ? null : _updateStatus,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Xác nhận', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                      if (_showRejectionReason) ...[
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _rejectionReasonController,
                          decoration: const InputDecoration(
                            labelText: 'Lý do từ chối',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                      ],
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: widget.registration.registrationId != null
                            ? () {
                          showDialog(
                            context: context,
                            builder: (context) => SetMeetingDialog(registrationId: widget.registration.registrationId!),
                          );
                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.calendar_today),
                        label: const Text('Thiết lập lịch hẹn'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color textColor) {
    return Row(
      children: [
        Icon(icon, color: textColor),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 16, color: textColor),
            softWrap: true,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.yellow;
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}