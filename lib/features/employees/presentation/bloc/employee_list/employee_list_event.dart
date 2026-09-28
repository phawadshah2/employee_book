sealed class EmployeeListEvent {
  const EmployeeListEvent();
}

final class EmployeeListRequested extends EmployeeListEvent {
  const EmployeeListRequested();
}

final class EmployeeListNextPageRequested extends EmployeeListEvent {
  const EmployeeListNextPageRequested();
}

final class EmployeeDeleteRequested extends EmployeeListEvent {
  const EmployeeDeleteRequested(this.id);
  final int id;
}
