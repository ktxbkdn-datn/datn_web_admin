import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../area_bloc/area_bloc.dart';
import '../../area_bloc/area_state.dart';
import 'image_drop_area.dart';

class RoomFormWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController capacityController;
  final TextEditingController priceController;
  final TextEditingController descriptionController;
  final TextEditingController? statusController;
  final int? areaId;
  final ValueChanged<int?> onAreaChanged;
  final String? status;
  final ValueChanged<String?>? onStatusChanged;
  final ValueChanged<List<Map<String, dynamic>>>? onImagesDropped;
  final bool showStatusField;
  final bool showImageField;

  const RoomFormWidget({
    Key? key,
    required this.formKey,
    required this.nameController,
    required this.capacityController,
    required this.priceController,
    required this.descriptionController,
    this.statusController,
    this.areaId,
    required this.onAreaChanged,
    this.status,
    this.onStatusChanged,
    this.onImagesDropped,
    this.showStatusField = false,
    this.showImageField = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: nameController,
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
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(
              labelText: 'Sức chứa',
              border: OutlineInputBorder(),
            ),
            value: capacityController.text.isNotEmpty ? int.tryParse(capacityController.text) : null,
            items: const [
              DropdownMenuItem(value: 2, child: Text('2')),
              DropdownMenuItem(value: 4, child: Text('4')),
              DropdownMenuItem(value: 6, child: Text('6')),
              DropdownMenuItem(value: 8, child: Text('8')),
            ],
            onChanged: (value) {
              if (value != null) {
                capacityController.text = value.toString();
              }
            },
            validator: (value) {
              if (value == null) {
                return 'Sức chứa không được để trống';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: priceController,
            decoration: const InputDecoration(
              labelText: 'Giá',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Giá không được để trống';
              }
              if (double.tryParse(value) == null || double.parse(value) <= 0) {
                return 'Giá phải là số dương';
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
          TextFormField(
            controller: descriptionController,
            decoration: const InputDecoration(
              labelText: 'Mô tả',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          if (showStatusField && statusController != null && onStatusChanged != null) ...[
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Trạng thái',
                border: OutlineInputBorder(),
              ),
              value: status, // Sử dụng status thay vì statusController.toString()
              items: const [
                DropdownMenuItem(value: 'AVAILABLE', child: Text('Có sẵn')),
                DropdownMenuItem(value: 'OCCUPIED', child: Text('Đã hết')),
                DropdownMenuItem(value: 'MAINTENANCE', child: Text('Bảo trì')),
                DropdownMenuItem(value: 'DISABLED', child: Text('Vô hiệu hóa')),
              ],
              onChanged: onStatusChanged,
            ),
          ],
          if (showImageField && onImagesDropped != null) ...[
            const SizedBox(height: 16),
            const Text(
              'Hình ảnh:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ImageDropArea(
              onImagesDropped: onImagesDropped!,
            ),
          ],
        ],
      ),
    );
  }
}