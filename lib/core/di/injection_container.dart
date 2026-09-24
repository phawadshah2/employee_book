import 'package:employee_book/features/employee/employee_injection.dart';
import 'package:get_it/get_it.dart';

class InjectionContainer {
  const InjectionContainer._();

  static final GetIt _getIt = GetIt.instance;

  static Future<void> setupDependencies() async {
    initEmployeeDependencies(_getIt);
  }
}
