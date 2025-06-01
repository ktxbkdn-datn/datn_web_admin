import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../room/presentations/bloc/area_bloc/area_bloc.dart';
import '../../../room/presentations/bloc/area_bloc/area_state.dart';

class ContractFormWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController roomNameController;
  final TextEditingController userEmailController;
  final TextEditingController startDateController;
  final TextEditingController endDateController;
  final int? areaId;
  final ValueChanged<int?> onAreaChanged;
  final String? contractType;
  final ValueChanged<String?>? onContractTypeChanged;
  final String? status;
  final ValueChanged<String?>? onStatusChanged;
  final VoidCallback? onStartDateTap;
  final VoidCallback? onEndDateTap;
  final bool showContractTypeField;
  final bool showStatusField;

  const ContractFormWidget({
    Key? key,
    required this.formKey,
    required this.roomNameController,
    required this.userEmailController,
    required this.startDateController,
    required this.endDateController,
    required this.areaId,
    required this.onAreaChanged,
    this.contractType,
    this.onContractTypeChanged,
    this.status,
    this.onStatusChanged,
    this.onStartDateTap,
    this.onEndDateTap,
    this.showContractTypeField = false,
    this.showStatusField = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: roomNameController,
            decoration: const InputDecoration(
              labelText: 'Tên phòng',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Tên phòng không được để trống';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: userEmailController,
            decoration: const InputDecoration(
              labelText: 'Email người dùng',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email không được để trống';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Email không hợp lệ';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          BlocBuilder<AreaBloc, AreaState>(
            builder: (context, areaState) {
              return DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Khu vực',
                  border: OutlineInputBorder(),
                ),
                value: areaId,
                items: areaState.areas.map((area) {
                  return DropdownMenuItem<int>(
                    value: area.areaId,
                    child: Text(area.name),
                  );
                }).toList(),
                onChanged: onAreaChanged,
                validator: (value) {
                  if (value == null) {
                    return 'Vui lòng chọn khu vực';
                  }
                  return null;
                },
              );
            },
          ),
          const SizedBox(height: 16),
          if (showContractTypeField && onContractTypeChanged != null) ...[
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Loại hợp đồng',
                border: OutlineInputBorder(),
              ),
              value: contractType,
              items: const [
                DropdownMenuItem(value: 'SHORT_TERM', child: Text('Ngắn hạn')),
                DropdownMenuItem(value: 'LONG_TERM', child: Text('Dài hạn')),
              ],
              onChanged: onContractTypeChanged,
              validator: (value) {
                if (value == null) {
                  return 'Vui lòng chọn loại hợp đồng';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
          ],
          if (showStatusField && onStatusChanged != null) ...[
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Trạng thái',
                border: OutlineInputBorder(),
              ),
              value: status,
              items: const [
                DropdownMenuItem(value: 'PENDING', child: Text('Chờ duyệt')),
                DropdownMenuItem(value: 'ACTIVE', child: Text('Còn hiệu lực')),
                DropdownMenuItem(value: 'EXPIRED', child: Text('Hết hạn')),
                DropdownMenuItem(value: 'TERMINATED', child: Text('Đã chấm dứt')),
              ],
              onChanged: onStatusChanged,
              validator: (value) {
                if (value == null) {
                  return 'Vui lòng chọn trạng thái';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
          ],
          TextFormField(
            controller: startDateController,
            readOnly: true, // Không cho phép nhập tay
            decoration: const InputDecoration(
              labelText: 'Ngày bắt đầu (YYYY-MM-DD)',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today),
            ),
            onTap: onStartDateTap, // Gọi DatePicker khi nhấn
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ngày bắt đầu không được để trống';
              }
              try {
                DateTime date = DateTime.parse(value);
                // Chỉ lấy ngày, bỏ thời gian
                DateTime dateOnly = DateTime(date.year, date.month, date.day);
                DateTime now = DateTime.now();
                DateTime today = DateTime(now.year, now.month, now.day);
                if (dateOnly.isBefore(today)) {
                  return 'Ngày bắt đầu không được trong quá khứ';
                }
              } catch (e) {
                return 'Định dạng ngày không hợp lệ (YYYY-MM-DD)';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: endDateController,
            readOnly: true, // Không cho phép nhập tay
            decoration: const InputDecoration(
              labelText: 'Ngày kết thúc (YYYY-MM-DD)',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today),
            ),
            onTap: onEndDateTap, // Gọi DatePicker khi nhấn
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ngày kết thúc không được để trống';
              }
              try {
                DateTime endDate = DateTime.parse(value);
                DateTime startDate = DateTime.parse(startDateController.text);
                // Chỉ lấy ngày, bỏ thời gian
                DateTime endDateOnly = DateTime(endDate.year, endDate.month, endDate.day);
                DateTime startDateOnly = DateTime(startDate.year, startDate.month, startDate.day);
                if (endDateOnly.isBefore(startDateOnly)) {
                  return 'Ngày kết thúc phải sau ngày bắt đầu';
                }
              } catch (e) {
                return 'Định dạng ngày không hợp lệ (YYYY-MM-DD)';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}