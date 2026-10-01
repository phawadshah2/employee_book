import 'package:employee_book/core/domain/error/failure.dart';
import 'package:employee_book/core/domain/result/result.dart';
import 'package:employee_book/features/employees/domain/entities/employee.dart';
import 'package:employee_book/features/employees/domain/entities/employee_page.dart';
import 'package:employee_book/features/employees/domain/entities/employee_page_request.dart';
import 'package:employee_book/features/employees/domain/usecases/employee_list.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../helpers/stub_employee_repository.dart';

void main() {
  group('EmployeeList', () {
    late StubEmployeeRepository repository;
    late EmployeeList useCase;

    setUp(() {
      repository = StubEmployeeRepository();
      useCase = EmployeeList(repository);
    });

    for (final limit in [0, -1]) {
      test('rejects limit $limit without calling the repository', () async {
        final result = await useCase(EmployeePageRequest(limit: limit));
        expect(
          result,
          isA<FailureResult<EmployeePage>>().having(
            (result) => result.failure,
            'failure',
            isA<ValidationFailure>(),
          ),
        );
        expect(repository.getEmployeesCallCount, 0);
        expect(repository.lastPageRequest, isNull);
      });
    }

    for (final cursor in [0, -1]) {
      test('rejects cursor $cursor without calling the repository', () async {
        final result = await useCase(EmployeePageRequest(afterId: cursor));
        expect(
          result,
          isA<FailureResult<EmployeePage>>().having(
            (result) => result.failure,
            'failure',
            isA<ValidationFailure>(),
          ),
        );
        expect(repository.getEmployeesCallCount, 0);
        expect(repository.lastPageRequest, isNull);
      });
    }

    test('accepts a first-page request with a null cursor', () async {
      const employee = Employee(
        id: 7,
        username: 'Alex_123',
        firstName: 'Alex',
        lastName: 'Smith',
        email: 'alex@example.com',
      );
      const request = EmployeePageRequest(limit: 1);

      final success = Success<EmployeePage>(
        EmployeePage(employees: const [employee], nextCursor: employee.id),
      );
      repository.getEmployeesResult = success;

      final result = await useCase(request);

      expect(result, same(success));
      expect(repository.getEmployeesCallCount, 1);
      expect(repository.lastPageRequest?.limit, 1);
      expect(repository.lastPageRequest?.afterId, isNull);
    });

    test('forwards the limit and cursor for a subsequent page', () async {
      const request = EmployeePageRequest(limit: 10, afterId: 11);
      final success = Success<EmployeePage>(
        EmployeePage(employees: [], nextCursor: null),
      );
      repository.getEmployeesResult = success;
      final result = await useCase(request);
      expect(result, same(success));
      expect(repository.getEmployeesCallCount, 1);
      expect(repository.lastPageRequest?.limit, 10);
      expect(repository.lastPageRequest?.afterId, 11);
    });

    test('returns an empty page as a successful result', () async {
      const request = EmployeePageRequest();
      final success = Success<EmployeePage>(
        EmployeePage(employees: const [], nextCursor: null),
      );
      repository.getEmployeesResult = success;

      final result = await useCase(request);

      expect(result, same(success));
      expect(repository.getEmployeesCallCount, 1);
      expect(repository.lastPageRequest?.limit, request.limit);
      expect(repository.lastPageRequest?.afterId, isNull);
    });

    test('forwards the repository storage failure', () async {
      const request = EmployeePageRequest(limit: 10, afterId: 7);
      const failure = FailureResult<EmployeePage>(StorageFailure());
      repository.getEmployeesResult = failure;

      final result = await useCase(request);

      expect(result, same(failure));
      expect(repository.getEmployeesCallCount, 1);
      expect(repository.lastPageRequest?.limit, 10);
      expect(repository.lastPageRequest?.afterId, 7);
    });
  });
}
