import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../src/core/error/failures.dart';
import '../../domain/entities/contract_entity.dart';

import '../../domain/usecase/create_contract.dart';
import '../../domain/usecase/delete_contract.dart';
import '../../domain/usecase/get_all_contracts.dart';
import '../../domain/usecase/get_contract_by_id.dart';
import '../../domain/usecase/update_contract.dart';
import '../../domain/usecase/update_contract_status.dart';
import 'contract_event.dart';
import 'contract_state.dart';

class ContractBloc extends Bloc<ContractEvent, ContractState> {
  final GetAllContracts getAllContracts;
  final GetContractById getContractById;
  final CreateContract createContract;
  final UpdateContract updateContract;
  final DeleteContract deleteContract;
  final UpdateContractStatus updateContractStatus; // Thêm use case
  List<Contract> _contracts = []; // Lưu trữ danh sách hợp đồng cục bộ

  ContractBloc({
    required this.getAllContracts,
    required this.getContractById,
    required this.createContract,
    required this.updateContract,
    required this.deleteContract,
    required this.updateContractStatus, // Thêm vào constructor
  }) : super(ContractInitial()) {
    on<FetchAllContractsEvent>(_onFetchAllContracts);
    on<FetchContractByIdEvent>(_onFetchContractById);
    on<CreateContractEvent>(_onCreateContract);
    on<UpdateContractEvent>(_onUpdateContract);
    on<DeleteContractEvent>(_onDeleteContract);
    on<UpdateContractStatusEvent>(_onUpdateContractStatus); // Thêm handler
  }

  Future<void> _onFetchAllContracts(FetchAllContractsEvent event, Emitter<ContractState> emit) async {
    emit(const ContractLoading());
    final result = await getAllContracts(
      page: event.page,
      limit: event.limit,
      email: event.email,
      status: event.status,
      startDate: event.startDate,
      endDate: event.endDate,
      contractType: event.contractType,
    );
    result.fold(
          (failure) => emit(ContractError(failure: failure, errorMessage: failure.message)),
          (contracts) {
        _contracts = contracts; // Cập nhật danh sách hợp đồng cục bộ
        emit(ContractListLoaded(contracts: contracts));
      },
    );
  }

  Future<void> _onFetchContractById(FetchContractByIdEvent event, Emitter<ContractState> emit) async {
    emit(const ContractLoading());
    final result = await getContractById(event.contractId);
    result.fold(
          (failure) => emit(ContractError(failure: failure, errorMessage: failure.message)),
          (contract) {
        // Cập nhật danh sách hợp đồng cục bộ nếu hợp đồng đã tồn tại
        final updatedContracts = _contracts.map((c) => c.contractId == contract.contractId ? contract : c).toList();
        if (!_contracts.any((c) => c.contractId == contract.contractId)) {
          updatedContracts.add(contract);
        }
        _contracts = updatedContracts;
        emit(ContractLoaded(contract: contract));
      },
    );
  }

  Future<void> _onCreateContract(CreateContractEvent event, Emitter<ContractState> emit) async {
    emit(const ContractLoading());
    final result = await createContract(event.contract, event.areaId);
    result.fold(
          (failure) => emit(ContractError(failure: failure, errorMessage: failure.message)),
          (contract) {
        // Không thêm hợp đồng mới vào danh sách cục bộ, UI sẽ gọi FetchAllContractsEvent để reload
        emit(const ContractCreated(successMessage: 'Tạo hợp đồng thành công'));
      },
    );
  }

  Future<void> _onUpdateContract(UpdateContractEvent event, Emitter<ContractState> emit) async {
    emit(const ContractLoading());
    final result = await updateContract(event.contractId, event.contract, event.areaId);
    result.fold(
          (failure) => emit(ContractError(failure: failure, errorMessage: failure.message)),
          (contract) {
        final updatedContracts = _contracts.map((c) => c.contractId == contract.contractId ? contract : c).toList();
        _contracts = updatedContracts;
        emit(ContractUpdated(contract: contract, successMessage: 'Cập nhật hợp đồng thành công'));
      },
    );
  }

  Future<void> _onDeleteContract(DeleteContractEvent event, Emitter<ContractState> emit) async {
    emit(const ContractLoading());
    final result = await deleteContract(event.contractId);
    result.fold(
          (failure) => emit(ContractError(failure: failure, errorMessage: failure.message)),
          (_) {
        final updatedContracts = _contracts.where((contract) => contract.contractId != event.contractId).toList();
        _contracts = updatedContracts;
        emit(ContractDeleted(
          contractId: event.contractId, // Truyền contractId vào trạng thái
          contracts: updatedContracts,
          successMessage: 'Xóa hợp đồng thành công',
        ));
      },
    );
  }

  Future<void> _onUpdateContractStatus(UpdateContractStatusEvent event, Emitter<ContractState> emit) async {
    emit(const ContractLoading());
    final result = await updateContractStatus();
    result.fold(
          (failure) => emit(ContractError(failure: failure, errorMessage: failure.message)),
          (_) {
        // Sau khi cập nhật trạng thái, có thể gọi lại FetchAllContractsEvent để làm mới danh sách hợp đồng
        add(const FetchAllContractsEvent());
        emit(const ContractStatusUpdated(successMessage: 'Cập nhật trạng thái hợp đồng thành công'));
      },
    );
  }
}