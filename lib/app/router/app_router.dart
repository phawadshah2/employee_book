import 'package:employee_book/features/employee/presentation/add_employee_page.dart';
import 'package:employee_book/features/employee/presentation/employee_list_page.dart';
import 'package:go_router/go_router.dart';

abstract final class AppRouter {
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
              path: '/add',
              name: 'add',
              builder: (_, _) => const AddEmployeePage(),
            ),
          ],
        ),
      ],
    );
    return router;
  }
}
