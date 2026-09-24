import 'package:employee_book/features/employee/domain/validation/employee_validation.dart';

extension EmployeeValidationMessages on EmployeeValidationError {
  String get message => switch (this) {
    EmployeeValidationError.required => 'This field is required.',
    EmployeeValidationError.usernameLength =>
      'Use between 3 and 30 characters.',
    EmployeeValidationError.usernameCharacters =>
      'Use letters, numbers, and underscores only.',
    EmployeeValidationError.nameTooLong => 'Use no more than 100 characters.',
    EmployeeValidationError.invalidEmail => 'Enter a valid email address.',
  };
}
