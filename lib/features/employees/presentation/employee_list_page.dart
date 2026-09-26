import 'package:employee_book/features/employees/presentation/bloc/employee_list/employee_list_bloc.dart';
import 'package:employee_book/features/employees/presentation/bloc/employee_list/employee_list_event.dart';
import 'package:employee_book/features/employees/presentation/bloc/employee_list/employee_list_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

class EmployeeListPage extends StatelessWidget {
  const EmployeeListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDeleting = context.select<EmployeeListBloc, bool>(
      (bloc) => bloc.state.isDeleting,
    );
    final scaffold = Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Employees'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isDeleting
            ? null
            : () async {
                await context.push<bool>('/employees/add');

                if (!context.mounted) return;

                context.read<EmployeeListBloc>().add(
                  const EmployeeListRequested(),
                );
              },
        icon: const Icon(Icons.add),
        label: const Text('Add Employee'),
      ),
      body: BlocConsumer<EmployeeListBloc, EmployeeListState>(
        listenWhen: (previous, current) {
          return current.deleteError != null &&
              previous.deleteError != current.deleteError;
        },
        listener: (context, state) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.deleteError!)));
        },
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

                  return Slidable(
                    key: ValueKey(employee.id),
                    enabled: !state.isDeleting,
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      extentRatio: 0.28,
                      children: [
                        SlidableAction(
                          onPressed: state.isDeleting
                              ? null
                              : (_) {
                                  context.read<EmployeeListBloc>().add(
                                    EmployeeDeleteRequested(employee.id),
                                  );
                                },
                          backgroundColor: Theme.of(context).colorScheme.error,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onError,
                          icon: Icons.delete_outline,
                          label: 'Delete',
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person_outline),
                      ),
                      title: Text(employee.name),
                      subtitle: Text(
                        '@${employee.username}\n${employee.email}',
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              );
          }
        },
      ),
    );

    return PopScope(
      canPop: !isDeleting,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ExcludeFocus(
            excluding: isDeleting,
            child: AbsorbPointer(absorbing: isDeleting, child: scaffold),
          ),
          if (isDeleting) ...[
            const Positioned.fill(
              child: ModalBarrier(dismissible: false, color: Colors.black45),
            ),
            const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        semanticsLabel: 'Deleting employee',
                      ),
                      SizedBox(height: 16),
                      Text('Deleting employee…'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
