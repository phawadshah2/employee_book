import 'package:employee_book/core/data/local/database/app_database.dart';
import 'package:employee_book/features/employees/domain/entities/employee.dart';

class EmployeeDto extends Employee {
  EmployeeDto({
    required super.id,
    required super.username,
    required super.firstName,
    required super.lastName,
    required super.email,
  });

  factory EmployeeDto.fromRow(EmployeeRow row) {
    return EmployeeDto(
      id: row.id,
      username: row.username,
      firstName: row.firstName,
      lastName: row.lastName,
      email: row.email,
    );
  }

  Employee toEntity() {
    return Employee(
      id: id,
      username: username,
      firstName: firstName,
      lastName: lastName,
      email: email,
    );
  }
}
