import 'package:employee_book/features/employee/domain/usecases/add_employee.dart';
import 'package:employee_book/features/employee/presentation/add_employee_page.dart';
import 'package:employee_book/features/employee/presentation/bloc/add_employee/add_employee_bloc.dart';
import 'package:employee_book/features/employee/presentation/employee_list_page.dart';
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
          builder: (_, _) => const EmployeeListPage(),
          routes: [
            GoRoute(
              path: 'add',
              name: 'add',
              builder: (_, _) {
                return BlocProvider(
                  create: (_) => AddEmployeeBloc(getIt<AddEmployee>()),
                  child: const AddEmployeePage(),
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
