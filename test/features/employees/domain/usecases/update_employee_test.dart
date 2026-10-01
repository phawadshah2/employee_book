import 'package:employee_book/core/domain/error/failure.dart';
import 'package:employee_book/core/domain/result/result.dart';
import 'package:employee_book/features/employees/domain/entities/employee_input.dart';
import 'package:employee_book/features/employees/domain/entities/update_employee_params.dart';
import 'package:employee_book/features/employees/domain/usecases/update_employee.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../helpers/stub_employee_repository.dart';

void main() {
  group('UpdateEmployee', () {
    late StubEmployeeRepository repository;
    late UpdateEmployee useCase;

    setUp(() {
      repository = StubEmployeeRepository();
      useCase = UpdateEmployee(repository);
    });

    const validInput = EmployeeInput(
      username: 'Alex_123',
      firstName: 'Alex',
      lastName: 'Smith',
      email: 'alex@example.com',
    );

    final invalidInputs = <String, EmployeeInput>{
      'username': validInput.copyWith(username: 'ab'),
      'first name': validInput.copyWith(firstName: ''),
      'last name': validInput.copyWith(lastName: ''),
      'email': validInput.copyWith(email: 'invalid'),
    };

    test('forwards the ID and valid fields to the repository', () async {
      const success = Success<void>(null);
      repository.updateEmployeeResult = success;
      final result = await useCase(
        const UpdateEmployeeParams(id: 7, input: validInput),
      );
      expect(result, same(success));
      expect(repository.updateEmployeeCount, 1);
      expect(repository.lastUpdatedEmployeeId, 7);
      final savedInput = repository.lastUpdatedEmployeeInput;
      expect(savedInput, isNotNull);
      expect(savedInput!.username, validInput.username);
      expect(savedInput.firstName, validInput.firstName);
      expect(savedInput.lastName, validInput.lastName);
      expect(savedInput.email, validInput.email);
    });

    for (final id in [0, -1]) {
      test('rejects ID $id without calling the repository', () async {
        final result = await useCase(
          UpdateEmployeeParams(id: id, input: validInput),
        );
        expect(
          result,
          isA<FailureResult<void>>().having(
            (result) => result.failure,
            'failure',
            isA<ValidationFailure>(),
          ),
        );
        expect(repository.updateEmployeeCount, 0);
        expect(repository.lastUpdatedEmployeeId, isNull);
        expect(repository.lastUpdatedEmployeeInput, isNull);
      });
    }

    test('trims all fields before updating the employee', () async {
      const input = EmployeeInput(
        username: '  Alex_123  ',
        firstName: '  Alex  ',
        lastName: '  Smith  ',
        email: '  alex@example.com  ',
      );
      final result = await useCase(
        const UpdateEmployeeParams(id: 7, input: input),
      );
      expect(result, isA<Success<void>>());
      expect(repository.updateEmployeeCount, 1);
      expect(repository.lastUpdatedEmployeeId, 7);
      final savedInput = repository.lastUpdatedEmployeeInput;
      expect(savedInput, isNotNull);
      expect(savedInput!.username, 'Alex_123');
      expect(savedInput.firstName, 'Alex');
      expect(savedInput.lastName, 'Smith');
      expect(savedInput.email, 'alex@example.com');
    });

    for (final entry in invalidInputs.entries) {
      test(
        'rejects invalid ${entry.key} without calling the repository',
        () async {
          final input = UpdateEmployeeParams(id: 5, input: entry.value);
          final result = await useCase(input);
          expect(
            result,
            isA<FailureResult<void>>().having(
              (result) => result.failure,
              'failure',
              isA<ValidationFailure>(),
            ),
          );
          expect(repository.updateEmployeeCount, 0);
          expect(repository.lastUpdatedEmployeeInput, isNull);
        },
      );
    }

    test('forwards the employee-not-found failure', () async {
      const failure = FailureResult<void>(EmployeeNotFoundFailure());
      repository.updateEmployeeResult = failure;
      const input = UpdateEmployeeParams(id: 7, input: validInput);
      final result = await useCase(input);
      expect(result, same(failure));
      expect(repository.updateEmployeeCount, 1);
      expect(repository.lastUpdatedEmployeeId, 7);
    });

    test('forwards the repository storage failure', () async {
      const failure = FailureResult<void>(StorageFailure());
      repository.updateEmployeeResult = failure;
      const input = UpdateEmployeeParams(id: 7, input: validInput);
      final result = await useCase(input);
      expect(result, same(failure));
      expect(repository.updateEmployeeCount, 1);
      expect(repository.lastUpdatedEmployeeId, 7);
    });
  });
}
