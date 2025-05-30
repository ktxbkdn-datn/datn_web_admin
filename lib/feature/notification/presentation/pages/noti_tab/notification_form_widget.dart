// lib/src/features/notification/presentations/widgets/notification_form_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../room/presentations/widget/room/image_drop_area.dart';
import '../../bloc/noti_type/notification_type_bloc.dart';
import '../../bloc/noti_type/notification_type_state.dart';

class NotificationFormWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController messageController;
  final int? typeId;
  final ValueChanged<int?> onTypeChanged;
  final String? targetType;
  final ValueChanged<String?> onTargetTypeChanged;
  final int? targetId;
  final ValueChanged<int?> onTargetIdChanged;
  final Function(List<Map<String, dynamic>>, List<String>) onMediaDropped;

  const NotificationFormWidget({
    Key? key,
    required this.formKey,
    required this.titleController,
    required this.messageController,
    required this.typeId,
    required this.onTypeChanged,
    required this.targetType,
    required this.onTargetTypeChanged,
    required this.targetId,
    required this.onTargetIdChanged,
    required this.onMediaDropped,
  }) : super(key: key);

  // Kiểm tra nếu loại thông báo là "General" (id: 3)
  bool get isGeneralNotification => typeId == 3;

  // Dịch tên loại thông báo sang tiếng Việt
  String translateNotificationType(String name) {
    switch (name) {
      case 'BILL':
        return 'Hóa đơn';
      case 'General':
        return 'Chung';
      case 'EMERGENCY':
        return 'Khẩn cấp';
      case 'CONTRACT':
        return 'Hợp đồng';
      case 'EVENT':
        return 'Sự kiện';
      case 'PAYMENT':
        return 'Thanh toán';
      default:
        return name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Tiêu đề thông báo',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Tiêu đề không được để trống';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: messageController,
            decoration: const InputDecoration(
              labelText: 'Nội dung thông báo',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nội dung không được để trống';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          BlocBuilder<NotificationTypeBloc, NotificationTypeState>(
            builder: (context, state) {
              List<DropdownMenuItem<int>> items = [];
              if (state is NotificationTypesLoaded) {
                items = state.types.map((type) {
                  return DropdownMenuItem<int>(
                    value: type.typeId,
                    child: Text(translateNotificationType(type.name)),
                  );
                }).toList();
              }
              return DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Loại thông báo',
                  border: OutlineInputBorder(),
                ),
                value: typeId,
                items: items,
                onChanged: (value) {
                  onTypeChanged(value);
                  // Nếu chọn "General", đặt targetType thành 'ALL' và targetId thành null
                  if (value == 3) {
                    onTargetTypeChanged('ALL');
                    onTargetIdChanged(null);
                  } else {
                    onTargetTypeChanged(null); // Reset targetType để người dùng chọn lại
                    onTargetIdChanged(null);
                  }
                },
                validator: (value) {
                  if (value == null) {
                    return 'Vui lòng chọn loại thông báo';
                  }
                  return null;
                },
              );
            },
          ),
          const SizedBox(height: 16),
          if (!isGeneralNotification) ...[
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Đối tượng nhận',
                border: OutlineInputBorder(),
              ),
              value: targetType,
              items: const [
                DropdownMenuItem(value: 'USER', child: Text('Người dùng')),
                DropdownMenuItem(value: 'ROOM', child: Text('Phòng')),
              ],
              onChanged: onTargetTypeChanged,
              validator: (value) {
                if (value == null) {
                  return 'Vui lòng chọn đối tượng nhận';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'ID đối tượng',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                onTargetIdChanged(value.isNotEmpty ? int.tryParse(value) : null);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  if (targetType == 'ROOM' || targetType == 'USER') {
                    return 'ID đối tượng là bắt buộc cho ROOM hoặc USER';
                  }
                  return null;
                }
                if (int.tryParse(value) == null) {
                  return 'ID đối tượng phải là số';
                }
                return null;
              },
            ),
          ] else ...[
            const SizedBox(height: 16),
            const Text(
              'Thông báo "Chung" không yêu cầu đối tượng nhận cụ thể.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
          const SizedBox(height: 16),
          const Text(
            'Media:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ImageDropArea(
            onImagesDropped: (images) {
              // Giả sử mỗi media có một altText mặc định, có thể mở rộng để nhập altText riêng
              List<String> altTexts = images.map((e) => 'Media for notification').toList();
              onMediaDropped(images, altTexts);
            },
          ),
        ],
      ),
    );
  }
}