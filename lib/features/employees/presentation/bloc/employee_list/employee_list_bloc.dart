import 'package:employee_book/core/domain/result/result.dart';
import 'package:employee_book/features/employees/domain/entities/employee.dart';
import 'package:employee_book/features/employees/domain/entities/employee_page.dart';
import 'package:employee_book/features/employees/domain/entities/employee_page_request.dart';
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
    on<EmployeeListEvent>(
      _onEvent,
      transformer: (events, mapper) => events.asyncExpand(mapper),
    );
  }

  static const _pageSize = 20;
  final EmployeeList _employeeList;
  final DeleteEmployee _deleteEmployee;

  Future<void> _onEvent(
    EmployeeListEvent event,
    Emitter<EmployeeListState> emit,
  ) async {
    switch (event) {
      case EmployeeListRequested():
        await _onRequested(emit);

      case EmployeeListNextPageRequested():
        await _onNextPageRequested(emit);

      case EmployeeDeleteRequested():
        await _onDeleteRequested(event, emit);
    }
  }

  Future<void> _onRequested(Emitter<EmployeeListState> emit) async {
    emit(const EmployeeListState(status: EmployeeListStatus.loading));
    try {
      final result = await _employeeList(
        const EmployeePageRequest(limit: _pageSize),
      );
      switch (result) {
        case Success<EmployeePage>():
          final page = result.value;
          emit(
            EmployeeListState(
              status: EmployeeListStatus.success,
              employees: page.employees,
              nextCursor: page.nextCursor,
            ),
          );
        case FailureResult<EmployeePage>():
          emit(const EmployeeListState(status: EmployeeListStatus.failure));
      }
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(const EmployeeListState(status: EmployeeListStatus.failure));
    }
  }

  Future<void> _onNextPageRequested(Emitter<EmployeeListState> emit) async {
    if (state.status != EmployeeListStatus.success || !state.hasMore) {
      return;
    }
    if (state.isLoadingMore) return;
    final employees = state.employees;
    final cursor = state.nextCursor;
    emit(
      EmployeeListState(
        status: EmployeeListStatus.success,
        employees: employees,
        nextCursor: cursor,
        isLoadingMore: true,
      ),
    );
    try {
      final result = await _employeeList(
        EmployeePageRequest(limit: _pageSize, afterId: cursor),
      );
      switch (result) {
        case Success<EmployeePage>():
          final page = result.value;
          emit(
            EmployeeListState(
              status: EmployeeListStatus.success,
              employees: List<Employee>.unmodifiable([
                ...employees,
                ...page.employees,
              ]),
              nextCursor: page.nextCursor,
            ),
          );
        case FailureResult<EmployeePage>():
          emit(
            EmployeeListState(
              status: EmployeeListStatus.success,
              employees: employees,
              nextCursor: cursor,
              loadMoreError: 'Could not load more employees. Please try again.',
            ),
          );
      }
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        EmployeeListState(
          status: EmployeeListStatus.success,
          employees: employees,
          nextCursor: cursor,
          loadMoreError: 'Could not load more employees. Please try again.',
        ),
      );
    }
  }

  Future<void> _onDeleteRequested(
    EmployeeDeleteRequested event,
    Emitter<EmployeeListState> emit,
  ) async {
    if (state.status != EmployeeListStatus.success) return;
    final employees = state.employees;
    final cursor = state.nextCursor;
    final loadMoreError = state.loadMoreError;
    if (!employees.any((employee) => employee.id == event.id)) {
      return;
    }
    emit(
      EmployeeListState(
        status: EmployeeListStatus.success,
        employees: employees,
        nextCursor: cursor,
        loadMoreError: loadMoreError,
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
              nextCursor: cursor,
              loadMoreError: loadMoreError,
            ),
          );
        case FailureResult<void>():
          emit(
            EmployeeListState(
              status: EmployeeListStatus.success,
              employees: employees,
              nextCursor: cursor,
              loadMoreError: loadMoreError,
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
          nextCursor: cursor,
          loadMoreError: loadMoreError,
          deleteError: 'Could not delete employee. Please try again.',
        ),
      );
    }
  }
}
