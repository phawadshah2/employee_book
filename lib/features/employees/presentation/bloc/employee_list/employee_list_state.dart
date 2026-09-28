import 'package:employee_book/features/employees/domain/entities/employee.dart';

enum EmployeeListStatus { initial, loading, success, failure }

class EmployeeListState {
  const EmployeeListState({
    this.status = EmployeeListStatus.initial,
    this.employees = const [],
    this.nextCursor,
    this.isLoadingMore = false,
    this.loadMoreError,
    this.deletingEmployeeId,
    this.deleteError,
  });

  final EmployeeListStatus status;
  final List<Employee> employees;

  final int? nextCursor;
  final bool isLoadingMore;
  final String? loadMoreError;

  final int? deletingEmployeeId;
  final String? deleteError;

  bool get hasMore => nextCursor != null;
  bool get isLoading => status == EmployeeListStatus.loading;
  bool get isDeleting => deletingEmployeeId != null;
}
