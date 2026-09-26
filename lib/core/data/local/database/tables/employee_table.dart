import 'package:drift/drift.dart';

@DataClassName('EmployeeRow')
class Employees extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get username =>
      text().named('user_name').withLength(min: 3, max: 30)();
  TextColumn get firstName => text().named('first_name').withLength(max: 100)();
  TextColumn get lastName => text().named('last_name').withLength(max: 100)();
  TextColumn get email =>
      text().named('email')(); // add indexing to this column, should be unique
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
// Track migration, incase if there's any issue with migration so we can delete
// last migration file and run again with bugs fixed
