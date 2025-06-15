import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/contract_entity.dart';
import '../bloc/contract_bloc.dart';
import '../bloc/contract_event.dart';
import '../bloc/contract_state.dart';
import 'contract_form_widget.dart';

class CreateContractDialog extends StatefulWidget {
  const CreateContractDialog({Key? key}) : super(key: key);

  @override
  _CreateContractDialogState createState() => _CreateContractDialogState();
}

class _CreateContractDialogState extends State<CreateContractDialog> {
  final _formKey = GlobalKey<FormState>();
  final _roomNameController = TextEditingController();
  final _userEmailController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  int? _areaId;
  String? _contractType;
  bool _isProcessing = false;
  int _pendingOperations = 0;
  bool _hasShownSuccessMessage = false;
  bool _hasShownErrorMessage = false;

  @override
  void dispose() {
    _roomNameController.dispose();
    _userEmailController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  void _updatePendingOperations(int change) {
    setState(() {
      _pendingOperations += change;
      _isProcessing = _pendingOperations > 0;
      print('Pending operations: $_pendingOperations, IsProcessing: $_isProcessing');
    });
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)), // Cho phép chọn ngày trong 10 năm tới
    );
    if (pickedDate != null) {
      setState(() {
        _selectedStartDate = pickedDate;
        _startDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? DateTime.now(),
      firstDate: _selectedStartDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedEndDate = pickedDate;
        _endDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _createContract() async {
    if (_isProcessing) return;

    if (_formKey.currentState!.validate()) {
      _updatePendingOperations(1);

      try {
        context.read<ContractBloc>().add(CreateContractEvent(
          contract: Contract(
            contractId: 0,
            roomId: 0,
            userId: 0,
            status: 'PENDING',
            createdAt: DateTime.now().toIso8601String(),
            contractType: _contractType!,
            startDate: _startDateController.text,
            endDate: _endDateController.text,
            roomName: _roomNameController.text,
            userEmail: _userEmailController.text,
          ),
          areaId: _areaId!,
        ));
      } catch (e) {
        print('Error creating contract: $e');
        _updatePendingOperations(-1);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(' $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: LayoutBuilder(
            builder: (context, constraints) {
              double screenWidth = MediaQuery.of(context).size.width;
              double screenHeight = MediaQuery.of(context).size.height;

              double dialogWidth = screenWidth < 600
                  ? screenWidth * 0.9
                  : screenWidth < 1200
                  ? screenWidth * 0.7
                  : 800;
              double dialogHeight = screenHeight < 600
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
                    if (state is ContractCreated && !_hasShownSuccessMessage) {
                      print('Contract Created Successfully');
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
                      _updatePendingOperations(-1);
                      Future.delayed(const Duration(seconds: 2), () {
                        if (mounted) {
                          Navigator.of(context).pop();
                        }
                      });
                    } else if (state is ContractError && !_hasShownErrorMessage) {
                      print('Contract Creation Error: ${state.errorMessage}');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Lỗi: ${state.errorMessage}'),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                      setState(() {
                        _hasShownErrorMessage = true;
                      });
                      _updatePendingOperations(-1);
                    }
                  },
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tạo Hợp đồng Mới',
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
                            userEmailController: _userEmailController,
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
                            onStartDateTap: () => _selectStartDate(context),
                            onEndDateTap: () => _selectEndDate(context),
                            showContractTypeField: true,
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
                            onPressed: _isProcessing ? null : _createContract,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: _isProcessing
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : const Text(
                              'Tạo',
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
        ),
        if (_isProcessing)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}