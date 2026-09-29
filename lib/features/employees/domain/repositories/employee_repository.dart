import 'package:employee_book/core/domain/result/result.dart';
import 'package:employee_book/features/employees/domain/entities/employee.dart';
import 'package:employee_book/features/employees/domain/entities/employee_input.dart';
import 'package:employee_book/features/employees/domain/entities/employee_page.dart';
import 'package:employee_book/features/employees/domain/entities/employee_page_request.dart';

abstract interface class EmployeeRepository {
  Future<Result<void>> addEmployee(EmployeeInput input);
  Future<Result<EmployeePage>> getEmployees(EmployeePageRequest request);
  Future<Result<void>> deleteEmployee(int id);
  Future<Result<Employee>> getEmployee(int id);
  Future<Result<void>> updateEmployee({
    required int id,
    required EmployeeInput input,
  });
}
