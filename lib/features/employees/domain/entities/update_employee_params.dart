import 'package:employee_book/features/employees/domain/entities/employee_input.dart';

class UpdateEmployeeParams {
  const UpdateEmployeeParams({required this.id, required this.input});
  final int id;
  final EmployeeInput input;
}
