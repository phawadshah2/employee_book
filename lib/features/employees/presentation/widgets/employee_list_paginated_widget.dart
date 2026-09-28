import 'package:employee_book/core/presentation/theme/theme_context_extension.dart';
import 'package:employee_book/core/presentation/widgets/empty.dart';
import 'package:employee_book/features/employees/presentation/bloc/employee_list/employee_list_bloc.dart';
import 'package:employee_book/features/employees/presentation/bloc/employee_list/employee_list_event.dart';
import 'package:employee_book/features/employees/presentation/bloc/employee_list/employee_list_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class EmployeePaginatedWidget extends StatefulWidget {
  const EmployeePaginatedWidget({
    required this.state,
    super.key,
    this.onPageEndReached,
  });

  final EmployeeListState state;
  final void Function()? onPageEndReached;

  @override
  State<EmployeePaginatedWidget> createState() =>
      _EmployeePaginatedWidgetState();
}

class _EmployeePaginatedWidgetState extends State<EmployeePaginatedWidget> {
  final _scrollController = ScrollController();
  int? _requestedCursor;
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (!position.hasContentDimensions) return;
    if (position.extentAfter <= 300) {
      _requestNextPage();
    }
  }

  void _requestNextPage() {
    final state = widget.state;
    final cursor = state.nextCursor;
    final callback = widget.onPageEndReached;

    if (callback == null ||
        state.status != EmployeeListStatus.success ||
        cursor == null ||
        state.isLoadingMore ||
        state.isDeleting) {
      return;
    }
    if (_requestedCursor == cursor) return;
    _requestedCursor = cursor;
    callback();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    if (state.employees.isEmpty && !state.hasMore) {
      return const EmptyWidget(
        message: 'No employees yet. Tap Add Employee to get started.',
      );
    }
    final actionsEnabled = !state.isDeleting && !state.isLoadingMore;
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      itemCount: state.employees.length + 1,
      itemBuilder: (context, index) {
        if (index == state.employees.length) {
          return _buildFooter();
        }
        final employee = state.employees[index];
        return Slidable(
          key: ValueKey(employee.id),
          enabled: actionsEnabled,
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            extentRatio: 0.28,
            children: [
              SlidableAction(
                onPressed: actionsEnabled
                    ? (_) {
                        context.read<EmployeeListBloc>().add(
                          EmployeeDeleteRequested(employee.id),
                        );
                      }
                    : null,
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
                icon: Icons.delete_outline,
                label: 'Delete',
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: context.colors.secondary),
              borderRadius: BorderRadius.circular(6),
            ),

            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person_outline)),
              title: Text(employee.name),
              subtitle: Text(
                'ID:${employee.id}\n@${employee.username}\n${employee.email}',
              ),
              isThreeLine: true,
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    final state = widget.state;
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              semanticsLabel: 'Loading more employees',
            ),
          ),
        ),
      );
    }
    if (!state.hasMore) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: Text('All employees loaded')),
      );
    }
    return const SizedBox();
  }
}
