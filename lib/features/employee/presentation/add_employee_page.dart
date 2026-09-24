import 'dart:developer';
import 'package:employee_book/features/employee/domain/validation/employee_validation.dart';
import 'package:employee_book/features/employee/domain/validation/employee_validation_messages.dart';
import 'package:employee_book/features/employee/presentation/bloc/add_employee/add_employee_bloc.dart';
import 'package:employee_book/features/employee/presentation/bloc/add_employee/add_employee_event.dart';
import 'package:employee_book/features/employee/presentation/bloc/add_employee/add_employee_state.dart';
import 'package:employee_book/features/employee/presentation/widgets/text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AddEmployeePage extends StatelessWidget {
  const AddEmployeePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddEmployeeBloc, AddEmployeeState>(
      listenWhen: (previous, current) {
        return previous.status != current.status;
      },
      listener: (context, state) {
        log(state.toString());
        switch (state.status) {
          case AddEmployeeStatus.success:
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(content: Text('Added successfully')),
              );
            context.pop();
          case AddEmployeeStatus.failure:
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text('Could not add employee. Please try again.'),
                ),
              );
          case AddEmployeeStatus.editing:
          case AddEmployeeStatus.submitting:
            break;
        }
      },

      builder: (context, state) {
        final bloc = context.read<AddEmployeeBloc>();
        final errors = state.visibleErrors;
        void submit() {
          if (state.isLocked) return;
          FocusScope.of(context).unfocus();
          bloc.add(const AddEmployeeSubmitted());
        }

        return PopScope(
          canPop: !state.isSubmitting,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Add Employee'),
              leading: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios_new),
              ),
            ),

            body: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: AutofillGroup(
                child: Column(
                  children: [
                    KTextField(
                      hintText: 'Username',
                      initialValue: state.input.username,
                      enabled: !state.isLocked,
                      autofillHints: const [AutofillHints.newUsername],
                      errorText: errors[EmployeeField.username]?.message,
                      onChanged: (value) {
                        bloc.add(
                          EmployeeFieldChanged(EmployeeField.username, value),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    KTextField(
                      hintText: 'First Name',
                      initialValue: state.input.firstName,
                      enabled: !state.isLocked,
                      autofillHints: const [AutofillHints.givenName],
                      errorText: errors[EmployeeField.firstName]?.message,
                      onChanged: (value) {
                        bloc.add(
                          EmployeeFieldChanged(EmployeeField.firstName, value),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    KTextField(
                      hintText: 'Last Name',
                      initialValue: state.input.lastName,
                      enabled: !state.isLocked,
                      autofillHints: const [AutofillHints.familyName],
                      errorText: errors[EmployeeField.lastName]?.message,
                      onChanged: (value) {
                        bloc.add(
                          EmployeeFieldChanged(EmployeeField.lastName, value),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    KTextField(
                      hintText: 'Email',
                      initialValue: state.input.email,
                      enabled: !state.isLocked,
                      autofillHints: const [AutofillHints.email],
                      errorText: errors[EmployeeField.email]?.message,
                      onChanged: (value) {
                        bloc.add(
                          EmployeeFieldChanged(EmployeeField.email, value),
                        );
                      },
                    ),
                    const SizedBox(height: 36),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        key: const ValueKey('add_employee_button'),
                        onPressed: state.isLocked ? null : submit,
                        child: state.isSubmitting
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                      semanticsLabel: 'Saving employee',
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text('Adding employee…'),
                                ],
                              )
                            : const Text('Add employee'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
