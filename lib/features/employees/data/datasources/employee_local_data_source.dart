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
}
