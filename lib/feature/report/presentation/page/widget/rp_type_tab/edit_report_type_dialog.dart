// lib/src/features/report/presentations/widgets/edit_report_type_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:datn_web_admin/feature/report/domain/entities/report_type_entity.dart';

import '../../../bloc/rp_type/rp_type_bloc.dart';
import '../../../bloc/rp_type/rp_type_event.dart';

class EditReportTypeDialog extends StatefulWidget {
  final ReportTypeEntity reportType;

  const EditReportTypeDialog({Key? key, required this.reportType}) : super(key: key);

  @override
  _EditReportTypeDialogState createState() => _EditReportTypeDialogState();
}

class _EditReportTypeDialogState extends State<EditReportTypeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.reportType.name;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Chỉnh sửa Loại Báo cáo'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên loại báo cáo',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tên loại báo cáo không được để trống';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Hủy', style: TextStyle(color: Colors.black)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              context.read<ReportTypeBloc>().add(UpdateReportTypeEvent(
                reportTypeId: widget.reportType.reportTypeId,
                name: _nameController.text,
              ));
              Navigator.of(context).pop();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Lưu', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}