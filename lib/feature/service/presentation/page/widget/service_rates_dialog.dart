import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:datn_web_admin/feature/service/domain/entities/service_rate_entity.dart';
import 'package:datn_web_admin/feature/service/presentation/bloc/service_bloc.dart';
import 'package:datn_web_admin/feature/service/presentation/bloc/service_event.dart';
import 'package:datn_web_admin/feature/service/presentation/bloc/service_state.dart';

class ServiceRatesDialog extends StatefulWidget {
  final int serviceId;

  const ServiceRatesDialog({Key? key, required this.serviceId}) : super(key: key);

  @override
  _ServiceRatesDialogState createState() => _ServiceRatesDialogState();
}

class _ServiceRatesDialogState extends State<ServiceRatesDialog> {
  List<ServiceRate> _serviceRates = [];

  @override
  void initState() {
    super.initState();
    context.read<ServiceBloc>().add(FetchServiceRates(serviceId: widget.serviceId));
  }

  void _deleteServiceRate(int rateId) {
    context.read<ServiceBloc>().add(DeleteServiceRateEvent(rateId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ServiceBloc, ServiceState>(
      listener: (context, state) {
        if (state is ServiceRateDeleted) {
          setState(() {
            _serviceRates.removeWhere((rate) => rate.rateId == state.deletedId);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message ?? 'Xóa mức giá thành công!'),
              backgroundColor: Colors.green,),
          );
        } else if (state is ServiceError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: ${state.message}')),
          );
        }
      },
      child: Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.6,
          height: MediaQuery.of(context).size.height * 0.6,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Danh sách mức giá', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: BlocBuilder<ServiceBloc, ServiceState>(
                  builder: (context, state) {
                    if (state is ServiceLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ServiceRatesLoaded) {
                      _serviceRates = state.serviceRates;
                    }
                    return _serviceRates.isEmpty
                        ? const Center(child: Text('Không có mức giá nào.'))
                        : ListView.builder(
                      itemCount: _serviceRates.length,
                      itemBuilder: (context, index) {
                        final rate = _serviceRates[index];
                        final isFutureRate = rate.effectiveDate.isAfter(DateTime.now());
                        return Card(
                          child: ListTile(
                            title: Text('${rate.unitPrice.toStringAsFixed(2)} VNĐ'),
                            subtitle: Text(
                              'Áp dụng từ: ${rate.effectiveDate.day}/${rate.effectiveDate.month}/${rate.effectiveDate.year}',
                            ),
                            trailing: isFutureRate
                                ? IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteServiceRate(rate.rateId!),
                              tooltip: 'Xóa mức giá',
                            )
                                : null,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}