import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccessibilityState extends Equatable {
  final bool isElderlyMode;
  final double textScaleFactor;
  final bool isHighContrast;

  const AccessibilityState({
    this.isElderlyMode = false,
    this.textScaleFactor = 1.0,
    this.isHighContrast = false,
  });

  AccessibilityState copyWith({
    bool? isElderlyMode,
    double? textScaleFactor,
    bool? isHighContrast,
  }) {
    return AccessibilityState(
      isElderlyMode: isElderlyMode ?? this.isElderlyMode,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      isHighContrast: isHighContrast ?? this.isHighContrast,
    );
  }

  @override
  List<Object?> get props => [isElderlyMode, textScaleFactor, isHighContrast];
}

class AccessibilityCubit extends Cubit<AccessibilityState> {
  AccessibilityCubit() : super(const AccessibilityState());

  void toggleElderlyMode() {
    final next = !state.isElderlyMode;
    emit(state.copyWith(
      isElderlyMode: next,
      textScaleFactor: next ? 1.35 : 1.0,
    ));
  }

  void setElderlyMode(bool enabled) {
    emit(state.copyWith(
      isElderlyMode: enabled,
      textScaleFactor: enabled ? 1.35 : 1.0,
    ));
  }

  void toggleHighContrast() {
    emit(state.copyWith(isHighContrast: !state.isHighContrast));
  }
}
