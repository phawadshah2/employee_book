import 'package:employee_book/core/domain/error/failure.dart';
import 'package:employee_book/core/domain/result/result.dart';
import 'package:employee_book/core/domain/usecase/usecase.dart';
import 'package:employee_book/features/employees/domain/entities/employee.dart';
import 'package:employee_book/features/employees/domain/repositories/employee_repository.dart';

class GetEmployee implements UseCase<Employee, int> {
  const GetEmployee(this._repository);
  final EmployeeRepository _repository;
  @override
  Future<Result<Employee>> call(int id) async {
    if (id <= 0) {
      return const FailureResult<Employee>(ValidationFailure());
    }
    return await _repository.getEmployee(id);
  }
}
