import 'package:bloc_test/bloc_test.dart';
import 'package:employee_book/core/domain/error/failure.dart';
import 'package:employee_book/core/domain/result/result.dart';
import 'package:employee_book/features/employees/domain/entities/employee_input.dart';
import 'package:employee_book/features/employees/domain/usecases/add_employee.dart';
import 'package:employee_book/features/employees/domain/validation/employee_validation.dart';
import 'package:employee_book/features/employees/presentation/bloc/add_employee/add_employee_bloc.dart';
import 'package:employee_book/features/employees/presentation/bloc/add_employee/add_employee_event.dart';
import 'package:employee_book/features/employees/presentation/bloc/add_employee/add_employee_state.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../../helpers/stub_employee_repository.dart';

void main() {
  group('AddEmployeeBloc', () {
    late StubEmployeeRepository repository;

    setUp(() {
      repository = StubEmployeeRepository();
    });

    AddEmployeeBloc buildBloc() => AddEmployeeBloc(AddEmployee(repository));
    const validInput = EmployeeInput(
      username: '  alex_123 ',
      firstName: ' Alex',
      lastName: 'Smith ',
      email: ' alex@example.com ',
    );

    blocTest<AddEmployeeBloc, AddEmployeeState>(
      'shows validation errors and does not save when submitted empty',
      build: buildBloc,
      act: (bloc) => bloc.add(const AddEmployeeSubmitted()),
      expect: () => [
        isA<AddEmployeeState>()
            .having((s) => s.status, 'status', AddEmployeeStatus.editing)
            .having((s) => s.showValidationErrors, 'showValidationErrors', true)
            .having(
              (s) => s.errors.keys,
              'error fields',
              containsAll(EmployeeField.values),
            ),
      ],
      verify: (bloc) {
        expect(repository.addCallCount, 0);
      },
    );

    blocTest<AddEmployeeBloc, AddEmployeeState>(
      'saves trimmed input and emits submitting then success',
      build: buildBloc,
      seed: () => const AddEmployeeState(input: validInput),
      act: (bloc) => bloc.add(const AddEmployeeSubmitted()),
      expect: () => [
        isA<AddEmployeeState>().having(
          (s) => s.status,
          'status',
          AddEmployeeStatus.submitting,
        ),
        isA<AddEmployeeState>().having(
          (s) => s.status,
          'status',
          AddEmployeeStatus.success,
        ),
      ],
      verify: (bloc) {
        expect(repository.addCallCount, 1);
        final saved = repository.lastAddedInput;
        expect(saved, isNotNull);
        expect(saved?.username, 'alex_123');
        expect(saved?.firstName, 'Alex');
        expect(saved?.lastName, 'Smith');
        expect(saved?.email, 'alex@example.com');
      },
    );

    blocTest<AddEmployeeBloc, AddEmployeeState>(
      'updates only the changed field',
      build: buildBloc,
      act: (bloc) => bloc.add(
        const EmployeeFieldChanged(EmployeeField.email, 'abc@gmail.com'),
      ),
      expect: () => [
        isA<AddEmployeeState>()
            .having((s) => s.status, 'status', AddEmployeeStatus.editing)
            .having((s) => s.input.email, 'email', 'abc@gmail.com')
            .having((s) => s.input.username, 'username', isEmpty)
            .having((s) => s.input.firstName, 'firstName', isEmpty)
            .having((s) => s.input.lastName, 'lastName', isEmpty),
      ],
    );

    blocTest<AddEmployeeBloc, AddEmployeeState>(
      'emits submitting then failure when the repository fails',
      build: () {
        repository.addResult = const FailureResult<void>(StorageFailure());
        return buildBloc();
      },
      seed: () => const AddEmployeeState(
        input: validInput,
        showValidationErrors: false,
      ),
      act: (bloc) => bloc.add(const AddEmployeeSubmitted()),
      expect: () => [
        isA<AddEmployeeState>()
            .having((s) => s.status, 'status', AddEmployeeStatus.submitting)
            .having(
              (s) => s.showValidationErrors,
              'showValidationErrors',
              true,
            ),
        isA<AddEmployeeState>().having(
          (s) => s.status,
          'status',
          AddEmployeeStatus.failure,
        ),
      ],
      verify: (bloc) => [
        expect(repository.addCallCount, 1),
        expect(
          repository.addResult,
          isA<FailureResult<void>>().having(
            (r) => r.failure,
            'failure',
            isA<StorageFailure>(),
          ),
        ),
      ],
    );

    blocTest<AddEmployeeBloc, AddEmployeeState>(
      'ignores field changes after a successful save',
      build: buildBloc,
      seed: () => const AddEmployeeState(
        input: validInput,
        status: AddEmployeeStatus.success,
      ),
      act: (bloc) =>
          bloc.add(const EmployeeFieldChanged(EmployeeField.username, 'bob')),
      expect: () => <AddEmployeeState>[],
    );

    blocTest<AddEmployeeBloc, AddEmployeeState>(
      'reset clears the input and bumps the form revision',
      build: buildBloc,
      seed: () => const AddEmployeeState(
        input: validInput,
        status: AddEmployeeStatus.failure,
        showValidationErrors: true,
        formRevision: 2,
      ),
      act: (bloc) => bloc.add(const AddEmployeeReset()),
      expect: () => [
        isA<AddEmployeeState>()
            .having((s) => s.status, 'status', AddEmployeeStatus.editing)
            .having(
              (s) => s.showValidationErrors,
              'showValidationErrors',
              false,
            )
            .having((s) => s.input, 'input', isA<EmployeeInput>())
            .having((s) => s.formRevision, 'formRevision', 3),
      ],
    );
  });
}
