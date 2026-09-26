import 'package:employee_book/features/employees/domain/entities/employee_input.dart';
import 'package:employee_book/features/employees/domain/validation/employee_validation.dart';

enum AddEmployeeStatus { editing, submitting, success, failure }

class AddEmployeeState {
  const AddEmployeeState({
    this.input = const EmployeeInput(),
    this.status = AddEmployeeStatus.editing,
    this.showValidationErrors = false,
    this.formRevision = 0,
  });

  final EmployeeInput input;
  final AddEmployeeStatus status;
  final bool showValidationErrors;
  final int formRevision;

  bool get isSubmitting => status == AddEmployeeStatus.submitting;

  bool get isLocked => isSubmitting || status == AddEmployeeStatus.success;

  Map<EmployeeField, EmployeeValidationError> get errors {
    if (!showValidationErrors) return const {};
    return EmployeeValidation.validate(input);
  }

  AddEmployeeState copyWith({
    EmployeeInput? input,
    AddEmployeeStatus? status,
    bool? showValidationErrors,
    int? formRevision,
  }) {
    return AddEmployeeState(
      input: input ?? this.input,
      status: status ?? this.status,
      showValidationErrors: showValidationErrors ?? this.showValidationErrors,
      formRevision: formRevision ?? this.formRevision,
    );
  }
}
