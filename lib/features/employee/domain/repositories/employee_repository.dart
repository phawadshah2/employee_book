import 'package:employee_book/features/employee/domain/entities/employee_input.dart';

abstract interface class EmployeeRepository {
  Future<void> addEmployee(EmployeeInput input);
}
