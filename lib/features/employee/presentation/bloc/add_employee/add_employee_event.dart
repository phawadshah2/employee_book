import 'package:employee_book/features/employee/domain/validation/employee_validation.dart';

sealed class AddEmployeeEvent {
  const AddEmployeeEvent();
}

final class EmployeeFieldChanged extends AddEmployeeEvent {
  const EmployeeFieldChanged(this.field, this.value);

  final EmployeeField field;
  final String value;
}

final class AddEmployeeSubmitted extends AddEmployeeEvent {
  const AddEmployeeSubmitted();
}
