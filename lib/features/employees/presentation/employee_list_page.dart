import 'package:employee_book/core/presentation/widgets/error.dart';
import 'package:employee_book/features/employees/presentation/bloc/employee_list/employee_list_bloc.dart';
import 'package:employee_book/features/employees/presentation/bloc/employee_list/employee_list_event.dart';
import 'package:employee_book/features/employees/presentation/bloc/employee_list/employee_list_state.dart';
import 'package:employee_book/features/employees/presentation/widgets/employee_list_paginated_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class EmployeeListPage extends StatelessWidget {
  const EmployeeListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EmployeeListBloc, EmployeeListState>(
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
        final scaffold = Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('Employees'),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              await context.push<bool>('/employees/add');
              if (!context.mounted) return;
              context.read<EmployeeListBloc>().add(
                const EmployeeListRequested(),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Employee'),
          ),
          body: _buildBody(context, state),
        );
        return PopScope(
          canPop: !state.isDeleting,
          child: Stack(
            children: [
              ExcludeFocus(
                excluding: state.isDeleting,
                child: AbsorbPointer(
                  absorbing: state.isDeleting,
                  child: scaffold,
                ),
              ),
              if (state.isDeleting) ...[
                const Positioned.fill(
                  child: ModalBarrier(
                    dismissible: false,
                    color: Colors.black45,
                  ),
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
      },
    );
  }

  Widget _buildBody(BuildContext context, EmployeeListState state) {
    switch (state.status) {
      case EmployeeListStatus.initial:
      case EmployeeListStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case EmployeeListStatus.failure:
        return FailureWidget(
          errMessage: 'Could not load employees. Please try again.',
          onButtonTap: () {
            context.read<EmployeeListBloc>().add(const EmployeeListRequested());
          },
        );
      case EmployeeListStatus.success:
        return EmployeePaginatedWidget(
          state: state,
          onPageEndReached: () {
            context.read<EmployeeListBloc>().add(
              const EmployeeListNextPageRequested(),
            );
          },
        );
    }
  }
}
