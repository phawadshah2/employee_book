import 'dart:developer';

import 'package:employee_book/core/domain/result/result.dart';
import 'package:employee_book/core/domain/usecase/usecase.dart';
import 'package:employee_book/features/employees/domain/entities/employee.dart';
import 'package:employee_book/features/employees/domain/usecases/employee_list.dart';
import 'package:employee_book/features/employees/presentation/bloc/employee_list/employee_list_event.dart';
import 'package:employee_book/features/employees/presentation/bloc/employee_list/employee_list_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmployeeListBloc extends Bloc<EmployeeListEvent, EmployeeListState> {
  EmployeeListBloc(this._employeeList) : super(const EmployeeListState()) {
    on<EmployeeListRequested>(_onRequested);
  }
  final EmployeeList _employeeList;

  Future<void> _onRequested(
    EmployeeListRequested event,
    Emitter<EmployeeListState> emit,
  ) async {
    log('get Employees');
    if (state.isLoading) return;
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
}
