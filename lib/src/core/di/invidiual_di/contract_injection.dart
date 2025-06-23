import 'package:datn_web_admin/feature/contract/domain/usecase/contract_usecase.dart';
import 'package:get_it/get_it.dart';

import '../../../../feature/contract/data/datasource/contract_data_source.dart';
import '../../../../feature/contract/data/repository/contract_repository_impl.dart';
import '../../../../feature/contract/domain/repository/contract_repository.dart';
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

  getIt.registerSingleton<ExportContractPdf>(
    ExportContractPdf(getIt<ContractRepository>()),
  );

  getIt.registerFactory<ContractBloc>(() => ContractBloc(
    getAllContracts: getIt<GetAllContracts>(),
    getContractById: getIt<GetContractById>(),
    createContract: getIt<CreateContract>(),
    updateContract: getIt<UpdateContract>(),
    deleteContract: getIt<DeleteContract>(),
    updateContractStatus: getIt<UpdateContractStatus>(),
    exportContractPdf: getIt<ExportContractPdf>(),
  ));
}