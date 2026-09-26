import 'package:employee_book/core/domain/error/failure.dart';
import 'package:employee_book/core/domain/result/result.dart';
import 'package:employee_book/core/domain/usecase/usecase.dart';
import 'package:employee_book/features/employees/domain/entities/employee_input.dart';
import 'package:employee_book/features/employees/domain/repositories/employee_repository.dart';
import 'package:employee_book/features/employees/domain/validation/employee_validation.dart';

class AddEmployee implements UseCase<void, EmployeeInput> {
  const AddEmployee(this._repository);
  final EmployeeRepository _repository;

  @override
  Future<Result<void>> call(EmployeeInput input) async {
    final normalized = input.normalized();
    final errors = EmployeeValidation.validate(normalized);

    if (errors.isNotEmpty) {
      return const FailureResult<void>(ValidationFailure());
    }

    return await _repository.addEmployee(normalized);
  }
}
