import 'package:employee_book/core/domain/error/failure.dart';
import 'package:employee_book/core/domain/result/result.dart';
import 'package:employee_book/features/employees/domain/usecases/delete_employee.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/stub_employee_repository.dart';

void main() {
  group('DeleteEmployee', () {
    late StubEmployeeRepository repository;
    late DeleteEmployee useCase;

    setUp(() {
      repository = StubEmployeeRepository();
      useCase = DeleteEmployee(repository);
    });

    test('forwards the ID and returns repository success', () async {
      const success = Success<void>(null);
      repository.deleteEmployeeResult = success;
      final result = await useCase(7);
      expect(result, same(success));
      expect(repository.deleteEmployeeCount, 1);
      expect(repository.lastDeletedEmployeeId, 7);
    });

    test('forwards the employee-not-found failure', () async {
      const failure = FailureResult<void>(EmployeeNotFoundFailure());
      repository.deleteEmployeeResult = failure;
      final result = await useCase(7);
      expect(result, same(failure));
      expect(repository.deleteEmployeeCount, 1);
      expect(repository.lastDeletedEmployeeId, 7);
    });

    test('forwards the repository storage failure', () async {
      const failure = FailureResult<void>(StorageFailure());
      repository.deleteEmployeeResult = failure;
      final result = await useCase(7);
      expect(result, same(failure));
      expect(repository.deleteEmployeeCount, 1);
      expect(repository.lastDeletedEmployeeId, 7);
    });
  });
}
