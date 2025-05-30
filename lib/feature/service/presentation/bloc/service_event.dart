import 'package:equatable/equatable.dart';
import '../../domain/entities/service_entity.dart';
import '../../domain/entities/service_rate_entity.dart';

abstract class ServiceEvent extends Equatable {
  const ServiceEvent();

  @override
  List<Object?> get props => [];
}

class FetchServices extends ServiceEvent {
  final int page;
  final int limit;

  const FetchServices({this.page = 1, this.limit = 10});

  @override
  List<Object?> get props => [page, limit];
}

class FetchServiceById extends ServiceEvent {
  final int serviceId;

  const FetchServiceById(this.serviceId);

  @override
  List<Object?> get props => [serviceId];
}

class CreateNewService extends ServiceEvent {
  final Service service;

  const CreateNewService(this.service);

  @override
  List<Object?> get props => [service];
}

class UpdateExistingService extends ServiceEvent {
  final int serviceId;
  final Service service;

  const UpdateExistingService(this.serviceId, this.service);

  @override
  List<Object?> get props => [serviceId, service];
}

class DeleteServiceEvent extends ServiceEvent {
  final int serviceId;

  const DeleteServiceEvent(this.serviceId);

  @override
  List<Object?> get props => [serviceId];
}

class FetchServiceRates extends ServiceEvent {
  final int? serviceId;
  final int page;
  final int limit;

  const FetchServiceRates({this.serviceId, this.page = 1, this.limit = 10});

  @override
  List<Object?> get props => [serviceId, page, limit];
}

class FetchCurrentServiceRate extends ServiceEvent {
  final int serviceId;

  const FetchCurrentServiceRate(this.serviceId);

  @override
  List<Object?> get props => [serviceId];
}

class CreateNewServiceRate extends ServiceEvent {
  final ServiceRate serviceRate;

  const CreateNewServiceRate(this.serviceRate);

  @override
  List<Object?> get props => [serviceRate];
}

class DeleteServiceRateEvent extends ServiceEvent {
  final int rateId;

  const DeleteServiceRateEvent(this.rateId);

  @override
  List<Object?> get props => [rateId];
}