import 'package:employee_book/features/employees/domain/entities/employee.dart';

class EmployeePage {
  EmployeePage({required List<Employee> employees, required this.nextCursor})
    : employees = List<Employee>.unmodifiable(employees);

  final List<Employee> employees;
  final int? nextCursor;

  bool get hasMore => nextCursor != null;
}
