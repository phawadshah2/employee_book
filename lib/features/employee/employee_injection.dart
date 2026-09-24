import 'package:employee_book/features/employee/data/repositories/dummy_employee_repository.dart';
import 'package:employee_book/features/employee/domain/repositories/employee_repository.dart';
import 'package:employee_book/features/employee/domain/usecases/add_employee.dart';
import 'package:get_it/get_it.dart';

void initEmployeeDependencies(GetIt getIt) {
  getIt.registerLazySingleton<EmployeeRepository>(
    () => const DummyEmployeeRepository(),
  );
  getIt.registerFactory(() => AddEmployee(getIt<EmployeeRepository>()));
}
