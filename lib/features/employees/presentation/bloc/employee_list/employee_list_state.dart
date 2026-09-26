import 'package:employee_book/features/employees/domain/entities/employee.dart';

enum EmployeeListStatus { initial, loading, success, failure }

class EmployeeListState {
  const EmployeeListState({
    this.status = EmployeeListStatus.initial,
    this.employees = const [],
  });

  final EmployeeListStatus status;
  final List<Employee> employees;

  bool get isLoading => status == EmployeeListStatus.loading;
}
