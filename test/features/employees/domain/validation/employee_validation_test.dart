import 'package:employee_book/features/employees/domain/entities/employee_input.dart';
import 'package:employee_book/features/employees/domain/validation/employee_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EmployeeValidation', () {
    group('username', () {
      test('returns required for empty input', () {
        const input = '';
        final result = EmployeeValidation.username(input);
        expect(result, EmployeeValidationError.required);
      });

      test('returns required for whitespace-only input', () {
        const input = '   ';
        final result = EmployeeValidation.username(input);
        expect(result, EmployeeValidationError.required);
      });

      test('rejects fewer than three characters', () {
        const input = 'ab';
        final result = EmployeeValidation.username(input);
        expect(result, EmployeeValidationError.usernameLength);
      });

      test('rejects more than thirty characters', () {
        final input = List.filled(31, 'a').join();
        final result = EmployeeValidation.username(input);
        expect(result, EmployeeValidationError.usernameLength);
      });

      test('rejects unsupported characters', () {
        const input = 'alex@123';
        final result = EmployeeValidation.username(input);
        expect(result, EmployeeValidationError.usernameCharacters);
      });

      test('rejects internal whitespace', () {
        const input = 'alex smith';
        final result = EmployeeValidation.username(input);
        expect(result, EmployeeValidationError.usernameCharacters);
      });
      test('ignores surrounding whitespace', () {
        const input = '  Alex_123  ';
        final result = EmployeeValidation.username(input);
        expect(result, isNull);
      });
      test('accepts letters, numbers, and underscores', () {
        const input = 'Alex_123';
        final result = EmployeeValidation.username(input);
        expect(result, isNull);
      });

      test('accepts exactly three characters', () {
        const input = 'abc';
        final result = EmployeeValidation.username(input);
        expect(result, isNull);
      });

      test('accepts exactly thirty characters', () {
        final input = List.filled(30, 'a').join();
        final result = EmployeeValidation.username(input);
        expect(result, isNull);
      });
    });

    group('firstName', () {
      test('returns required for empty input', () {
        const input = '';
        final result = EmployeeValidation.firstName(input);
        expect(result, EmployeeValidationError.required);
      });

      test('returns required for whitespace-only input', () {
        const input = '   ';
        final result = EmployeeValidation.firstName(input);
        expect(result, EmployeeValidationError.required);
      });

      test('rejects more than 100 characters', () {
        final input = List.filled(102, 'a').join();
        final result = EmployeeValidation.firstName(input);
        expect(result, EmployeeValidationError.nameTooLong);
      });

      test('ignores surrounding whitespace', () {
        const input = '  Alex john  ';
        final result = EmployeeValidation.firstName(input);
        expect(result, isNull);
      });

      test('accepts internal whitespace', () {
        const input = 'alex smith';
        final result = EmployeeValidation.firstName(input);
        expect(result, isNull);
      });

      test('accepts exactly 100 characters', () {
        final input = '  ${List.filled(100, 'a').join()}  ';
        final result = EmployeeValidation.firstName(input);
        expect(result, isNull);
      });
    });

    group('lastName', () {
      test('returns required for empty input', () {
        const input = '';
        final result = EmployeeValidation.lastName(input);
        expect(result, EmployeeValidationError.required);
      });

      test('returns required for whitespace-only input', () {
        const input = '   ';
        final result = EmployeeValidation.lastName(input);
        expect(result, EmployeeValidationError.required);
      });

      test('rejects more than 100 characters', () {
        final input = List.filled(102, 'a').join();
        final result = EmployeeValidation.lastName(input);
        expect(result, EmployeeValidationError.nameTooLong);
      });

      test('ignores surrounding whitespace', () {
        const input = '  Alex john  ';
        final result = EmployeeValidation.lastName(input);
        expect(result, isNull);
      });

      test('accepts internal whitespace', () {
        const input = 'alex smith';
        final result = EmployeeValidation.lastName(input);
        expect(result, isNull);
      });

      test('accepts exactly 100 characters', () {
        final input = '  ${List.filled(100, 'a').join()}  ';
        final result = EmployeeValidation.lastName(input);
        expect(result, isNull);
      });
    });

    group('email', () {
      test('returns required for empty input', () {
        const input = '';
        final result = EmployeeValidation.email(input);
        expect(result, EmployeeValidationError.required);
      });
      test('returns required for whitespace-only input', () {
        const input = '   ';
        final result = EmployeeValidation.email(input);
        expect(result, EmployeeValidationError.required);
      });
      test('rejects a missing local part', () {
        const input = '@example.com';
        final result = EmployeeValidation.email(input);
        expect(result, EmployeeValidationError.invalidEmail);
      });
      test('rejects missing (@)', () {
        const input = 'abcexample.com';
        final result = EmployeeValidation.email(input);
        expect(result, EmployeeValidationError.invalidEmail);
      });
      test('rejects a missing domain', () {
        const input = 'abc@';
        final result = EmployeeValidation.email(input);
        expect(result, EmployeeValidationError.invalidEmail);
      });
      test('rejects a missing domain name before the dot', () {
        const input = 'abc@.com';
        final result = EmployeeValidation.email(input);
        expect(result, EmployeeValidationError.invalidEmail);
      });
      test('rejects a domain without a dot', () {
        const input = 'abc@example';
        final result = EmployeeValidation.email(input);
        expect(result, EmployeeValidationError.invalidEmail);
      });

      test('rejects multiple (@)', () {
        const input = 'abc@@example.com';
        final result = EmployeeValidation.email(input);
        expect(result, EmployeeValidationError.invalidEmail);
      });
      test('rejects internal whitespace', () {
        const input = 'alex@ smith.com';
        final result = EmployeeValidation.email(input);
        expect(result, EmployeeValidationError.invalidEmail);
      });
      test('ignores surrounding whitespace', () {
        const input = '  Alex@john.com  ';
        final result = EmployeeValidation.email(input);
        expect(result, isNull);
      });
      test('accepts a valid email', () {
        const input = 'abc@example.com';
        final result = EmployeeValidation.email(input);
        expect(result, isNull);
      });
    });

    group('validate', () {
      test('returns required errors for all empty fields', () {
        const input = EmployeeInput();
        final result = EmployeeValidation.validate(input);
        expect(result, {
          EmployeeField.username: EmployeeValidationError.required,
          EmployeeField.firstName: EmployeeValidationError.required,
          EmployeeField.lastName: EmployeeValidationError.required,
          EmployeeField.email: EmployeeValidationError.required,
        });
      });

      test('returns only the error for the invalid field', () {
        const input = EmployeeInput(
          username: 'Alex_123',
          firstName: 'Alex',
          lastName: 'Smith',
          email: 'invalid',
        );

        final result = EmployeeValidation.validate(input);

        expect(result, {
          EmployeeField.email: EmployeeValidationError.invalidEmail,
        });
      });

      test('maps different errors to their corresponding fields', () {
        final input = EmployeeInput(
          username: 'ab',
          firstName: List.filled(101, 'a').join(),
          lastName: '',
          email: 'invalid',
        );
        final result = EmployeeValidation.validate(input);
        expect(result, {
          EmployeeField.username: EmployeeValidationError.usernameLength,
          EmployeeField.firstName: EmployeeValidationError.nameTooLong,
          EmployeeField.lastName: EmployeeValidationError.required,
          EmployeeField.email: EmployeeValidationError.invalidEmail,
        });
      });

      test('returns no error when all fields are valid', () {
        const input = EmployeeInput(
          username: 'alex',
          firstName: 'alex',
          lastName: 'patel',
          email: 'alex@example.com',
        );
        final result = EmployeeValidation.validate(input);
        expect(result, isEmpty);
      });
    });
  });
}
