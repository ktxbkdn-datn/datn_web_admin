import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecase/rate/create_service_rate.dart';
import '../../domain/usecase/rate/delete_service_rate.dart';
import '../../domain/usecase/rate/get_current_service_rate.dart';
import '../../domain/usecase/rate/get_service_rate.dart';
import '../../domain/usecase/service/create_service.dart';
import '../../domain/usecase/service/delete_service.dart';
import '../../domain/usecase/service/get_all_service.dart';
import '../../domain/usecase/service/get_service_by_id.dart';
import '../../domain/usecase/service/update_service.dart';
import 'service_event.dart';
import 'service_state.dart';

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  final GetAllServices getAllServices;
  final GetServiceById getServiceById;
  final CreateService createService;
  final UpdateService updateService;
  final DeleteService deleteService;
  final GetServiceRates getServiceRates;
  final GetCurrentServiceRate getCurrentServiceRate;
  final CreateServiceRate createServiceRate;
  final DeleteServiceRate deleteServiceRate;

  ServiceBloc({
    required this.getAllServices,
    required this.getServiceById,
    required this.createService,
    required this.updateService,
    required this.deleteService,
    required this.getServiceRates,
    required this.getCurrentServiceRate,
    required this.createServiceRate,
    required this.deleteServiceRate,
  }) : super(ServiceInitial()) {
    on<FetchServices>(_onFetchServices);
    on<FetchServiceById>(_onFetchServiceById);
    on<CreateNewService>(_onCreateService);
    on<UpdateExistingService>(_onUpdateService);
    on<DeleteServiceEvent>(_onDeleteService);
    on<FetchServiceRates>(_onFetchServiceRates);
    on<FetchCurrentServiceRate>(_onFetchCurrentServiceRate);
    on<CreateNewServiceRate>(_onCreateServiceRate);
    on<DeleteServiceRateEvent>(_onDeleteServiceRate);
  }

  Future<void> _onFetchServices(FetchServices event, Emitter<ServiceState> emit) async {
    emit(ServiceLoading());
    final result = await getAllServices(page: event.page, limit: event.limit);
    result.fold(
          (failure) => emit(ServiceError(failure.message)),
          (services) => emit(ServicesLoaded(
        services: services,
        total: services.length,
        pages: (services.length / event.limit).ceil(),
        currentPage: event.page,
      )),
    );
  }

  Future<void> _onFetchServiceById(FetchServiceById event, Emitter<ServiceState> emit) async {
    emit(ServiceLoading());
    final result = await getServiceById(event.serviceId);
    result.fold(
          (failure) => emit(ServiceError(failure.message)),
          (service) => emit(ServiceDetailLoaded(service)),
    );
  }

  Future<void> _onCreateService(CreateNewService event, Emitter<ServiceState> emit) async {
    emit(ServiceLoading());
    final result = await createService(event.service);
    result.fold(
          (failure) => emit(ServiceError(failure.message)),
          (service) => emit(ServiceCreated(service)),
    );
  }

  Future<void> _onUpdateService(UpdateExistingService event, Emitter<ServiceState> emit) async {
    emit(ServiceLoading());
    final result = await updateService(event.serviceId, event.service);
    result.fold(
          (failure) => emit(ServiceError(failure.message)),
          (service) => emit(ServiceUpdated(service)),
    );
  }

  Future<void> _onDeleteService(DeleteServiceEvent event, Emitter<ServiceState> emit) async {
    emit(ServiceLoading());
    final result = await deleteService(event.serviceId);
    result.fold(
          (failure) => emit(ServiceError(failure.message)),
          (_) => emit(ServiceDeleted(
        deletedId: event.serviceId,
        message: 'Xóa dịch vụ thành công',
      )),
    );
  }

  Future<void> _onFetchServiceRates(FetchServiceRates event, Emitter<ServiceState> emit) async {
    emit(ServiceLoading());
    final result = await getServiceRates(
      serviceId: event.serviceId,
      page: event.page,
      limit: event.limit,
    );
    result.fold(
          (failure) => emit(ServiceError(failure.message)),
          (serviceRates) => emit(ServiceRatesLoaded(
        serviceRates: serviceRates,
        total: serviceRates.length,
        pages: (serviceRates.length / event.limit).ceil(),
        currentPage: event.page,
      )),
    );
  }

  Future<void> _onFetchCurrentServiceRate(FetchCurrentServiceRate event, Emitter<ServiceState> emit) async {
    emit(ServiceLoading());
    final result = await getCurrentServiceRate(event.serviceId);
    result.fold(
          (failure) => emit(ServiceError(failure.message)),
          (serviceRate) => emit(CurrentServiceRateLoaded(serviceRate)),
    );
  }

  Future<void> _onCreateServiceRate(CreateNewServiceRate event, Emitter<ServiceState> emit) async {
    emit(ServiceLoading());
    final result = await createServiceRate(event.serviceRate);
    result.fold(
          (failure) => emit(ServiceError(failure.message)),
          (serviceRate) => emit(ServiceRateCreated(serviceRate)),
    );
  }

  Future<void> _onDeleteServiceRate(DeleteServiceRateEvent event, Emitter<ServiceState> emit) async {
    emit(ServiceLoading());
    final result = await deleteServiceRate(event.rateId);
    result.fold(
          (failure) => emit(ServiceError(failure.message)),
          (_) => emit(ServiceRateDeleted(
        deletedId: event.rateId,
        message: 'Xóa mức giá thành công',
      )),
    );
  }
}