import 'package:bloc_test/bloc_test.dart';
import 'package:employee_book/core/domain/error/failure.dart';
import 'package:employee_book/core/domain/result/result.dart';
import 'package:employee_book/features/employees/domain/entities/employee.dart';
import 'package:employee_book/features/employees/domain/entities/employee_input.dart';
import 'package:employee_book/features/employees/domain/usecases/get_employee.dart';
import 'package:employee_book/features/employees/domain/usecases/update_employee.dart';
import 'package:employee_book/features/employees/domain/validation/employee_validation.dart';
import 'package:employee_book/features/employees/presentation/bloc/edit_employee/edit_employee_bloc.dart';
import 'package:employee_book/features/employees/presentation/bloc/edit_employee/edit_employee_event.dart';
import 'package:employee_book/features/employees/presentation/bloc/edit_employee/edit_employee_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/stub_employee_repository.dart';

void main() {
  group('EditEmployeeBloc', () {
    late StubEmployeeRepository repository;

    setUp(() {
      repository = StubEmployeeRepository();
    });

    EditEmployeeBloc buildBloc({int employeeId = 7}) => EditEmployeeBloc(
      employeeId: employeeId,
      getEmployee: GetEmployee(repository),
      updateEmployee: UpdateEmployee(repository),
    );

    const employee = Employee(
      id: 7,
      username: 'alex_123',
      firstName: 'Alex',
      lastName: 'Smith',
      email: 'alex@example.com',
    );

    group('EditEmployeeRequested', () {
      blocTest<EditEmployeeBloc, EditEmployeeState>(
        'emits loading then editing with the employee pre-filled',
        build: () {
          repository.getEmployeeResult = const Success<Employee>(employee);
          return buildBloc();
        },
        act: (bloc) => bloc.add(const EditEmployeeRequested()),
        expect: () => [
          isA<EditEmployeeState>().having(
            (s) => s.status,
            'status',
            EditEmployeeStatus.loading,
          ),
          isA<EditEmployeeState>()
              .having((s) => s.status, 'status', EditEmployeeStatus.editing)
              .having((s) => s.input.username, 'username', employee.username)
              .having((s) => s.input.firstName, 'firstName', employee.firstName)
              .having((s) => s.input.lastName, 'lastName', employee.lastName)
              .having((s) => s.input.email, 'email', employee.email),
        ],
        verify: (_) {
          expect(repository.getEmployeeCallCount, 1);
          expect(repository.lastRequestedEmployeeId, employee.id);
        },
      );

      blocTest<EditEmployeeBloc, EditEmployeeState>(
        'emits loading then notFound when the employee does not exist',
        build: () {
          repository.getEmployeeResult = const FailureResult<Employee>(
            EmployeeNotFoundFailure(),
          );
          return buildBloc(employeeId: 5);
        },
        act: (bloc) => bloc.add(const EditEmployeeRequested()),
        expect: () => [
          isA<EditEmployeeState>().having(
            (s) => s.status,
            'status',
            EditEmployeeStatus.loading,
          ),
          isA<EditEmployeeState>().having(
            (s) => s.status,
            'status',
            EditEmployeeStatus.notFound,
          ),
        ],
        verify: (_) {
          expect(repository.getEmployeeCallCount, 1);
          expect(repository.lastRequestedEmployeeId, 5);
        },
      );

      blocTest<EditEmployeeBloc, EditEmployeeState>(
        'emits notFound without hitting the repository when id is invalid',
        build: () => buildBloc(employeeId: 0),
        act: (bloc) => bloc.add(const EditEmployeeRequested()),
        expect: () => [
          isA<EditEmployeeState>().having(
            (s) => s.status,
            'status',
            EditEmployeeStatus.loading,
          ),
          isA<EditEmployeeState>().having(
            (s) => s.status,
            'status',
            EditEmployeeStatus.notFound,
          ),
        ],
        verify: (_) {
          expect(repository.getEmployeeCallCount, 0);
        },
      );

      blocTest<EditEmployeeBloc, EditEmployeeState>(
        'emits loading then loadFailure when storage fails',
        build: () {
          repository.getEmployeeResult = const FailureResult<Employee>(
            StorageFailure(),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(const EditEmployeeRequested()),
        expect: () => [
          isA<EditEmployeeState>().having(
            (s) => s.status,
            'status',
            EditEmployeeStatus.loading,
          ),
          isA<EditEmployeeState>().having(
            (s) => s.status,
            'status',
            EditEmployeeStatus.loadFailure,
          ),
        ],
        verify: (_) {
          expect(repository.getEmployeeCallCount, 1);
          expect(repository.lastRequestedEmployeeId, 7);
        },
      );

      blocTest<EditEmployeeBloc, EditEmployeeState>(
        'does nothing when the employee is already loaded',
        build: buildBloc,
        seed: () => const EditEmployeeState(
          status: EditEmployeeStatus.editing,
          input: EmployeeInput(username: 'typed_by_user'),
        ),
        act: (bloc) => bloc.add(const EditEmployeeRequested()),
        expect: () => <EditEmployeeState>[],
        verify: (_) {
          expect(repository.getEmployeeCallCount, 0);
        },
      );

      blocTest<EditEmployeeBloc, EditEmployeeState>(
        'loads only once when requested twice in a row',
        build: () {
          repository.getEmployeeResult = const Success<Employee>(employee);
          return buildBloc();
        },
        act: (bloc) => bloc
          ..add(const EditEmployeeRequested())
          ..add(const EditEmployeeRequested()),
        expect: () => [
          isA<EditEmployeeState>().having(
            (s) => s.status,
            'status',
            EditEmployeeStatus.loading,
          ),
          isA<EditEmployeeState>().having(
            (s) => s.status,
            'status',
            EditEmployeeStatus.editing,
          ),
        ],
        verify: (_) {
          expect(repository.getEmployeeCallCount, 1);
        },
      );

      blocTest<EditEmployeeBloc, EditEmployeeState>(
        'retries the load after a loadFailure',
        build: () {
          repository.getEmployeeResult = const Success<Employee>(employee);
          return buildBloc();
        },
        seed: () =>
            const EditEmployeeState(status: EditEmployeeStatus.loadFailure),
        act: (bloc) => bloc.add(const EditEmployeeRequested()),
        expect: () => [
          isA<EditEmployeeState>().having(
            (s) => s.status,
            'status',
            EditEmployeeStatus.loading,
          ),
          isA<EditEmployeeState>()
              .having((s) => s.status, 'status', EditEmployeeStatus.editing)
              .having((s) => s.input.username, 'username', employee.username),
        ],
        verify: (_) {
          expect(repository.getEmployeeCallCount, 1);
        },
      );
    });

    group('EditEmployeeFieldChanged', () {
      const loadedInput = EmployeeInput(
        username: 'alex_123',
        firstName: 'Alex',
        lastName: 'Smith',
        email: 'alex@example.com',
      );

      blocTest<EditEmployeeBloc, EditEmployeeState>(
        'updates only the changed field and keeps validation errors visible',
        build: buildBloc,
        seed: () => const EditEmployeeState(
          status: EditEmployeeStatus.editing,
          input: loadedInput,
          showValidationErrors: true,
        ),
        act: (bloc) => bloc.add(
          const EditEmployeeFieldChanged(EmployeeField.username, 'alex'),
        ),
        expect: () => [
          isA<EditEmployeeState>()
              .having((s) => s.status, 'status', EditEmployeeStatus.editing)
              .having((s) => s.input.username, 'username', 'alex')
              .having((s) => s.input.firstName, 'firstName', 'Alex')
              .having((s) => s.input.lastName, 'lastName', 'Smith')
              .having((s) => s.input.email, 'email', 'alex@example.com')
              .having(
                (s) => s.showValidationErrors,
                'showValidationErrors',
                true,
              ),
        ],
      );

      blocTest<EditEmployeeBloc, EditEmployeeState>(
        'lets the user edit again after a saveFailure',
        build: buildBloc,
        seed: () => const EditEmployeeState(
          status: EditEmployeeStatus.saveFailure,
          input: loadedInput,
        ),
        act: (bloc) => bloc.add(
          const EditEmployeeFieldChanged(
            EmployeeField.email,
            'new@example.com',
          ),
        ),
        expect: () => [
          isA<EditEmployeeState>()
              .having((s) => s.status, 'status', EditEmployeeStatus.editing)
              .having((s) => s.input.email, 'email', 'new@example.com'),
        ],
      );

      blocTest<EditEmployeeBloc, EditEmployeeState>(
        'ignores field changes while submitting',
        build: buildBloc,
        seed: () => const EditEmployeeState(
          status: EditEmployeeStatus.submitting,
          input: loadedInput,
        ),
        act: (bloc) => bloc.add(
          const EditEmployeeFieldChanged(EmployeeField.username, 'alex'),
        ),
        expect: () => <EditEmployeeState>[],
      );

      blocTest<EditEmployeeBloc, EditEmployeeState>(
        'ignores field changes before the employee has loaded',
        build: buildBloc,
        act: (bloc) => bloc.add(
          const EditEmployeeFieldChanged(EmployeeField.username, 'alex'),
        ),
        expect: () => <EditEmployeeState>[],
      );
    });
    group('EditEmployeeSubmitted', () {
      const paddedInput = EmployeeInput(
        username: ' alex_123',
        firstName: ' Alex',
        lastName: ' Smith',
        email: ' alex@example.com',
      );

      void expectSavedTrimmedInput() {
        final saved = repository.lastUpdatedEmployeeInput;
        expect(saved?.username, 'alex_123');
        expect(saved?.firstName, 'Alex');
        expect(saved?.lastName, 'Smith');
        expect(saved?.email, 'alex@example.com');
      }

      blocTest<EditEmployeeBloc, EditEmployeeState>(
        'ignores submit before the employee has loaded',
        build: buildBloc,
        act: (bloc) => bloc.add(const EditEmployeeSubmitted()),
        expect: () => <EditEmployeeState>[],
        verify: (_) {
          expect(repository.updateEmployeeCount, 0);
        },
      );

      blocTest<EditEmployeeBloc, EditEmployeeState>(
        'ignores a second submit while already submitting',
        build: buildBloc,
        seed: () => const EditEmployeeState(
          input: paddedInput,
          status: EditEmployeeStatus.submitting,
        ),
        act: (bloc) => bloc.add(const EditEmployeeSubmitted()),
        expect: () => <EditEmployeeState>[],
        verify: (_) {
          expect(repository.updateEmployeeCount, 0);
        },
      );

      blocTest<EditEmployeeBloc, EditEmployeeState>(
        'shows validation errors and does not save when input is invalid',
        build: buildBloc,
        seed: () => EditEmployeeState(
          status: EditEmployeeStatus.editing,
          input: paddedInput.copyWith(email: 'nope'),
        ),
        act: (bloc) => bloc.add(const EditEmployeeSubmitted()),
        expect: () => [
          isA<EditEmployeeState>()
              .having((s) => s.status, 'status', EditEmployeeStatus.editing)
              .having(
                (s) => s.showValidationErrors,
                'showValidationErrors',
                true,
              )
              .having((s) => s.errors, 'errors', {
                EmployeeField.email: EmployeeValidationError.invalidEmail,
              }),
        ],
        verify: (_) {
          expect(repository.updateEmployeeCount, 0);
        },
      );

      blocTest<EditEmployeeBloc, EditEmployeeState>(
        'saves trimmed input and emits submitting then success',
        build: buildBloc,
        seed: () => const EditEmployeeState(
          input: paddedInput,
          status: EditEmployeeStatus.editing,
        ),
        act: (bloc) => bloc.add(const EditEmployeeSubmitted()),
        expect: () => [
          isA<EditEmployeeState>().having(
            (s) => s.status,
            'status',
            EditEmployeeStatus.submitting,
          ),
          isA<EditEmployeeState>().having(
            (s) => s.status,
            'status',
            EditEmployeeStatus.success,
          ),
        ],
        verify: (_) {
          expect(repository.updateEmployeeCount, 1);
          expect(repository.lastUpdatedEmployeeId, 7);
          expectSavedTrimmedInput();
        },
      );

      blocTest<EditEmployeeBloc, EditEmployeeState>(
        'emits notFound when the employee was deleted meanwhile',
        build: () {
          repository.updateEmployeeResult = const FailureResult<void>(
            EmployeeNotFoundFailure(),
          );
          return buildBloc();
        },
        seed: () => const EditEmployeeState(
          input: paddedInput,
          status: EditEmployeeStatus.editing,
        ),
        act: (bloc) => bloc.add(const EditEmployeeSubmitted()),
        expect: () => [
          isA<EditEmployeeState>().having(
            (s) => s.status,
            'status',
            EditEmployeeStatus.submitting,
          ),
          isA<EditEmployeeState>().having(
            (s) => s.status,
            'status',
            EditEmployeeStatus.notFound,
          ),
        ],
        verify: (_) {
          expect(repository.updateEmployeeCount, 1);
        },
      );

      blocTest<EditEmployeeBloc, EditEmployeeState>(
        'emits saveFailure and keeps the input when storage fails',
        build: () {
          repository.updateEmployeeResult = const FailureResult<void>(
            StorageFailure(),
          );
          return buildBloc();
        },
        seed: () => const EditEmployeeState(
          input: paddedInput,
          status: EditEmployeeStatus.editing,
        ),
        act: (bloc) => bloc.add(const EditEmployeeSubmitted()),
        expect: () => [
          isA<EditEmployeeState>().having(
            (s) => s.status,
            'status',
            EditEmployeeStatus.submitting,
          ),
          isA<EditEmployeeState>()
              .having((s) => s.status, 'status', EditEmployeeStatus.saveFailure)
              .having((s) => s.input.username, 'username', ' alex_123')
              .having((s) => s.input.email, 'email', ' alex@example.com'),
        ],
        verify: (_) {
          expect(repository.updateEmployeeCount, 1);
        },
      );

      blocTest<EditEmployeeBloc, EditEmployeeState>(
        'retries the save after a saveFailure',
        build: buildBloc,
        seed: () => const EditEmployeeState(
          input: paddedInput,
          status: EditEmployeeStatus.saveFailure,
        ),
        act: (bloc) => bloc.add(const EditEmployeeSubmitted()),
        expect: () => [
          isA<EditEmployeeState>().having(
            (s) => s.status,
            'status',
            EditEmployeeStatus.submitting,
          ),
          isA<EditEmployeeState>().having(
            (s) => s.status,
            'status',
            EditEmployeeStatus.success,
          ),
        ],
        verify: (_) {
          expect(repository.updateEmployeeCount, 1);
          expectSavedTrimmedInput();
        },
      );
    });
  });
}
