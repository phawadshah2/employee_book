import 'package:employee_book/core/domain/result/result.dart';
import 'package:employee_book/core/domain/usecase/usecase.dart';
import 'package:employee_book/features/employees/domain/entities/employee.dart';
import 'package:employee_book/features/employees/domain/repositories/employee_repository.dart';

class EmployeeList implements UseCase<List<Employee>, NoParams> {
  const EmployeeList(this._repository);
  final EmployeeRepository _repository;
  @override
  Future<Result<List<Employee>>> call(NoParams input) async {
    return await _repository.getEmployees();
  }
}
