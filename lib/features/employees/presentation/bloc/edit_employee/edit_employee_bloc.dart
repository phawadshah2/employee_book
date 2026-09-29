import 'dart:developer';

import 'package:employee_book/core/domain/error/failure.dart';
import 'package:employee_book/core/domain/result/result.dart';
import 'package:employee_book/features/employees/domain/entities/employee.dart';
import 'package:employee_book/features/employees/domain/entities/employee_input.dart';
import 'package:employee_book/features/employees/domain/entities/update_employee_params.dart';
import 'package:employee_book/features/employees/domain/usecases/get_employee.dart';
import 'package:employee_book/features/employees/domain/usecases/update_employee.dart';
import 'package:employee_book/features/employees/domain/validation/employee_validation.dart';
import 'package:employee_book/features/employees/presentation/bloc/edit_employee/edit_employee_event.dart';
import 'package:employee_book/features/employees/presentation/bloc/edit_employee/edit_employee_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditEmployeeBloc extends Bloc<EditEmployeeEvent, EditEmployeeState> {
  EditEmployeeBloc({
    required int employeeId,
    required GetEmployee getEmployee,
    required UpdateEmployee updateEmployee,
  }) : _employeeId = employeeId,
       _getEmployee = getEmployee,
       _updateEmployee = updateEmployee,
       super(const EditEmployeeState()) {
    on<EditEmployeeRequested>(_onRequested);
    on<EditEmployeeFieldChanged>(_onFieldChanged);
    on<EditEmployeeSubmitted>(_onSubmitted);
  }

  final int _employeeId;
  final GetEmployee _getEmployee;
  final UpdateEmployee _updateEmployee;

  Future<void> _onRequested(
    EditEmployeeRequested event,
    Emitter<EditEmployeeState> emit,
  ) async {
    if (state.status != EditEmployeeStatus.initial &&
        state.status != EditEmployeeStatus.loadFailure) {
      return;
    }
    log('get Employee $_employeeId');
    emit(const EditEmployeeState(status: EditEmployeeStatus.loading));
    try {
      final result = await _getEmployee(_employeeId);
      switch (result) {
        case Success<Employee>():
          final employee = result.value;
          emit(
            EditEmployeeState(
              status: EditEmployeeStatus.editing,
              input: EmployeeInput(
                username: employee.username,
                firstName: employee.firstName,
                lastName: employee.lastName,
                email: employee.email,
              ),
            ),
          );
        case FailureResult<Employee>():
          final cannotLoad =
              result.failure is EmployeeNotFoundFailure ||
              result.failure is ValidationFailure;

          emit(
            EditEmployeeState(
              status: cannotLoad
                  ? EditEmployeeStatus.notFound
                  : EditEmployeeStatus.loadFailure,
            ),
          );
      }
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(const EditEmployeeState(status: EditEmployeeStatus.loadFailure));
    }
  }

  void _onFieldChanged(
    EditEmployeeFieldChanged event,
    Emitter<EditEmployeeState> emit,
  ) {
    if (!state.canEdit) return;
    final input = switch (event.field) {
      EmployeeField.username => state.input.copyWith(username: event.value),
      EmployeeField.firstName => state.input.copyWith(firstName: event.value),
      EmployeeField.lastName => state.input.copyWith(lastName: event.value),
      EmployeeField.email => state.input.copyWith(email: event.value),
    };
    emit(
      EditEmployeeState(
        status: EditEmployeeStatus.editing,
        input: input,
        showValidationErrors: state.showValidationErrors,
      ),
    );
  }

  Future<void> _onSubmitted(
    EditEmployeeSubmitted event,
    Emitter<EditEmployeeState> emit,
  ) async {
    if (!state.canEdit) return;
    final input = state.input;
    final errors = EmployeeValidation.validate(input);
    if (errors.isNotEmpty) {
      emit(
        EditEmployeeState(
          status: EditEmployeeStatus.editing,
          input: input,
          showValidationErrors: true,
        ),
      );
      return;
    }
    emit(
      EditEmployeeState(
        status: EditEmployeeStatus.submitting,
        input: input,
        showValidationErrors: true,
      ),
    );
    try {
      // The use case normalizes and validates before saving.
      final result = await _updateEmployee(
        UpdateEmployeeParams(id: _employeeId, input: input),
      );
      switch (result) {
        case Success<void>():
          emit(
            EditEmployeeState(
              status: EditEmployeeStatus.success,
              input: input,
              showValidationErrors: true,
            ),
          );
        case FailureResult<void>():
          emit(
            EditEmployeeState(
              status: result.failure is EmployeeNotFoundFailure
                  ? EditEmployeeStatus.notFound
                  : EditEmployeeStatus.saveFailure,
              input: input,
              showValidationErrors: true,
            ),
          );
      }
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        EditEmployeeState(
          status: EditEmployeeStatus.saveFailure,
          input: input,
          showValidationErrors: true,
        ),
      );
    }
  }
}
