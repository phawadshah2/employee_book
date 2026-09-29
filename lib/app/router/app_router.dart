import 'package:employee_book/features/employees/domain/usecases/add_employee.dart';
import 'package:employee_book/features/employees/domain/usecases/delete_employee.dart';
import 'package:employee_book/features/employees/domain/usecases/employee_list.dart';
import 'package:employee_book/features/employees/domain/usecases/get_employee.dart';
import 'package:employee_book/features/employees/domain/usecases/update_employee.dart';
import 'package:employee_book/features/employees/presentation/add_employee_page.dart';
import 'package:employee_book/features/employees/presentation/bloc/add_employee/add_employee_bloc.dart';
import 'package:employee_book/features/employees/presentation/bloc/edit_employee/edit_employee_bloc.dart';
import 'package:employee_book/features/employees/presentation/bloc/edit_employee/edit_employee_event.dart';
import 'package:employee_book/features/employees/presentation/bloc/employee_list/employee_list_bloc.dart';
import 'package:employee_book/features/employees/presentation/bloc/employee_list/employee_list_event.dart';
import 'package:employee_book/features/employees/presentation/edit_employee_page.dart';
import 'package:employee_book/features/employees/presentation/employee_list_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

abstract final class AppRouter {
  static final GetIt getIt = GetIt.instance;
  static GoRouter createRouter() {
    final router = GoRouter(
      initialLocation: '/employees',
      routes: [
        GoRoute(
          path: '/employees',
          name: 'employees',
          builder: (_, _) {
            return BlocProvider(
              create: (_) => EmployeeListBloc(
                employeeList: getIt<EmployeeList>(),
                deleteEmployee: getIt<DeleteEmployee>(),
              )..add(const EmployeeListRequested()),
              child: const EmployeeListPage(),
            );
          },
          routes: [
            GoRoute(
              path: 'add',
              name: 'addEmployee',
              builder: (_, _) {
                return BlocProvider(
                  create: (_) => AddEmployeeBloc(getIt<AddEmployee>()),
                  child: const AddEmployeePage(),
                );
              },
            ),
            GoRoute(
              path: ':id/edit',
              name: 'editEmployee',
              builder: (context, state) {
                final employeeId = int.tryParse(
                  state.pathParameters['id'] ?? '',
                );
                return BlocProvider(
                  create: (_) => EditEmployeeBloc(
                    employeeId: employeeId ?? 0,
                    getEmployee: getIt<GetEmployee>(),
                    updateEmployee: getIt<UpdateEmployee>(),
                  )..add(const EditEmployeeRequested()),
                  child: const EditEmployeePage(),
                );
              },
            ),
          ],
        ),
      ],
    );
    return router;
  }
}
