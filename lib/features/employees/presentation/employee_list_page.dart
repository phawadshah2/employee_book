import 'package:employee_book/features/employees/presentation/bloc/employee_list/employee_list_bloc.dart';
import 'package:employee_book/features/employees/presentation/bloc/employee_list/employee_list_event.dart';
import 'package:employee_book/features/employees/presentation/bloc/employee_list/employee_list_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          if (!context.mounted) return;
          context.read<EmployeeListBloc>().add(const EmployeeListRequested());
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Employee'),
      ),
      body: BlocBuilder<EmployeeListBloc, EmployeeListState>(
        builder: (context, state) {
          switch (state.status) {
            case EmployeeListStatus.initial:
            case EmployeeListStatus.loading:
              return const Center(child: CircularProgressIndicator());

            case EmployeeListStatus.failure:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Could not load employees. Please try again.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () {
                          context.read<EmployeeListBloc>().add(
                            const EmployeeListRequested(),
                          );
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );

            case EmployeeListStatus.success:
              if (state.employees.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No employees yet. Tap Add Employee to get started.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
                itemCount: state.employees.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final employee = state.employees[index];
                  return ListTile(
                    key: ValueKey(employee.id),
                    leading: const CircleAvatar(
                      child: Icon(Icons.person_outline),
                    ),
                    title: Text(employee.name),
                    subtitle: Text('@${employee.username}\n${employee.email}'),
                    isThreeLine: true,
                  );
                },
              );
          }
        },
      ),
    );
  }
}
