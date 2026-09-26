import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EmployeeListPage extends StatelessWidget {
  const EmployeeListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Employees'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push<bool>('/employees/add');
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Employee'),
      ),
      body: const Center(child: Text('Employees List')),
    );
  }
}
