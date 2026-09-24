import 'package:employee_book/features/employee/domain/entities/employee_input.dart';
import 'package:employee_book/features/employee/domain/repositories/employee_repository.dart';
import 'package:employee_book/features/employee/domain/validation/employee_validation.dart';

class InvalidEmployeeInput implements Exception {
  InvalidEmployeeInput(Map<EmployeeField, EmployeeValidationError> errors)
    : errors = Map.unmodifiable(errors);

  final Map<EmployeeField, EmployeeValidationError> errors;
}

class AddEmployee {
  const AddEmployee(this._repository);

  final EmployeeRepository _repository;

  Future<void> call(EmployeeInput input) async {
    final normalized = input.normalized();
    final errors = EmployeeValidation.validate(normalized);

    if (errors.isNotEmpty) {
      throw InvalidEmployeeInput(errors);
    }

    await _repository.addEmployee(normalized);
  }
}
