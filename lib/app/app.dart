import 'package:employee_book/app/router/app_router.dart';
import 'package:employee_book/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EmployeeBook extends StatefulWidget {
  const EmployeeBook({super.key});

  @override
  State<EmployeeBook> createState() => _EmployeeBookState();
}

class _EmployeeBookState extends State<EmployeeBook> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = AppRouter.createRouter();
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Employees',
      routerConfig: _router,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
    );
  }
}
