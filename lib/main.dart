import 'package:employee_book/app/app.dart';
import 'package:employee_book/core/di/injection_container.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await InjectionContainer.setupDependencies();
  runApp(const EmployeeBook());
}
