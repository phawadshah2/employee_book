import 'package:employee_book/features/employees/domain/validation/employee_validation.dart';

sealed class EditEmployeeEvent {
  const EditEmployeeEvent();
}

final class EditEmployeeRequested extends EditEmployeeEvent {
  const EditEmployeeRequested();
}

final class EditEmployeeFieldChanged extends EditEmployeeEvent {
  const EditEmployeeFieldChanged(this.field, this.value);

  final EmployeeField field;
  final String value;
}

final class EditEmployeeSubmitted extends EditEmployeeEvent {
  const EditEmployeeSubmitted();
}
