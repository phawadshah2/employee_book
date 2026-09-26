import 'package:employee_book/core/data/local/database/app_database.dart';
import 'package:employee_book/features/employees/employee_injection.dart';
import 'package:get_it/get_it.dart';

class InjectionContainer {
  const InjectionContainer._();

  static final GetIt _getIt = GetIt.instance;

  static Future<void> setupDependencies() async {
    _getIt.registerLazySingleton<AppDatabase>(AppDatabase.new);
    initEmployeeDependencies(_getIt);
  }
}
