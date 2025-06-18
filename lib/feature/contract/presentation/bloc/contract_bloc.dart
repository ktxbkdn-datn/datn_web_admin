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
  final UpdateContractStatus updateContractStatus;
  List<Contract> _contracts = []; // Lưu trữ hợp đồng trang hiện tại
  static const int _limit = 10; // Định nghĩa limit cố định, đồng bộ với ContractListPage

  ContractBloc({
    required this.getAllContracts,
    required this.getContractById,
    required this.createContract,
    required this.updateContract,
    required this.deleteContract,
    required this.updateContractStatus,
  }) : super(ContractInitial()) {
    on<FetchAllContractsEvent>(_onFetchAllContracts);
    on<FetchContractByIdEvent>(_onFetchContractById);
    on<CreateContractEvent>(_onCreateContract);
    on<UpdateContractEvent>(_onUpdateContract);
    on<DeleteContractEvent>(_onDeleteContract);
    on<UpdateContractStatusEvent>(_onUpdateContractStatus);
  }

  Future<void> _onFetchAllContracts(FetchAllContractsEvent event, Emitter<ContractState> emit) async {
    emit(const ContractLoading());
    try {
      final result = await getAllContracts(
        page: event.page,
        limit: event.limit,
        keyword: event.keyword, // Thêm dòng này
        email: event.email,
        status: event.status,
        startDate: event.startDate,
        endDate: event.endDate,
        contractType: event.contractType,
      );

      result.fold(
        (failure) => emit(const ContractListLoaded(contracts: [], totalItems: 0)), // Không emit ContractError
        (tuple) {
          final contracts = tuple.$1;
          final totalItems = tuple.$2;
          _contracts = contracts;
          emit(ContractListLoaded(contracts: contracts, totalItems: totalItems));
        },
      );
    } catch (e) {
      emit(const ContractListLoaded(contracts: [], totalItems: 0)); // Không emit ContractError
    }
  }

  Future<void> _onFetchContractById(FetchContractByIdEvent event, Emitter<ContractState> emit) async {
    emit(const ContractLoading());
    final result = await getContractById(event.contractId);
    result.fold(
      (failure) => emit(ContractError(failure: failure, errorMessage: failure.message)),
      (contract) {
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
        emit(const ContractCreated(successMessage: 'Tạo hợp đồng thành công'));
        add(FetchAllContractsEvent(page: 1, limit: _limit)); // Sử dụng _limit đã định nghĩa
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
        add(FetchAllContractsEvent(page: 1, limit: _limit)); // Sử dụng _limit đã định nghĩa
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
          contractId: event.contractId,
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
        emit(const ContractStatusUpdated(successMessage: 'Cập nhật trạng thái hợp đồng thành công'));
        add(FetchAllContractsEvent(page: 1, limit: _limit)); // Sử dụng _limit đã định nghĩa
      },
    );
  }
}