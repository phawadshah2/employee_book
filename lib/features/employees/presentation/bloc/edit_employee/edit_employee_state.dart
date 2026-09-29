import 'package:employee_book/features/employees/domain/entities/employee_input.dart';
import 'package:employee_book/features/employees/domain/validation/employee_validation.dart';

enum EditEmployeeStatus {
  initial,
  loading,
  loadFailure,
  notFound,
  editing,
  submitting,
  success,
  saveFailure,
}

class EditEmployeeState {
  const EditEmployeeState({
    this.status = EditEmployeeStatus.initial,
    this.input = const EmployeeInput(),
    this.showValidationErrors = false,
  });

  final EditEmployeeStatus status;
  final EmployeeInput input;
  final bool showValidationErrors;

  bool get isSubmitting => status == EditEmployeeStatus.submitting;

  bool get canEdit =>
      status == EditEmployeeStatus.editing ||
      status == EditEmployeeStatus.saveFailure;

  bool get isLocked => !canEdit;

  Map<EmployeeField, EmployeeValidationError> get errors {
    if (!showValidationErrors) return const {};
    return EmployeeValidation.validate(input);
  }
}
