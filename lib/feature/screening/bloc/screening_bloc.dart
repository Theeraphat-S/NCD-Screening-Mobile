import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app_standard/domain/models/ncd_models.dart';
import 'package:mobile_app_standard/domain/repositories/ncd_repository.dart';
import 'package:mobile_app_standard/domain/services/ncd_risk_calculator.dart';

// EVENTS
abstract class ScreeningEvent extends Equatable {
  const ScreeningEvent();
  @override
  List<Object?> get props => [];
}

class ScreeningHistoryLoadRequested extends ScreeningEvent {
  final String patientId;
  const ScreeningHistoryLoadRequested(this.patientId);
  @override
  List<Object?> get props => [patientId];
}

class ScreeningDetailSelected extends ScreeningEvent {
  final Screening screening;
  const ScreeningDetailSelected(this.screening);
  @override
  List<Object?> get props => [screening];
}

class ScreeningCalculateRiskRequested extends ScreeningEvent {
  final String screeningId;
  final double weight;
  final double height;
  final double bmi;
  final double waistCm;
  final double sbp;
  final double dbp;
  final double pulse;
  final double bloodSugar;
  final String gender;
  final bool hasDirectFamilyNcd;
  final bool hasPersonalNcd;
  final String? personalNcdDetail;

  const ScreeningCalculateRiskRequested({
    required this.screeningId,
    required this.weight,
    required this.height,
    required this.bmi,
    required this.waistCm,
    required this.sbp,
    required this.dbp,
    required this.pulse,
    required this.bloodSugar,
    required this.gender,
    this.hasDirectFamilyNcd = false,
    this.hasPersonalNcd = false,
    this.personalNcdDetail,
  });

  @override
  List<Object?> get props => [
        screeningId,
        weight,
        height,
        bmi,
        waistCm,
        sbp,
        dbp,
        pulse,
        bloodSugar,
        gender,
        hasDirectFamilyNcd,
        hasPersonalNcd,
        personalNcdDetail,
      ];
}

class ScreeningSaveRequested extends ScreeningEvent {
  final Screening screening;
  const ScreeningSaveRequested(this.screening);
  @override
  List<Object?> get props => [screening];
}

class ScreeningApproveRequested extends ScreeningEvent {
  final String screeningId;
  final ReviewStatus status;
  final String nurseId;
  final List<ScreeningResult>? updatedResults;

  const ScreeningApproveRequested({
    required this.screeningId,
    required this.status,
    required this.nurseId,
    this.updatedResults,
  });

  @override
  List<Object?> get props => [screeningId, status, nurseId, updatedResults];
}

// STATES
enum ScreeningStatus { initial, loading, success, failure }

class ScreeningState extends Equatable {
  final ScreeningStatus status;
  final List<Screening> historyList;
  final Screening? currentScreening;
  final List<ScreeningResult> evaluatedResults;
  final String? message;
  final String? errorMessage;

  const ScreeningState({
    this.status = ScreeningStatus.initial,
    this.historyList = const [],
    this.currentScreening,
    this.evaluatedResults = const [],
    this.message,
    this.errorMessage,
  });

  ScreeningState copyWith({
    ScreeningStatus? status,
    List<Screening>? historyList,
    Screening? currentScreening,
    List<ScreeningResult>? evaluatedResults,
    String? message,
    String? errorMessage,
  }) {
    return ScreeningState(
      status: status ?? this.status,
      historyList: historyList ?? this.historyList,
      currentScreening: currentScreening ?? this.currentScreening,
      evaluatedResults: evaluatedResults ?? this.evaluatedResults,
      message: message,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        historyList,
        currentScreening,
        evaluatedResults,
        message,
        errorMessage,
      ];
}

// BLOC
class ScreeningBloc extends Bloc<ScreeningEvent, ScreeningState> {
  final NcdRepositoryInterface repository;

  ScreeningBloc(this.repository) : super(const ScreeningState()) {
    on<ScreeningHistoryLoadRequested>((event, emit) async {
      emit(state.copyWith(status: ScreeningStatus.loading, errorMessage: null));
      try {
        final list = await repository.getScreeningsByPatient(event.patientId);
        emit(state.copyWith(
          status: ScreeningStatus.success,
          historyList: list,
        ));
      } catch (e) {
        emit(state.copyWith(
          status: ScreeningStatus.failure,
          errorMessage: 'ไม่พบข้อมูล',
        ));
      }
    });

    on<ScreeningDetailSelected>((event, emit) {
      emit(state.copyWith(
        currentScreening: event.screening,
        evaluatedResults: event.screening.results,
      ));
    });

    on<ScreeningCalculateRiskRequested>((event, emit) {
      final results = NcdRiskCalculator.evaluateRisk(
        screeningId: event.screeningId,
        weight: event.weight,
        height: event.height,
        bmi: event.bmi,
        waistCm: event.waistCm,
        sbp: event.sbp,
        dbp: event.dbp,
        pulse: event.pulse,
        bloodSugar: event.bloodSugar,
        gender: event.gender,
        hasDirectFamilyNcd: event.hasDirectFamilyNcd,
        hasPersonalNcd: event.hasPersonalNcd,
        personalNcdDetail: event.personalNcdDetail,
      );
      emit(state.copyWith(evaluatedResults: results));
    });

    on<ScreeningSaveRequested>((event, emit) async {
      emit(state.copyWith(status: ScreeningStatus.loading));
      try {
        final saved = await repository.saveScreening(event.screening);
        emit(state.copyWith(
          status: ScreeningStatus.success,
          currentScreening: saved,
          historyList: [saved, ...state.historyList],
          message: 'บันทึกการคัดกรองสำเร็จ',
        ));
      } catch (e) {
        emit(state.copyWith(
          status: ScreeningStatus.failure,
          errorMessage: 'บันทึกการแบบฟอร์มคัดกรองโรคไม่สำเร็จ',
        ));
      }
    });

    on<ScreeningApproveRequested>((event, emit) async {
      emit(state.copyWith(status: ScreeningStatus.loading));
      try {
        final updated = await repository.updateScreeningReview(
          screeningId: event.screeningId,
          status: event.status,
          nurseId: event.nurseId,
          updatedResults: event.updatedResults,
        );
        final updatedHistory = state.historyList
            .map((s) => s.screenId == updated.screenId ? updated : s)
            .toList();
        emit(state.copyWith(
          status: ScreeningStatus.success,
          currentScreening: updated,
          historyList: updatedHistory,
          evaluatedResults: updated.results,
          message: 'อนุมัติผลการประเมินความเสี่ยงสำเร็จ',
        ));
      } catch (e) {
        emit(state.copyWith(
          status: ScreeningStatus.failure,
          errorMessage: 'บันทึกผลประเมิน ไม่สำเร็จ',
        ));
      }
    });
  }
}
