import 'package:employee_book/core/presentation/widgets/appbar.dart';
import 'package:employee_book/core/presentation/widgets/error.dart';
import 'package:employee_book/features/employees/domain/validation/employee_validation.dart';
import 'package:employee_book/features/employees/domain/validation/employee_validation_messages.dart';
import 'package:employee_book/features/employees/presentation/bloc/edit_employee/edit_employee_bloc.dart';
import 'package:employee_book/features/employees/presentation/bloc/edit_employee/edit_employee_event.dart';
import 'package:employee_book/features/employees/presentation/bloc/edit_employee/edit_employee_state.dart';
import 'package:employee_book/features/employees/presentation/widgets/text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class EditEmployeePage extends StatelessWidget {
  const EditEmployeePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditEmployeeBloc, EditEmployeeState>(
      listenWhen: (previous, current) {
        return previous.status != current.status;
      },
      listener: (context, state) {
        if (state.status == EditEmployeeStatus.success) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Employee updated successfully')),
            );
          context.pop(true);
        } else if (state.status == EditEmployeeStatus.saveFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('Could not save changes. Please try again.'),
              ),
            );
        }
      },
      builder: (context, state) {
        return PopScope(
          canPop: !state.isSubmitting,
          child: Scaffold(
            appBar: KAppBar(
              titleText: 'Edit Employee',
              canGoBack: !state.isSubmitting,
            ),
            body: _buildBody(context, state),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, EditEmployeeState state) {
    switch (state.status) {
      case EditEmployeeStatus.initial:
      case EditEmployeeStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case EditEmployeeStatus.loadFailure:
        return FailureWidget(
          errMessage: 'Could not load employee. Please try again.',
          onButtonTap: () {
            context.read<EditEmployeeBloc>().add(const EditEmployeeRequested());
          },
        );
      case EditEmployeeStatus.notFound:
        return FailureWidget(
          errMessage: 'This employee no longer exists.',
          buttonTitle: 'Back to employees',
          onButtonTap: () => context.pop(true),
        );
      case EditEmployeeStatus.editing:
      case EditEmployeeStatus.submitting:
      case EditEmployeeStatus.success:
      case EditEmployeeStatus.saveFailure:
        return _buildForm(context, state);
    }
  }

  Widget _buildForm(BuildContext context, EditEmployeeState state) {
    final bloc = context.read<EditEmployeeBloc>();
    final errors = state.errors;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: AutofillGroup(
        child: Column(
          children: [
            KTextField(
              hintText: 'Username',
              initialValue: state.input.username,
              enabled: state.canEdit,
              errorText: errors[EmployeeField.username]?.message,
              onChanged: (value) {
                bloc.add(
                  EditEmployeeFieldChanged(EmployeeField.username, value),
                );
              },
            ),
            const SizedBox(height: 12),
            KTextField(
              hintText: 'First Name',
              initialValue: state.input.firstName,
              enabled: state.canEdit,
              autofillHints: const [AutofillHints.givenName],
              errorText: errors[EmployeeField.firstName]?.message,
              onChanged: (value) {
                bloc.add(
                  EditEmployeeFieldChanged(EmployeeField.firstName, value),
                );
              },
            ),
            const SizedBox(height: 12),
            KTextField(
              hintText: 'Last Name',
              initialValue: state.input.lastName,
              enabled: state.canEdit,
              autofillHints: const [AutofillHints.familyName],
              errorText: errors[EmployeeField.lastName]?.message,
              onChanged: (value) {
                bloc.add(
                  EditEmployeeFieldChanged(EmployeeField.lastName, value),
                );
              },
            ),
            const SizedBox(height: 12),
            KTextField(
              hintText: 'Email',
              initialValue: state.input.email,
              enabled: state.canEdit,
              autofillHints: const [AutofillHints.email],
              textInputAction: TextInputAction.done,
              errorText: errors[EmployeeField.email]?.message,
              onChanged: (value) {
                bloc.add(EditEmployeeFieldChanged(EmployeeField.email, value));
              },
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                key: const ValueKey('edit_employee_button'),
                onPressed: state.canEdit
                    ? () {
                        FocusScope.of(context).unfocus();
                        bloc.add(const EditEmployeeSubmitted());
                      }
                    : null,
                child: state.isSubmitting
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.onPrimary,
                              semanticsLabel: 'Saving changes',
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text('Saving…'),
                        ],
                      )
                    : const Text('Save changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
