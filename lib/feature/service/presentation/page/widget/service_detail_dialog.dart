import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:datn_web_admin/feature/service/domain/entities/service_entity.dart';
import 'package:datn_web_admin/feature/service/presentation/bloc/service_bloc.dart';
import 'package:datn_web_admin/feature/service/presentation/bloc/service_event.dart';
import 'package:datn_web_admin/feature/service/presentation/bloc/service_state.dart';
import 'package:datn_web_admin/feature/service/presentation/page/widget/service_rates_dialog.dart';
import 'package:datn_web_admin/feature/service/presentation/page/widget/set_service_rate_dialog.dart';

class ServiceDetailDialog extends StatefulWidget {
  final Service service;

  const ServiceDetailDialog({Key? key, required this.service}) : super(key: key);

  @override
  _ServiceDetailDialogState createState() => _ServiceDetailDialogState();
}

class _ServiceDetailDialogState extends State<ServiceDetailDialog> {
  final _nameController = TextEditingController();
  final _unitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.service.name;
    _unitController.text = widget.service.unit;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _updateService() {
    if (widget.service.serviceId != null) {
      context.read<ServiceBloc>().add(UpdateExistingService(
        widget.service.serviceId!,
        Service(
          serviceId: widget.service.serviceId!,
          name: _nameController.text,
          unit: _unitController.text,
        ),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể cập nhật dịch vụ: ID không hợp lệ.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _addServiceRate() {
    showDialog(
      context: context,
      builder: (context) => SetServiceRateDialog(serviceId: widget.service.serviceId!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ServiceBloc, ServiceState>(
      listener: (context, state) {
        if (state is ServiceUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật dịch vụ thành công!'),
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
        }
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            minWidth: 400,
            minHeight: 200,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 5),
              ],
            ),
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
                        _buildInfoRow(Icons.text_fields, 'Tên dịch vụ:', Colors.black),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 10),
                        _buildInfoRow(Icons.add, 'Đơn vị tính:', Colors.black),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _unitController,
                          decoration: const InputDecoration(border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildInfoRow(Icons.price_check, 'Danh sách mức giá:', Colors.black),
                              IconButton(
                                icon: const Icon(Icons.list, color: Colors.blue),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => ServiceRatesDialog(serviceId: widget.service.serviceId),
                                  );
                                },
                                tooltip: 'Xem danh sách mức giá',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: _updateService,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Cập nhật', style: TextStyle(color: Colors.white)),
                            ),
                            ElevatedButton.icon(
                              onPressed: _addServiceRate,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.add),
                              label: const Text('Thêm mức giá'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
        Text(
          text,
          style: TextStyle(fontSize: 16, color: textColor),
          softWrap: true,
        ),
      ],
    );
  }
}