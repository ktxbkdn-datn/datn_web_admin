import 'package:equatable/equatable.dart';

import '../../domain/entities/contract_entity.dart';

abstract class ContractEvent extends Equatable {
  const ContractEvent();

  @override
  List<Object?> get props => [];
}

class FetchAllContractsEvent extends ContractEvent {
  final int page;
  final int limit;
  final String? email;
  final String? status;
  final String? startDate;
  final String? endDate;
  final String? contractType;

  const FetchAllContractsEvent({
    this.page = 1,
    this.limit = 10,
    this.email,
    this.status,
    this.startDate,
    this.endDate,
    this.contractType,
  });

  @override
  List<Object?> get props => [page, limit, email, status, startDate, endDate, contractType];
}

class FetchContractByIdEvent extends ContractEvent {
  final int contractId;

  const FetchContractByIdEvent(this.contractId);

  @override
  List<Object?> get props => [contractId];
}

class CreateContractEvent extends ContractEvent {
  final Contract contract;
  final int areaId;

  const CreateContractEvent({
    required this.contract,
    required this.areaId,
  });

  @override
  List<Object?> get props => [contract, areaId];
}

class UpdateContractEvent extends ContractEvent {
  final int contractId;
  final Contract contract;
  final int areaId;

  const UpdateContractEvent({
    required this.contractId,
    required this.contract,
    required this.areaId,
  });

  @override
  List<Object?> get props => [contractId, contract, areaId];
}

class DeleteContractEvent extends ContractEvent {
  final int contractId;

  const DeleteContractEvent(this.contractId);

  @override
  List<Object?> get props => [contractId];
}

class UpdateContractStatusEvent extends ContractEvent {} // Thêm sự kiện mới