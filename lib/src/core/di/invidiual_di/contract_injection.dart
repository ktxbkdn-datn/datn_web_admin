import 'package:get_it/get_it.dart';

import '../../../../feature/contract/data/datasource/contract_data_source.dart';
import '../../../../feature/contract/data/repository/contract_repository_impl.dart';
import '../../../../feature/contract/domain/repository/contract_repository.dart';
import '../../../../feature/contract/domain/usecase/create_contract.dart';
import '../../../../feature/contract/domain/usecase/delete_contract.dart';
import '../../../../feature/contract/domain/usecase/get_all_contracts.dart';
import '../../../../feature/contract/domain/usecase/get_contract_by_id.dart';
import '../../../../feature/contract/domain/usecase/update_contract.dart';
import '../../../../feature/contract/domain/usecase/update_contract_status.dart';
import '../../../../feature/contract/presentation/bloc/contract_bloc.dart';
import '../../network/api_client.dart';

final getIt = GetIt.instance;

void registerContractDependencies() {
  getIt.registerSingleton<ContractRemoteDataSource>(
    ContractRemoteDataSourceImpl(getIt<ApiService>()),
  );

  getIt.registerSingleton<ContractRepository>(
    ContractRepositoryImpl(getIt<ContractRemoteDataSource>()),
  );

  getIt.registerSingleton<GetAllContracts>(
    GetAllContracts(getIt<ContractRepository>()),
  );

  getIt.registerSingleton<GetContractById>(
    GetContractById(getIt<ContractRepository>()),
  );

  getIt.registerSingleton<CreateContract>(
    CreateContract(getIt<ContractRepository>()),
  );

  getIt.registerSingleton<UpdateContract>(
    UpdateContract(getIt<ContractRepository>()),
  );

  getIt.registerSingleton<DeleteContract>(
    DeleteContract(getIt<ContractRepository>()),
  );

  getIt.registerSingleton<UpdateContractStatus>(
    UpdateContractStatus(getIt<ContractRepository>()),
  );

  getIt.registerFactory<ContractBloc>(() => ContractBloc(
    getAllContracts: getIt<GetAllContracts>(),
    getContractById: getIt<GetContractById>(),
    createContract: getIt<CreateContract>(),
    updateContract: getIt<UpdateContract>(),
    deleteContract: getIt<DeleteContract>(),
    updateContractStatus: getIt<UpdateContractStatus>(),
  ));
}