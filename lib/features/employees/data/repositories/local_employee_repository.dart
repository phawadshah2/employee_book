import 'dart:developer' as developer;
import 'package:employee_book/core/domain/error/failure.dart';
import 'package:employee_book/core/domain/result/result.dart';
import 'package:employee_book/features/employees/data/datasources/employee_local_data_source.dart';
import 'package:employee_book/features/employees/data/models/employee_dto.dart';
import 'package:employee_book/features/employees/domain/entities/employee.dart';
import 'package:employee_book/features/employees/domain/entities/employee_input.dart';
import 'package:employee_book/features/employees/domain/entities/employee_page.dart';
import 'package:employee_book/features/employees/domain/entities/employee_page_request.dart';
import 'package:employee_book/features/employees/domain/repositories/employee_repository.dart';
import 'package:sqlite3/common.dart';

class LocalEmployeeRepository implements EmployeeRepository {
  const LocalEmployeeRepository(this._localDataSource);
  final EmployeeLocalDataSource _localDataSource;

  @override
  Future<Result<void>> addEmployee(EmployeeInput input) async {
    try {
      await _localDataSource.insertEmployee(
        username: input.username,
        firstName: input.firstName,
        lastName: input.lastName,
        email: input.email,
      );
      return const Success<void>(null);
    } on SqliteException catch (error, stackTrace) {
      _reportStorageError(error, stackTrace);
      return const FailureResult<void>(StorageFailure());
    }
  }

  void _reportStorageError(Object error, StackTrace stackTrace) {
    developer.log(
      'Employee database operation failed',
      name: 'LocalEmployeeRepository',
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  Future<Result<void>> deleteEmployee(int id) async {
    try {
      await _localDataSource.deleteEmployee(id);
      return const Success<void>(null);
    } on SqliteException catch (error, stackTrace) {
      _reportStorageError(error, stackTrace);
      return const FailureResult<void>(StorageFailure());
    }
  }

  @override
  Future<Result<EmployeePage>> getEmployees(EmployeePageRequest request) async {
    try {
      final rows = await _localDataSource.getEmployees(
        limit: request.limit + 1,
        afterId: request.afterId,
      );
      final hasMore = rows.length > request.limit;
      final employees = rows
          .take(request.limit)
          .map((row) => EmployeeDto.fromRow(row).toEntity())
          .toList();
      return Success<EmployeePage>(
        EmployeePage(
          employees: employees,
          nextCursor: hasMore ? employees.last.id : null,
        ),
      );
    } on SqliteException catch (error, stackTrace) {
      _reportStorageError(error, stackTrace);
      return const FailureResult<EmployeePage>(StorageFailure());
    }
  }

  @override
  Future<Result<Employee>> getEmployee(int id) async {
    try {
      final row = await _localDataSource.getEmployee(id);
      if (row == null) {
        return const FailureResult<Employee>(EmployeeNotFoundFailure());
      }
      final employee = EmployeeDto.fromRow(row);
      return Success<Employee>(employee);
    } on SqliteException catch (error, stackTrace) {
      _reportStorageError(error, stackTrace);
      return const FailureResult<Employee>(StorageFailure());
    }
  }

  @override
  Future<Result<void>> updateEmployee({
    required int id,
    required EmployeeInput input,
  }) async {
    try {
      final affectedRows = await _localDataSource.updateEmployee(
        id: id,
        username: input.username,
        firstName: input.firstName,
        lastName: input.lastName,
        email: input.email,
      );

      if (affectedRows == 0) {
        return const FailureResult<void>(EmployeeNotFoundFailure());
      }
      return const Success<void>(null);
    } on SqliteException catch (error, stackTrace) {
      _reportStorageError(error, stackTrace);
      return const FailureResult<Employee>(StorageFailure());
    }
  }
}
