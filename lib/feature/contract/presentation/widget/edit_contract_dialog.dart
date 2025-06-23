import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/contract_entity.dart';
import '../bloc/contract_bloc.dart';
import '../bloc/contract_event.dart';
import '../bloc/contract_state.dart';
import 'contract_form_widget.dart';

class EditContractDialog extends StatefulWidget {
  final Contract contract;

  const EditContractDialog({Key? key, required this.contract}) : super(key: key);

  @override
  _EditContractDialogState createState() => _EditContractDialogState();
}

class _EditContractDialogState extends State<EditContractDialog> {
  final _formKey = GlobalKey<FormState>();
  final _roomNameController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _studentCodeController = TextEditingController();
  int? _areaId;
  String? _contractType;
  bool _hasShownSuccessMessage = false;
  bool _hasShownErrorMessage = false;

  @override
  void initState() {
    super.initState();
    _roomNameController.text = widget.contract.roomName;
    _startDateController.text = widget.contract.startDate;
    _endDateController.text = widget.contract.endDate;
    _contractType = widget.contract.contractType;
    _areaId = null;
    _studentCodeController.text = widget.contract.studentCode ?? '';
  }

  @override
  void dispose() {
    _roomNameController.dispose();
    _studentCodeController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<ContractBloc>().add(UpdateContractEvent(
        contractId: widget.contract.contractId,
        contract: Contract(
          contractId: widget.contract.contractId,
          roomId: widget.contract.roomId,
          userId: widget.contract.userId,
          status: widget.contract.status,
          createdAt: widget.contract.createdAt,
          contractType: _contractType!,
          startDate: _startDateController.text,
          endDate: _endDateController.text,
          roomName: _roomNameController.text,
          studentCode: _studentCodeController.text,
        ),
        areaId: _areaId!,
        studentCode: _studentCodeController.text,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = MediaQuery.of(context).size.width;
          double screenHeight = MediaQuery.of(context).size.height;

          double dialogWidth = screenWidth < 800
              ? screenWidth * 0.9
              : screenWidth < 1200
              ? screenWidth * 0.7
              : 800;
          double dialogHeight = screenHeight < 800
              ? screenHeight * 0.9
              : screenHeight < 900
              ? screenHeight * 0.8
              : 600;

          return Container(
            width: dialogWidth,
            height: dialogHeight,
            padding: const EdgeInsets.all(24),
            child: BlocListener<ContractBloc, ContractState>(
              listener: (context, state) {
                if (state is ContractUpdated && !_hasShownSuccessMessage) {
                  print('Contract Updated Successfully');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.successMessage),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  setState(() {
                    _hasShownSuccessMessage = true;
                  });
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  });
                } else if (state is ContractError && !_hasShownErrorMessage) {
                  print('Contract Update Error: ${state.errorMessage}');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${state.errorMessage}'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                  setState(() {
                    _hasShownErrorMessage = true;
                  });
                }
              },
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Chỉnh sửa Hợp đồng',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: ContractFormWidget(
                        formKey: _formKey,
                        roomNameController: _roomNameController,
                        startDateController: _startDateController,
                        endDateController: _endDateController,
                        areaId: _areaId,
                        onAreaChanged: (value) {
                          setState(() {
                            _areaId = value;
                          });
                        },
                        contractType: _contractType,
                        onContractTypeChanged: (value) {
                          setState(() {
                            _contractType = value;
                          });
                        },
                        showContractTypeField: true,
                        studentCodeController: _studentCodeController,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Hủy',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text(
                          'Lưu',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}