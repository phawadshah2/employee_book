import 'package:bloc_test/bloc_test.dart';
import 'package:employee_book/core/domain/error/failure.dart';
import 'package:employee_book/core/domain/result/result.dart';
import 'package:employee_book/features/employees/domain/entities/employee.dart';
import 'package:employee_book/features/employees/domain/entities/employee_page.dart';
import 'package:employee_book/features/employees/domain/usecases/delete_employee.dart';
import 'package:employee_book/features/employees/domain/usecases/employee_list.dart';
import 'package:employee_book/features/employees/presentation/bloc/employee_list/employee_list_bloc.dart';
import 'package:employee_book/features/employees/presentation/bloc/employee_list/employee_list_event.dart';
import 'package:employee_book/features/employees/presentation/bloc/employee_list/employee_list_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/stub_employee_repository.dart';

void main() {
  group('EmployeeListBloc', () {
    late StubEmployeeRepository repository;

    setUp(() {
      repository = StubEmployeeRepository();
    });

    EmployeeListBloc buildBloc() => EmployeeListBloc(
      employeeList: EmployeeList(repository),
      deleteEmployee: DeleteEmployee(repository),
    );
    Employee employee(int id) => Employee(
      id: id,
      username: 'user_$id',
      firstName: 'First$id',
      lastName: 'Last$id',
      email: 'user$id@example.com',
    );

    List<Employee> employees(Iterable<int> ids) => ids.map(employee).toList();
    group('EmployeeListRequested', () {
      blocTest<EmployeeListBloc, EmployeeListState>(
        'emits loading then success with the first page',
        build: () {
          repository.getEmployeesResult = Success<EmployeePage>(
            EmployeePage(
              employees: employees([1, 2, 3, 4, 5, 6]),
              nextCursor: 6,
            ),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(const EmployeeListRequested()),
        expect: () => [
          isA<EmployeeListState>().having(
            (s) => s.status,
            'status',
            EmployeeListStatus.loading,
          ),
          isA<EmployeeListState>()
              .having((s) => s.status, 'status', EmployeeListStatus.success)
              .having((s) => s.employees.map((e) => e.id), 'employee ids', [
                1,
                2,
                3,
                4,
                5,
                6,
              ])
              .having((s) => s.nextCursor, 'nextCursor', 6)
              .having((s) => s.hasMore, 'hasMore', true),
        ],
        verify: (_) {
          expect(repository.getEmployeesCallCount, 1);
          expect(repository.lastPageRequest?.limit, 20);
          expect(repository.lastPageRequest?.afterId, isNull);
        },
      );

      blocTest<EmployeeListBloc, EmployeeListState>(
        'emits loading then failure when the repository fails',
        build: () {
          repository.getEmployeesResult = const FailureResult<EmployeePage>(
            StorageFailure(),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(const EmployeeListRequested()),
        expect: () => [
          isA<EmployeeListState>().having(
            (s) => s.status,
            'status',
            EmployeeListStatus.loading,
          ),
          isA<EmployeeListState>()
              .having((s) => s.status, 'status', EmployeeListStatus.failure)
              .having((s) => s.employees, 'employees', <Employee>[])
              .having((s) => s.nextCursor, 'nextCursor', null),
        ],
        verify: (_) {
          expect(repository.getEmployeesCallCount, 1);
          expect(repository.lastPageRequest?.limit, 20);
          expect(repository.lastPageRequest?.afterId, isNull);
        },
      );

      blocTest<EmployeeListBloc, EmployeeListState>(
        'emits success with no employees when the list is empty',
        build: () {
          repository.getEmployeesResult = Success<EmployeePage>(
            EmployeePage(employees: const [], nextCursor: null),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(const EmployeeListRequested()),
        expect: () => [
          isA<EmployeeListState>().having(
            (s) => s.status,
            'status',
            EmployeeListStatus.loading,
          ),
          isA<EmployeeListState>()
              .having((s) => s.status, 'status', EmployeeListStatus.success)
              .having((s) => s.employees, 'employees', <Employee>[])
              .having((s) => s.nextCursor, 'nextCursor', null),
        ],
        verify: (_) {
          expect(repository.getEmployeesCallCount, 1);
          expect(repository.lastPageRequest?.limit, 20);
          expect(repository.lastPageRequest?.afterId, isNull);
        },
      );

      blocTest<EmployeeListBloc, EmployeeListState>(
        'refresh replaces the list and clears the load more error',
        build: () {
          repository.getEmployeesResult = Success<EmployeePage>(
            EmployeePage(employees: employees([10, 11]), nextCursor: null),
          );
          return buildBloc();
        },
        seed: () => EmployeeListState(
          status: EmployeeListStatus.success,
          employees: employees([1, 2, 3, 4, 5]),
          nextCursor: 5,
          loadMoreError: 'Could not load more employees. Please try again.',
        ),
        act: (bloc) => bloc.add(const EmployeeListRequested()),
        expect: () => [
          isA<EmployeeListState>()
              .having((s) => s.status, 'status', EmployeeListStatus.loading)
              .having((s) => s.employees, 'employees', isEmpty),
          isA<EmployeeListState>()
              .having((s) => s.status, 'status', EmployeeListStatus.success)
              .having((s) => s.employees.map((e) => e.id), 'employees', [
                10,
                11,
              ])
              .having((s) => s.hasMore, 'hasMore', false)
              .having((s) => s.loadMoreError, 'loadMoreError', isNull),
        ],
        verify: (_) {
          expect(repository.getEmployeesCallCount, 1);
          expect(repository.lastPageRequest?.afterId, isNull);
        },
      );
    });
    group('EmployeeListNextPageRequested', () {
      blocTest<EmployeeListBloc, EmployeeListState>(
        'shows loading more then appends the next page',
        build: () {
          repository.getEmployeesResult = Success<EmployeePage>(
            EmployeePage(employees: employees([4, 5, 6]), nextCursor: 6),
          );
          return buildBloc();
        },
        seed: () => EmployeeListState(
          employees: employees([1, 2, 3]),
          nextCursor: 3,
          status: EmployeeListStatus.success,
        ),
        act: (bloc) => bloc.add(const EmployeeListNextPageRequested()),
        expect: () => [
          isA<EmployeeListState>()
              .having((s) => s.status, 'status', EmployeeListStatus.success)
              .having((s) => s.employees.map((e) => e.id), 'employees', [
                1,
                2,
                3,
              ])
              .having((s) => s.nextCursor, 'nextCursor', 3)
              .having((s) => s.isLoadingMore, 'isLoadingMore', true),

          isA<EmployeeListState>()
              .having((s) => s.status, 'status', EmployeeListStatus.success)
              .having((s) => s.employees.map((e) => e.id), 'employees', [
                1,
                2,
                3,
                4,
                5,
                6,
              ])
              .having((s) => s.nextCursor, 'nextCursor', 6)
              .having((s) => s.isLoadingMore, 'isLoadingMore', false),
        ],
        verify: (_) {
          expect(repository.getEmployeesCallCount, 1);
          expect(repository.lastPageRequest?.limit, 20);
          expect(repository.lastPageRequest?.afterId, 3);
        },
      );

      blocTest<EmployeeListBloc, EmployeeListState>(
        'keeps the list and cursor and sets an error when loading fails',
        build: () {
          repository.getEmployeesResult = const FailureResult<EmployeePage>(
            StorageFailure(),
          );
          return buildBloc();
        },
        seed: () => EmployeeListState(
          employees: employees([1, 2, 3]),
          nextCursor: 3,
          status: EmployeeListStatus.success,
        ),
        act: (bloc) => bloc.add(const EmployeeListNextPageRequested()),
        expect: () => [
          isA<EmployeeListState>()
              .having((s) => s.status, 'status', EmployeeListStatus.success)
              .having((s) => s.employees.map((e) => e.id), 'employees', [
                1,
                2,
                3,
              ])
              .having((s) => s.nextCursor, 'nextCursor', 3)
              .having((s) => s.isLoadingMore, 'isLoadingMore', true),

          isA<EmployeeListState>()
              .having((s) => s.status, 'status', EmployeeListStatus.success)
              .having((s) => s.employees.map((e) => e.id), 'employees', [
                1,
                2,
                3,
              ])
              .having((s) => s.isLoadingMore, 'isLoadingMore', false)
              .having((s) => s.nextCursor, 'nextCursor', 3)
              .having(
                (s) => s.loadMoreError,
                'loadMoreError',
                'Could not load more employees. Please try again.',
              ),
        ],
        verify: (_) {
          expect(repository.getEmployeesCallCount, 1);
          expect(repository.lastPageRequest?.limit, 20);
          expect(repository.lastPageRequest?.afterId, 3);
        },
      );

      blocTest<EmployeeListBloc, EmployeeListState>(
        'clears the load more error after a successful retry',
        build: () {
          repository.getEmployeesResult = Success<EmployeePage>(
            EmployeePage(employees: employees([4, 5, 6]), nextCursor: 6),
          );
          return buildBloc();
        },
        seed: () => EmployeeListState(
          employees: employees([1, 2, 3]),
          nextCursor: 3,
          status: EmployeeListStatus.success,
          loadMoreError: 'Could not load more employees. Please try again.',
          isLoadingMore: false,
        ),
        act: (bloc) => bloc.add(const EmployeeListNextPageRequested()),
        expect: () => [
          isA<EmployeeListState>()
              .having((s) => s.status, 'status', EmployeeListStatus.success)
              .having((s) => s.employees.map((e) => e.id), 'employees', [
                1,
                2,
                3,
              ])
              .having((s) => s.nextCursor, 'nextCursor', 3)
              .having((s) => s.loadMoreError, 'loadMoreError', null)
              .having((s) => s.isLoadingMore, 'isLoadingMore', true),

          isA<EmployeeListState>()
              .having((s) => s.status, 'status', EmployeeListStatus.success)
              .having((s) => s.employees.map((e) => e.id), 'employees', [
                1,
                2,
                3,
                4,
                5,
                6,
              ])
              .having((s) => s.loadMoreError, 'loadMoreError', null)
              .having((s) => s.nextCursor, 'nextCursor', 6)
              .having((s) => s.isLoadingMore, 'isLoadingMore', false),
        ],
        verify: (_) {
          expect(repository.getEmployeesCallCount, 1);
          expect(repository.lastPageRequest?.limit, 20);
          expect(repository.lastPageRequest?.afterId, 3);
        },
      );

      blocTest<EmployeeListBloc, EmployeeListState>(
        'does nothing when there are no more pages',
        build: buildBloc,
        seed: () => EmployeeListState(
          employees: employees([1, 2, 3]),
          nextCursor: null,
          status: EmployeeListStatus.success,
          isLoadingMore: false,
        ),
        act: (bloc) => bloc.add(const EmployeeListNextPageRequested()),
        expect: () => <EmployeeListState>[],
        verify: (_) {
          expect(repository.getEmployeesCallCount, 0);
        },
      );

      blocTest<EmployeeListBloc, EmployeeListState>(
        'does nothing while already loading more',
        build: buildBloc,
        seed: () => EmployeeListState(
          employees: employees([1, 2, 3]),
          nextCursor: 3,
          status: EmployeeListStatus.success,
          isLoadingMore: true,
        ),
        act: (bloc) => bloc.add(const EmployeeListNextPageRequested()),
        expect: () => <EmployeeListState>[],
        verify: (_) {
          expect(repository.getEmployeesCallCount, 0);
        },
      );
      blocTest<EmployeeListBloc, EmployeeListState>(
        'does nothing before the first page has loaded',
        build: buildBloc,
        seed: () => EmployeeListState(
          employees: employees([1, 2, 3]),
          status: EmployeeListStatus.loading,
          nextCursor: 3,
        ),
        act: (bloc) => bloc.add(const EmployeeListNextPageRequested()),
        expect: () => <EmployeeListState>[],
        verify: (_) {
          expect(repository.getEmployeesCallCount, 0);
        },
      );
    });
    group('EmployeeDeleteRequested', () {
      blocTest<EmployeeListBloc, EmployeeListState>(
        'marks the employee as deleting then removes it from the list',
        build: buildBloc,
        seed: () => EmployeeListState(
          status: EmployeeListStatus.success,
          employees: employees([3, 6, 8]),
          nextCursor: 8,
          loadMoreError: 'Could not load more employees. Please try again.',
        ),

        act: (bloc) => bloc.add(const EmployeeDeleteRequested(6)),
        expect: () => [
          isA<EmployeeListState>()
              .having((s) => s.deletingEmployeeId, 'deletingEmployeeId', 6)
              .having((s) => s.employees.map((e) => e.id), 'employees', [
                3,
                6,
                8,
              ]),
          isA<EmployeeListState>()
              .having((s) => s.status, 'status', EmployeeListStatus.success)
              .having((s) => s.employees.map((e) => e.id), 'employees', [3, 8])
              .having((s) => s.isDeleting, 'isDeleting', false)
              .having((s) => s.nextCursor, 'nextCursor', 8)
              .having((s) => s.loadMoreError, 'loadMoreError', isNotNull),
        ],
        verify: (bloc) {
          expect(repository.deleteEmployeeCount, 1);
          expect(repository.lastDeletedEmployeeId, 6);
        },
      );

      blocTest<EmployeeListBloc, EmployeeListState>(
        'keeps the employee and sets a delete error when deleting fails',
        build: () {
          repository.deleteEmployeeResult = const FailureResult<void>(
            StorageFailure(),
          );
          return buildBloc();
        },
        seed: () => EmployeeListState(
          status: EmployeeListStatus.success,
          employees: employees([3, 6, 8]),
          nextCursor: 8,
        ),
        act: (bloc) => bloc.add(const EmployeeDeleteRequested(6)),
        expect: () => [
          isA<EmployeeListState>().having(
            (s) => s.deletingEmployeeId,
            'deletingEmployeeId',
            6,
          ),
          isA<EmployeeListState>()
              .having((s) => s.status, 'status', EmployeeListStatus.success)
              .having((s) => s.employees.map((e) => e.id), 'employees', [
                3,
                6,
                8,
              ])
              .having((s) => s.isDeleting, 'isDeleting', false)
              .having((s) => s.nextCursor, 'nextCursor', 8)
              .having(
                (s) => s.deleteError,
                'deleteError',
                'Could not delete employee. Please try again.',
              ),
        ],
        verify: (bloc) {
          expect(repository.deleteEmployeeCount, 1);
          expect(repository.lastDeletedEmployeeId, 6);
        },
      );

      blocTest<EmployeeListBloc, EmployeeListState>(
        'does nothing when the employee is not in the list',
        build: buildBloc,
        seed: () => EmployeeListState(
          employees: employees([3, 6, 8]),
          status: EmployeeListStatus.success,
        ),
        act: (bloc) => bloc.add(const EmployeeDeleteRequested(11)),
        expect: () => <EmployeeListState>[],
        verify: (bloc) {
          expect(repository.deleteEmployeeCount, 0);
        },
      );

      blocTest<EmployeeListBloc, EmployeeListState>(
        'does nothing before the list has loaded',
        build: buildBloc,
        seed: () => EmployeeListState(
          status: EmployeeListStatus.loading,
          employees: employees([3, 6, 8]),
        ),
        act: (bloc) => bloc.add(const EmployeeDeleteRequested(11)),
        expect: () => <EmployeeListState>[],
        verify: (bloc) {
          expect(repository.deleteEmployeeCount, 0);
        },
      );
    });
  });
}
