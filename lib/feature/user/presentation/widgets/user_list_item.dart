// lib/src/features/user/presentation/widgets/user_list_item.dart
import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';

class UserListItem extends StatelessWidget {
  final UserEntity user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const UserListItem({
    Key? key,
    required this.user,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        child: Icon(Icons.person),
      ),
      title: Text(user.fullname),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Email: ${user.email}'),
          if (user.phone != null) Text('Phone: ${user.phone}'),
          if (user.className != null) Text('Class: ${user.className}'),
          if (user.dateOfBirth != null)
            Text('BirthDay: ${user.dateOfBirth!.toIso8601String().split('T')[0]}'),
          if (user.cccd != null) Text('CCCD: ${user.cccd}'),
          if (user.className != null) Text('Created at: ${user.className}'),
          if (user.createdAt != null) Text('Created at: ${user.createdAt}'),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}