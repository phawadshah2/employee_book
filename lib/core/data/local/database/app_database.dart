import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:employee_book/core/data/local/database/tables/employee_table.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Employees])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_createConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _createConnection() {
    return driftDatabase(
      name: 'employee_app',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }
}
