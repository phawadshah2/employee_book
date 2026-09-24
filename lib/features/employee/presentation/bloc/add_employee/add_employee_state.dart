import 'package:employee_book/features/employee/domain/entities/employee_input.dart';
import 'package:employee_book/features/employee/domain/validation/employee_validation.dart';

enum AddEmployeeStatus { editing, submitting, success, failure }

class AddEmployeeState {
  const AddEmployeeState({
    this.input = const EmployeeInput(),
    this.status = AddEmployeeStatus.editing,
    this.showValidationErrors = false,
  });

  final EmployeeInput input;
  final AddEmployeeStatus status;
  final bool showValidationErrors;

  bool get isSubmitting => status == AddEmployeeStatus.submitting;
  bool get isLocked => isSubmitting || status == AddEmployeeStatus.success;

  /// Always computed from current input — never stale.
  Map<EmployeeField, EmployeeValidationError> get errors =>
      EmployeeValidation.validate(input);

  /// What the UI should actually display — empty until the user has
  /// attempted a submit, even if errors technically exist.
  Map<EmployeeField, EmployeeValidationError> get visibleErrors =>
      showValidationErrors ? errors : const {};

  AddEmployeeState copyWith({
    EmployeeInput? input,
    AddEmployeeStatus? status,
    bool? showValidationErrors,
  }) {
    return AddEmployeeState(
      input: input ?? this.input,
      status: status ?? this.status,
      showValidationErrors: showValidationErrors ?? this.showValidationErrors,
    );
  }
}
