class EmployeeInput {
  const EmployeeInput({
    this.username = '',
    this.firstName = '',
    this.lastName = '',
    this.email = '',
  });
  final String username;
  final String firstName;
  final String lastName;
  final String email;

  EmployeeInput copyWith({
    String? username,
    String? firstName,
    String? lastName,
    String? email,
  }) {
    return EmployeeInput(
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
    );
  }

  EmployeeInput normalized() {
    return EmployeeInput(
      username: username.trim(),
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      email: email.trim(),
    );
  }
}
