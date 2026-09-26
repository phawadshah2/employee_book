import 'dart:developer' as developer;
import 'package:employee_book/core/domain/error/failure.dart';
import 'package:employee_book/core/domain/result/result.dart';
import 'package:employee_book/features/employees/data/datasources/employee_local_data_source.dart';
import 'package:employee_book/features/employees/data/models/employee_dto.dart';
import 'package:employee_book/features/employees/domain/entities/employee.dart';
import 'package:employee_book/features/employees/domain/entities/employee_input.dart';
import 'package:employee_book/features/employees/domain/repositories/employee_repository.dart';
import 'package:sqlite3/common.dart';

class LocalEmployeeRepository implements EmployeeRepository {
  const LocalEmployeeRepository(this._localDataSource);
  final EmployeeLocalDataSource _localDataSource;

  @override
  Future<Result<void>> addEmployee(EmployeeInput input) async {
    try {
      final resultValue = await _localDataSource.insertEmployee(
        username: input.username,
        firstName: input.firstName,
        lastName: input.lastName,
        email: input.email,
      );
      developer.log('value is $resultValue');
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
  Future<Result<List<Employee>>> getEmployees() async {
    try {
      final rows = await _localDataSource.getEmployees();
      final dtos = rows.map((row) {
        return EmployeeDto.fromRow(row);
      }).toList();
      final employees = dtos.map((dto) => dto.toEntity()).toList();
      return Success<List<Employee>>(employees);
    } on SqliteException catch (error, stackTrace) {
      _reportStorageError(error, stackTrace);
      return const FailureResult<List<Employee>>(StorageFailure());
    }
  }
}
