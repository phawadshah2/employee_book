import 'dart:developer';

import 'package:employee_book/core/domain/result/result.dart';
import 'package:employee_book/core/domain/usecase/usecase.dart';
import 'package:employee_book/features/employees/domain/entities/employee.dart';
import 'package:employee_book/features/employees/domain/usecases/delete_employee.dart';
import 'package:employee_book/features/employees/domain/usecases/employee_list.dart';
import 'package:employee_book/features/employees/presentation/bloc/employee_list/employee_list_event.dart';
import 'package:employee_book/features/employees/presentation/bloc/employee_list/employee_list_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmployeeListBloc extends Bloc<EmployeeListEvent, EmployeeListState> {
  EmployeeListBloc({
    required EmployeeList employeeList,
    required DeleteEmployee deleteEmployee,
  }) : _employeeList = employeeList,
       _deleteEmployee = deleteEmployee,
       super(const EmployeeListState()) {
    on<EmployeeListRequested>(_onRequested);
    on<EmployeeDeleteRequested>(_onDeleteRequested);
  }
  final EmployeeList _employeeList;
  final DeleteEmployee _deleteEmployee;

  Future<void> _onRequested(
    EmployeeListRequested event,
    Emitter<EmployeeListState> emit,
  ) async {
    log('get Employees');
    if (state.isLoading || state.isDeleting) return;
    emit(const EmployeeListState(status: EmployeeListStatus.loading));
    try {
      final result = await _employeeList(const NoParams());
      switch (result) {
        case Success<List<Employee>>():
          emit(
            EmployeeListState(
              employees: List<Employee>.unmodifiable(result.value),
              status: EmployeeListStatus.success,
            ),
          );
        case FailureResult<List<Employee>>():
          emit(const EmployeeListState(status: EmployeeListStatus.failure));
      }
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(const EmployeeListState(status: EmployeeListStatus.failure));
    }
  }

  Future<void> _onDeleteRequested(
    EmployeeDeleteRequested event,
    Emitter<EmployeeListState> emit,
  ) async {
    if (state.status != EmployeeListStatus.success || state.isDeleting) {
      return;
    }
    final employees = state.employees;
    if (!employees.any((employee) => employee.id == event.id)) {
      return;
    }
    emit(
      EmployeeListState(
        status: EmployeeListStatus.success,
        employees: employees,
        deletingEmployeeId: event.id,
      ),
    );
    try {
      final result = await _deleteEmployee(event.id);
      switch (result) {
        case Success<void>():
          emit(
            EmployeeListState(
              status: EmployeeListStatus.success,
              employees: List<Employee>.unmodifiable(
                employees.where((employee) => employee.id != event.id),
              ),
            ),
          );
        case FailureResult<void>():
          emit(
            EmployeeListState(
              status: EmployeeListStatus.success,
              employees: employees,
              deleteError: 'Could not delete employee. Please try again.',
            ),
          );
      }
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        EmployeeListState(
          status: EmployeeListStatus.success,
          employees: employees,
          deleteError: 'Could not delete employee. Please try again.',
        ),
      );
    }
  }
}
