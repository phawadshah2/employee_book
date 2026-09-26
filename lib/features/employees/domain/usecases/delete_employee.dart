import 'package:employee_book/core/domain/result/result.dart';
import 'package:employee_book/core/domain/usecase/usecase.dart';
import 'package:employee_book/features/employees/domain/repositories/employee_repository.dart';

class DeleteEmployee implements UseCase<void, int> {
  const DeleteEmployee(this._repository);
  final EmployeeRepository _repository;
  @override
  Future<Result<void>> call(int id) async {
    return await _repository.deleteEmployee(id);
  }
}
