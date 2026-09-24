import 'dart:developer';

import 'package:employee_book/features/employee/domain/entities/employee_input.dart';

enum EmployeeField { username, firstName, lastName, email }

enum EmployeeValidationError {
  required,
  usernameLength,
  usernameCharacters,
  nameTooLong,
  invalidEmail,
}

abstract final class EmployeeValidation {
  static final _usernamePattern = RegExp(r'^[a-zA-Z0-9_]+$');
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static EmployeeValidationError? username(String value) {
    final text = value.trim();
    if (text.isEmpty) return EmployeeValidationError.required;
    if (text.length < 3 || text.length > 30) {
      return EmployeeValidationError.usernameLength;
    }
    if (!_usernamePattern.hasMatch(text)) {
      return EmployeeValidationError.usernameCharacters;
    }
    return null;
  }

  static EmployeeValidationError? firstName(String value) => _name(value);
  static EmployeeValidationError? lastName(String value) => _name(value);

  static EmployeeValidationError? email(String value) {
    final text = value.trim();
    if (text.isEmpty) return EmployeeValidationError.required;
    if (!_emailPattern.hasMatch(text)) {
      return EmployeeValidationError.invalidEmail;
    }
    return null;
  }

  static EmployeeValidationError? _name(String value) {
    final text = value.trim();
    if (text.isEmpty) return EmployeeValidationError.required;
    if (text.runes.length > 100) {
      return EmployeeValidationError.nameTooLong;
    }
    return null;
  }

  static Map<EmployeeField, EmployeeValidationError> validate(
    EmployeeInput input,
  ) {
    final results = <EmployeeField, EmployeeValidationError?>{
      EmployeeField.username: username(input.username),
      EmployeeField.firstName: firstName(input.firstName),
      EmployeeField.lastName: lastName(input.lastName),
      EmployeeField.email: email(input.email),
    };

    return Map.unmodifiable({
      for (final entry in results.entries)
        if (entry.value != null) entry.key: entry.value!,
    });
  }
}
