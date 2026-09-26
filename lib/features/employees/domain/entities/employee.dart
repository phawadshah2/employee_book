class Employee {
  const Employee({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;

  String get name => '$firstName $lastName';
}
