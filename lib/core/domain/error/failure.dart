sealed class Failure {
  const Failure();
}

final class ValidationFailure extends Failure {
  const ValidationFailure();
}

final class StorageFailure extends Failure {
  const StorageFailure();
}

final class EmployeeNotFoundFailure extends Failure {
  const EmployeeNotFoundFailure();
}
