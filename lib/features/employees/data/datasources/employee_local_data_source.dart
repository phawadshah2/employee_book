import 'package:drift/drift.dart';
import 'package:employee_book/core/data/local/database/app_database.dart';

class EmployeeLocalDataSource {
  const EmployeeLocalDataSource(this._database);
  final AppDatabase _database;

  Future<int> insertEmployee({
    required String username,
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 3));
    return await _database
        .into(_database.employees)
        .insert(
          EmployeesCompanion.insert(
            username: username,
            firstName: firstName,
            lastName: lastName,
            email: email,
          ),
        );
  }

  Future<List<EmployeeRow>> getEmployees({
    required int limit,
    int? afterId,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 2));
    final query = _database.select(_database.employees);
    if (afterId != null) {
      query.where((employee) => employee.id.isBiggerThanValue(afterId));
    }
    query
      ..orderBy([(employee) => OrderingTerm.asc(employee.id)])
      ..limit(limit);

    return await query.get();
  }

  Future<int> deleteEmployee(int id) async {
    await Future<void>.delayed(const Duration(seconds: 2));
    return await (_database.delete(
      _database.employees,
    )..where((employee) => employee.id.equals(id))).go();
  }

  Future<EmployeeRow?> getEmployee(int id) async {
    await Future<void>.delayed(const Duration(seconds: 2));
    final query = _database.select(_database.employees)
      ..where((employee) => employee.id.equals(id));
    return await query.getSingleOrNull();
  }

  Future<int> updateEmployee({
    required int id,
    required String username,
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    final query = _database.update(_database.employees)
      ..where((employee) => employee.id.equals(id));
    return await query.write(
      EmployeesCompanion(
        username: Value(username),
        firstName: Value(firstName),
        lastName: Value(lastName),
        email: Value(email),
      ),
    );
  }
}
