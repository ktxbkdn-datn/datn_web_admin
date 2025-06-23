import 'package:datn_web_admin/feature/bill/data/models/bill_detail_model.dart' as model;
import 'package:datn_web_admin/feature/bill/domain/usecase/bill_usecase.dart' as use_case;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:datn_web_admin/feature/bill/presentation/bloc/bill_event.dart';
import 'package:datn_web_admin/feature/bill/presentation/bloc/bill_state.dart';

import '../../domain/entities/monthly_bill_entity.dart';

class BillBloc extends Bloc<BillEvent, BillState> {
  final use_case.CreateMonthlyBillsBulk createMonthlyBillsBulk;
  final use_case.GetAllBillDetails getAllBillDetails;
  final use_case.GetAllMonthlyBills getAllMonthlyBills;
  final use_case.DeletePaidBills deletePaidBills;
  final use_case.DeleteBillDetail deleteBillDetail;
  final use_case.DeleteMonthlyBill deleteMonthlyBill;
  final use_case.NotifyRemindBillDetail notifyRemindBillDetail;
  final use_case.NotifyRemindPayment notifyRemindPayment;
  final use_case.GetRoomBillDetails getRoomBillDetails;

  final Map<int, (List<MonthlyBill>, int)> _pageCache = {};
  static const int _maxCachedPages = 5;
  BillBloc({
    required this.createMonthlyBillsBulk,
    required this.getAllBillDetails,
    required this.getAllMonthlyBills,
    required this.deletePaidBills,
    required this.deleteBillDetail,
    required this.deleteMonthlyBill,
    required this.notifyRemindBillDetail,
    required this.notifyRemindPayment,
    required this.getRoomBillDetails,
  }) : super(BillInitial()) {
    on<CreateMonthlyBillsBulk>(_onCreateMonthlyBillsBulk);
    on<NotifyRemindBillDetailEvent>(_onNotifyRemindBillDetail);
    on<NotifyRemindPaymentEvent>(_onNotifyRemindPayment);
    on<GetRoomBillDetailsEvent>(_onGetRoomBillDetails);
    on<FetchAllBillDetails>((event, emit) async {
      emit(BillLoading());
      final result = await getAllBillDetails(
        page: event.page,
        limit: event.limit,
        area: event.area,
        service: event.service,
        billStatus: event.billStatus,
        paymentStatus: event.paymentStatus,
        search: event.search,
        month: event.month,
        submissionStatus: event.submissionStatus,
      );
      result.fold(
        (failure) => emit(BillError(failure.message)),
        (data) {
          final billDetailsRaw = data['billDetails'] as List;
          final billDetails = billDetailsRaw
              .map((e) => (e as model.BillDetailModel).toEntity())
              .toList();
          emit(BillDetailsLoaded(
            billDetails: billDetails,
            total: data['total'] as int,
            pages: data['pages'] as int,
            currentPage: data['currentPage'] as int,
          ));
        },
      );
    });
    on<FetchAllMonthlyBills>((event, emit) async {
      emit(BillLoading());
      final result = await getAllMonthlyBills(
        page: event.page,
        limit: event.limit,
        area: event.area,
        paymentStatus: event.paymentStatus,
        service: event.service,
        month: event.month,
        billStatus: event.billStatus,
        search: event.search,
      );
      result.fold(
            (failure) => emit(BillError(failure.message)),
            (data) {
          final monthlyBills = data.$1;
          final total = data.$2;
          _cachePage(event.page, monthlyBills, total);
          emit(MonthlyBillsLoaded(
            monthlyBills: monthlyBills,
            total: total,
            pages: (total / event.limit).ceil(),
            currentPage: event.page,
          ));
        },
      );
    });
    on<DeletePaidBillsEvent>(_onDeletePaidBills);
    on<DeleteBillDetailEvent>(_onDeleteBillDetail);
    on<DeleteMonthlyBillEvent>(_onDeleteMonthlyBill);
  }

  void _clearCache() {
    _pageCache.clear();
  }

  void _cachePage(int page, List<MonthlyBill> bills, int total) {
    _pageCache[page] = (bills, total);
    if (_pageCache.length > _maxCachedPages) {
      final oldestPage = _pageCache.keys.reduce((a, b) => a < b ? a : b);
      _pageCache.remove(oldestPage);
    }
  }

  Future<void> _onCreateMonthlyBillsBulk(CreateMonthlyBillsBulk event, Emitter<BillState> emit) async {
    emit(BillLoading());
    final result = await createMonthlyBillsBulk(
      billMonth: event.billMonth,
      roomIds: event.roomIds,
    );
    result.fold(
          (failure) => emit(BillError(failure.message)),
          (response) {
        _clearCache();
        emit(MonthlyBillsCreated(
          billsCreated: response['bills_created'] ?? [],
          errors: response['errors'] ?? [],
          message: response['message'] ?? 'Tạo hóa đơn hàng tháng hoàn tất',
        ));
      },
    );
  }

  Future<void> _onFetchAllMonthlyBills(FetchAllMonthlyBills event, Emitter<BillState> emit) async {
    if (_pageCache.containsKey(event.page)) {
      final (cachedBills, cachedTotal) = _pageCache[event.page]!;
      emit(MonthlyBillsLoaded(
        monthlyBills: cachedBills,
        total: cachedTotal,
        pages: (cachedTotal / event.limit).ceil(),
        currentPage: event.page,
      ));
      return;
    }

    emit(BillLoading());
    final result = await getAllMonthlyBills(page: event.page, limit: event.limit);
    result.fold(
          (failure) => emit(BillError(failure.message)),
          (data) {
        final monthlyBills = data.$1;
        final total = data.$2;
        _cachePage(event.page, monthlyBills, total);
        emit(MonthlyBillsLoaded(
          monthlyBills: monthlyBills,
          total: total,
          pages: (total / event.limit).ceil(),
          currentPage: event.page,
        ));
      },
    );
  }

  Future<void> _onDeletePaidBills(DeletePaidBillsEvent event, Emitter<BillState> emit) async {
    emit(BillLoading());
    final result = await deletePaidBills(event.billIds);
    result.fold(
          (failure) => emit(BillError(failure.message)),
          (deletedIds) {
        _clearCache();
        emit(PaidBillsDeleted(
          deletedMonthlyBillIds: deletedIds['deleted_monthly_bills'] ?? [],
          deletedBillDetailIds: deletedIds['deleted_bill_details'] ?? [],
          message: 'Xóa các hóa đơn đã thanh toán thành công',
        ));
      },
    );
  }

  Future<void> _onDeleteBillDetail(DeleteBillDetailEvent event, Emitter<BillState> emit) async {
    emit(BillLoading());
    final result = await deleteBillDetail(event.detailId);
    result.fold(
          (failure) {
        if (failure.message == 'Không thể xóa chi tiết hóa đơn vì đã được liên kết với một hóa đơn hàng tháng') {
          emit(BillError('Hãy xóa monthly bill trước rồi mới được xóa báo cáo chỉ số'));
        } else {
          emit(BillError(failure.message));
        }
      },
          (_) => emit(BillDetailDeleted(
        deletedId: event.detailId,
        message: 'Xóa chi tiết hóa đơn thành công',
      )),
    );
  }

  Future<void> _onDeleteMonthlyBill(DeleteMonthlyBillEvent event, Emitter<BillState> emit) async {
    emit(BillLoading());
    final result = await deleteMonthlyBill(event.billId);
    result.fold(
          (failure) => emit(BillError(failure.message)),
          (_) {
        _clearCache();
        emit(MonthlyBillDeleted(
          deletedId: event.billId,
          message: 'Xóa hóa đơn hàng tháng thành công',
        ));
      },
    );
  }
  Future<void> _onNotifyRemindBillDetail(NotifyRemindBillDetailEvent event, Emitter<BillState> emit) async {
    emit(BillLoading());
    final result = await notifyRemindBillDetail(
      billMonth: event.billMonth,
    );
    result.fold(
      (failure) => emit(BillError(failure.message)),
      (response) {
        emit(NotificationSent(
          message: response['message'] ?? 'Đã gửi thông báo nhắc nhở nộp chỉ số thành công',
          notifiedRooms: response['notified_rooms'] as List<dynamic>? ?? [],
        ));
      },
    );
  }
  Future<void> _onNotifyRemindPayment(NotifyRemindPaymentEvent event, Emitter<BillState> emit) async {
    emit(BillLoading());
    final result = await notifyRemindPayment(
      billMonth: event.billMonth,
    );
    result.fold(
      (failure) => emit(BillError(failure.message)),
      (response) {
        emit(NotificationSent(
          message: response['message'] ?? 'Đã gửi thông báo nhắc nhở thanh toán thành công',
          notifiedRooms: response['notified_rooms'] as List<dynamic>? ?? [],
        ));
      },
    );
  }
  Future<void> _onGetRoomBillDetails(GetRoomBillDetailsEvent event, Emitter<BillState> emit) async {
    emit(BillLoading());
    final result = await getRoomBillDetails(
      roomId: event.roomId,
      year: event.year,
      serviceId: event.serviceId,
    );
    result.fold(
      (failure) => emit(BillError(failure.message)),      (roomBillDetails) {
        emit(RoomBillDetailsLoaded(
          roomBillDetails: roomBillDetails,
          roomId: event.roomId,
          year: event.year,
          serviceId: event.serviceId,
        ));
      },
    );
  }
}