import 'package:employee_book/core/domain/error/failure.dart';
import 'package:employee_book/core/domain/result/result.dart';
import 'package:employee_book/features/employees/domain/entities/employee.dart';
import 'package:employee_book/features/employees/domain/usecases/get_employee.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../helpers/stub_employee_repository.dart';

void main() {
  group('GetEmployee', () {
    late StubEmployeeRepository repository;
    late GetEmployee useCase;

    setUp(() {
      repository = StubEmployeeRepository();
      useCase = GetEmployee(repository);
    });

    test('rejects invalid IDs without calling the repository', () async {
      const input = 0;
      final result = await useCase(input);
      expect(
        result,
        isA<FailureResult<Employee>>().having(
          (result) => result.failure,
          'failure',
          isA<ValidationFailure>(),
        ),
      );
      expect(repository.getEmployeeCallCount, 0);
      expect(repository.lastRequestedEmployeeId, isNull);
    });

    test('returns the employee when the ID exists', () async {
      const employee = Employee(
        id: 7,
        username: 'Alex_123',
        firstName: 'Alex',
        lastName: 'Smith',
        email: 'alex@example.com',
      );
      repository.getEmployeeResult = const Success<Employee>(employee);
      final result = await useCase(employee.id);
      expect(
        result,
        isA<Success<Employee>>().having(
          (result) => result.value,
          'employee',
          same(employee),
        ),
      );
      expect(repository.getEmployeeCallCount, 1);
      expect(repository.lastRequestedEmployeeId, employee.id);
    });

    test('forwards the repository storage failure', () async {
      const failure = FailureResult<Employee>(StorageFailure());
      repository.getEmployeeResult = failure;
      final result = await useCase(4);
      expect(result, same(failure));
      expect(repository.getEmployeeCallCount, 1);
      expect(repository.lastRequestedEmployeeId, 4);
    });

    test('forwards the employee-not-found failure', () async {
      const failure = FailureResult<Employee>(EmployeeNotFoundFailure());
      repository.getEmployeeResult = failure;
      final result = await useCase(4);
      expect(result, same(failure));
      expect(repository.getEmployeeCallCount, 1);
      expect(repository.lastRequestedEmployeeId, 4);
    });
  });
}
