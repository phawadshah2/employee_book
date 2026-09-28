import 'package:employee_book/core/domain/error/failure.dart';
import 'package:employee_book/core/domain/result/result.dart';
import 'package:employee_book/core/domain/usecase/usecase.dart';
import 'package:employee_book/features/employees/domain/entities/employee_page.dart';
import 'package:employee_book/features/employees/domain/entities/employee_page_request.dart';
import 'package:employee_book/features/employees/domain/repositories/employee_repository.dart';

class EmployeeList implements UseCase<EmployeePage, EmployeePageRequest> {
  const EmployeeList(this._repository);

  final EmployeeRepository _repository;

  @override
  Future<Result<EmployeePage>> call(EmployeePageRequest input) async {
    if (input.limit <= 0 || (input.afterId != null && input.afterId! <= 0)) {
      return const FailureResult<EmployeePage>(ValidationFailure());
    }
    return await _repository.getEmployees(input);
  }
}
