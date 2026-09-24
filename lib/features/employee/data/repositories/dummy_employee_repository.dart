import 'package:employee_book/features/employee/domain/entities/employee_input.dart';
import 'package:employee_book/features/employee/domain/repositories/employee_repository.dart';

class DummyEmployeeRepository implements EmployeeRepository {
  const DummyEmployeeRepository();
  @override
  Future<void> addEmployee(EmployeeInput input) async {
    // Simulates an API request. Nothing is persisted.
    await Future<void>.delayed(const Duration(seconds: 8));
  }
}
