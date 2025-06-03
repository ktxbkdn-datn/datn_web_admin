import 'package:equatable/equatable.dart';

import '../../../../src/core/error/failures.dart';
import '../../domain/entities/contract_entity.dart';

abstract class ContractState extends Equatable {
  const ContractState();

  @override
  List<Object?> get props => [];
}

class ContractInitial extends ContractState {}

class ContractLoading extends ContractState {
  final bool isLoading;

  const ContractLoading({this.isLoading = true});

  @override
  List<Object?> get props => [isLoading];
}

class ContractListLoaded extends ContractState {
  final List<Contract> contracts;
  final int totalItems; // Thêm tổng số hợp đồng

  const ContractListLoaded({required this.contracts, required this.totalItems});

  @override
  List<Object?> get props => [contracts, totalItems];
}

class ContractLoaded extends ContractState {
  final Contract contract;

  const ContractLoaded({required this.contract});

  @override
  List<Object?> get props => [contract];
}

class ContractCreated extends ContractState {
  final String successMessage;

  const ContractCreated({required this.successMessage});

  @override
  List<Object?> get props => [successMessage];
}

class ContractUpdated extends ContractState {
  final Contract contract;
  final String successMessage;

  const ContractUpdated({required this.contract, required this.successMessage});

  @override
  List<Object?> get props => [contract, successMessage];
}

class ContractDeleted extends ContractState {
  final int contractId; // Thêm contractId để biết hợp đồng nào bị xóa
  final List<Contract> contracts;
  final String successMessage;

  const ContractDeleted({
    required this.contractId,
    required this.contracts,
    required this.successMessage,
  });

  @override
  List<Object?> get props => [contractId, contracts, successMessage];
}

class ContractStatusUpdated extends ContractState {
  final String successMessage;

  const ContractStatusUpdated({required this.successMessage});

  @override
  List<Object?> get props => [successMessage];
}

class ContractError extends ContractState {
  final Failure failure;
  final String errorMessage;

  const ContractError({required this.failure, required this.errorMessage});

  @override
  List<Object?> get props => [failure, errorMessage];
}

