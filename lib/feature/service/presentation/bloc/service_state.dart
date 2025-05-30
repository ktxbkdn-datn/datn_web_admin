import 'package:equatable/equatable.dart';
import 'package:datn_web_admin/feature/service/domain/entities/service_entity.dart';
import 'package:datn_web_admin/feature/service/domain/entities/service_rate_entity.dart';

abstract class ServiceState extends Equatable {
  const ServiceState();

  @override
  List<Object?> get props => [];
}

class ServiceInitial extends ServiceState {}

class ServiceLoading extends ServiceState {}

class ServicesLoaded extends ServiceState {
  final List<Service> services;
  final int total;
  final int pages;
  final int currentPage;

  const ServicesLoaded({
    required this.services,
    required this.total,
    required this.pages,
    required this.currentPage,
  });

  @override
  List<Object?> get props => [services, total, pages, currentPage];
}

class ServiceDetailLoaded extends ServiceState {
  final Service service;

  const ServiceDetailLoaded(this.service);

  @override
  List<Object?> get props => [service];
}

class ServiceCreated extends ServiceState {
  final Service service;

  const ServiceCreated(this.service);

  @override
  List<Object?> get props => [service];
}

class ServiceUpdated extends ServiceState {
  final Service service;

  const ServiceUpdated(this.service);

  @override
  List<Object?> get props => [service];
}

class ServiceDeleted extends ServiceState {
  final int deletedId;
  final String? message;

  const ServiceDeleted({
    required this.deletedId,
    this.message,
  });

  @override
  List<Object?> get props => [deletedId, message];
}

class ServiceRatesLoaded extends ServiceState {
  final List<ServiceRate> serviceRates;
  final int total;
  final int pages;
  final int currentPage;

  const ServiceRatesLoaded({
    required this.serviceRates,
    required this.total,
    required this.pages,
    required this.currentPage,
  });

  @override
  List<Object?> get props => [serviceRates, total, pages, currentPage];
}

class CurrentServiceRateLoaded extends ServiceState {
  final ServiceRate serviceRate;

  const CurrentServiceRateLoaded(this.serviceRate);

  @override
  List<Object?> get props => [serviceRate];
}

class NextServiceRateLoaded extends ServiceState {
  final ServiceRate serviceRate;

  const NextServiceRateLoaded(this.serviceRate);

  @override
  List<Object?> get props => [serviceRate];
}

class ServiceRateCreated extends ServiceState {
  final ServiceRate serviceRate;

  const ServiceRateCreated(this.serviceRate);

  @override
  List<Object?> get props => [serviceRate];
}

class ServiceRateUpdated extends ServiceState {
  final ServiceRate serviceRate;

  const ServiceRateUpdated(this.serviceRate);

  @override
  List<Object?> get props => [serviceRate];
}

class ServiceRateDeleted extends ServiceState {
  final int deletedId;
  final String? message;

  const ServiceRateDeleted({
    required this.deletedId,
    this.message,
  });

  @override
  List<Object?> get props => [deletedId, message];
}

class ServiceError extends ServiceState {
  final String message;

  const ServiceError(this.message);

  @override
  List<Object?> get props => [message];
}