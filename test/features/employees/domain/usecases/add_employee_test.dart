import 'package:employee_book/core/domain/error/failure.dart';
import 'package:employee_book/core/domain/result/result.dart';
import 'package:employee_book/features/employees/domain/entities/employee_input.dart';
import 'package:employee_book/features/employees/domain/usecases/add_employee.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../helpers/stub_employee_repository.dart';

void main() {
  group('AddEmployee', () {
    late StubEmployeeRepository repository;
    late AddEmployee useCase;

    const validInput = EmployeeInput(
      username: 'Alex_123',
      firstName: 'Alex',
      lastName: 'Smith',
      email: 'alex@example.com',
    );

    setUp(() {
      repository = StubEmployeeRepository();
      useCase = AddEmployee(repository);
    });

    test('rejects invalid input without calling the repository', () async {
      const input = EmployeeInput();
      final result = await useCase(input);
      const expectedResult = FailureResult<void>(ValidationFailure());
      expect(
        result,
        isA<FailureResult<void>>().having(
          (result) => result.failure,
          'failure',
          isA<ValidationFailure>(),
        ),
      );
      expect(result, same(expectedResult));
      expect(repository.addCallCount, 0);
      expect(repository.lastAddedInput, isNull);
    });

    final invalidInputs = <String, EmployeeInput>{
      'username': validInput.copyWith(username: 'ab'),
      'first name': validInput.copyWith(firstName: ''),
      'last name': validInput.copyWith(lastName: ''),
      'email': validInput.copyWith(email: 'invalid'),
    };

    for (final entry in invalidInputs.entries) {
      test(
        'rejects invalid ${entry.key} without calling the repository',
        () async {
          final result = await useCase(entry.value);
          const expectedResult = FailureResult<void>(ValidationFailure());

          expect(result, same(expectedResult));
          expect(repository.addCallCount, 0);
          expect(repository.lastAddedInput, isNull);
        },
      );
    }
    test('accepts valid input and calls the repository once', () async {
      const input = validInput;
      final result = await useCase(input);
      expect(result, isA<Success<void>>());
      expect(repository.addCallCount, 1);

      final savedInput = repository.lastAddedInput;
      expect(savedInput, isNotNull);
      expect(savedInput!.username, input.username);
      expect(savedInput.firstName, input.firstName);
      expect(savedInput.lastName, input.lastName);
      expect(savedInput.email, input.email);
    });

    test('trims all fields before passing them to the repository', () async {
      const input = EmployeeInput(
        username: ' Alex_123 ',
        firstName: '  Alex  ',
        lastName: ' Smith ',
        email: '  alex@example.com  ',
      );
      final result = await useCase(input);
      expect(result, isA<Success<void>>());
      expect(repository.addCallCount, 01);
      final savedInput = repository.lastAddedInput;
      expect(savedInput, isNotNull);
      expect(savedInput!.username, 'Alex_123');
      expect(savedInput.firstName, 'Alex');
      expect(savedInput.lastName, 'Smith');
      expect(savedInput.email, 'alex@example.com');
    });

    test('returns the repository failure', () async {
      const failure = FailureResult<void>(StorageFailure());
      repository.addResult = failure;
      final result = await useCase(validInput);
      expect(result, same(failure));
      expect(repository.addCallCount, 1);
    });
  });
}
