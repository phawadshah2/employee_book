import 'package:employee_book/core/domain/error/failure.dart';
import 'package:employee_book/core/domain/result/result.dart';
import 'package:employee_book/core/domain/usecase/usecase.dart';
import 'package:employee_book/features/employees/domain/entities/update_employee_params.dart';
import 'package:employee_book/features/employees/domain/repositories/employee_repository.dart';
import 'package:employee_book/features/employees/domain/validation/employee_validation.dart';

class UpdateEmployee implements UseCase<void, UpdateEmployeeParams> {
  const UpdateEmployee(this._repository);
  final EmployeeRepository _repository;
  @override
  Future<Result<void>> call(UpdateEmployeeParams params) async {
    if (params.id <= 0) {
      return const FailureResult<void>(ValidationFailure());
    }
    final normalized = params.input.normalized();
    final errors = EmployeeValidation.validate(normalized);
    if (errors.isNotEmpty) {
      return const FailureResult<void>(ValidationFailure());
    }
    return await _repository.updateEmployee(id: params.id, input: normalized);
  }
}
