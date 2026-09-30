import 'package:employee_book/core/domain/error/failure.dart';
import 'package:employee_book/core/domain/result/result.dart';
import 'package:employee_book/features/employees/domain/entities/employee.dart';
import 'package:employee_book/features/employees/domain/entities/employee_input.dart';
import 'package:employee_book/features/employees/domain/entities/employee_page.dart';
import 'package:employee_book/features/employees/domain/entities/employee_page_request.dart';
import 'package:employee_book/features/employees/domain/repositories/employee_repository.dart';

class StubEmployeeRepository implements EmployeeRepository {
  Result<void> addResult = const Success<void>(null);
  int addCallCount = 0;
  EmployeeInput? lastAddedInput;

  @override
  Future<Result<void>> addEmployee(EmployeeInput input) async {
    addCallCount++;
    lastAddedInput = input;
    return addResult;
  }

  Result<Employee> getEmployeeResult = const FailureResult<Employee>(
    EmployeeNotFoundFailure(),
  );
  int getEmployeeCallCount = 0;
  int? lastRequestedEmployeeId;

  @override
  Future<Result<Employee>> getEmployee(int id) async {
    getEmployeeCallCount++;
    lastRequestedEmployeeId = id;
    return getEmployeeResult;
  }

  Result<void> deleteEmployeeResult = const Success<void>(null);
  int deleteEmployeeCount = 0;
  int? lastDeletedEmployeeId;

  @override
  Future<Result<void>> deleteEmployee(int id) async {
    deleteEmployeeCount++;
    lastDeletedEmployeeId = id;
    return deleteEmployeeResult;
  }

  @override
  Future<Result<EmployeePage>> getEmployees(EmployeePageRequest request) {
    // TODO(getEmployees): implement getEmployees
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> updateEmployee({
    required int id,
    required EmployeeInput input,
  }) {
    // TODO(updateEmployee): implement updateEmployee
    throw UnimplementedError();
  }
}
