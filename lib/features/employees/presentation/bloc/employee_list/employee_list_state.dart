import 'package:employee_book/features/employees/domain/entities/employee.dart';

enum EmployeeListStatus { initial, loading, success, failure }

class EmployeeListState {
  const EmployeeListState({
    this.status = EmployeeListStatus.initial,
    this.employees = const [],
    this.deletingEmployeeId,
    this.deleteError,
  });

  final EmployeeListStatus status;
  final List<Employee> employees;
  final int? deletingEmployeeId;
  final String? deleteError;

  bool get isLoading => status == EmployeeListStatus.loading;
  bool get isDeleting => deletingEmployeeId != null;
}
