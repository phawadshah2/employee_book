import 'package:employee_book/core/data/local/database/app_database.dart';
import 'package:employee_book/features/employees/data/datasources/employee_local_data_source.dart';
import 'package:employee_book/features/employees/data/repositories/local_employee_repository.dart';
import 'package:employee_book/features/employees/domain/repositories/employee_repository.dart';
import 'package:employee_book/features/employees/domain/usecases/add_employee.dart';
import 'package:employee_book/features/employees/domain/usecases/delete_employee.dart';
import 'package:employee_book/features/employees/domain/usecases/employee_list.dart';
import 'package:get_it/get_it.dart';

void initEmployeeDependencies(GetIt getIt) {
  getIt.registerLazySingleton<EmployeeLocalDataSource>(
    () => EmployeeLocalDataSource(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<EmployeeRepository>(
    () => LocalEmployeeRepository(getIt<EmployeeLocalDataSource>()),
  );
  getIt.registerFactory(() => AddEmployee(getIt<EmployeeRepository>()));
  getIt.registerFactory(() => EmployeeList(getIt<EmployeeRepository>()));
  getIt.registerFactory(() => DeleteEmployee(getIt<EmployeeRepository>()));
}
