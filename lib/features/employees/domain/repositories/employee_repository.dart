import 'package:employee_book/core/domain/result/result.dart';
import 'package:employee_book/features/employees/domain/entities/employee_input.dart';

abstract interface class EmployeeRepository {
  Future<Result<void>> addEmployee(EmployeeInput input);
}
