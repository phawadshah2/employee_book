import 'package:employee_book/features/employees/domain/usecases/add_employee.dart';
import 'package:employee_book/features/employees/domain/validation/employee_validation.dart';
import 'package:employee_book/features/employees/presentation/bloc/add_employee/add_employee_event.dart';
import 'package:employee_book/features/employees/presentation/bloc/add_employee/add_employee_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// add_employee_bloc.dart
class AddEmployeeBloc extends Bloc<AddEmployeeEvent, AddEmployeeState> {
  AddEmployeeBloc(this._addEmployee) : super(const AddEmployeeState()) {
    on<EmployeeFieldChanged>(_onFieldChanged);
    on<AddEmployeeSubmitted>(_onSubmitted);
    on<AddEmployeeReset>(_onReset);
  }

  final AddEmployee _addEmployee;

  void _onReset(AddEmployeeReset event, Emitter<AddEmployeeState> emit) {
    if (state.isSubmitting) return;
    emit(AddEmployeeState(formRevision: state.formRevision + 1));
  }

  void _onFieldChanged(
    EmployeeFieldChanged event,
    Emitter<AddEmployeeState> emit,
  ) {
    if (state.isLocked) return;

    final input = switch (event.field) {
      EmployeeField.username => state.input.copyWith(username: event.value),
      EmployeeField.firstName => state.input.copyWith(firstName: event.value),
      EmployeeField.lastName => state.input.copyWith(lastName: event.value),
      EmployeeField.email => state.input.copyWith(email: event.value),
    };

    emit(state.copyWith(input: input, status: AddEmployeeStatus.editing));
  }

  Future<void> _onSubmitted(
    AddEmployeeSubmitted event,
    Emitter<AddEmployeeState> emit,
  ) async {
    if (state.isLocked) return;

    if (state.errors.isNotEmpty) {
      emit(state.copyWith(showValidationErrors: true));
      return;
    }

    final input = state.input;
    emit(
      state.copyWith(
        status: AddEmployeeStatus.submitting,
        showValidationErrors: true,
      ),
    );

    try {
      await _addEmployee(input);
      emit(state.copyWith(status: AddEmployeeStatus.success));
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.copyWith(status: AddEmployeeStatus.failure));
    }
  }
}
