import 'package:flutter/material.dart';

class KTextField extends StatelessWidget {
  const KTextField({
    super.key,
    this.hintText,
    this.initialValue,
    this.errorText,
    this.enabled = true,
    this.autoCorrect = false,
    this.autofillHints,
    this.textInputAction = TextInputAction.next,
    this.textEditingController,
    this.onChanged,
  });
  final String? hintText;
  final String? initialValue;
  final String? errorText;
  final bool enabled;
  final bool autoCorrect;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final TextEditingController? textEditingController;
  final void Function(String value)? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey(hintText),
      controller: textEditingController,
      initialValue: initialValue,
      enabled: enabled,
      autocorrect: autoCorrect,
      textCapitalization: TextCapitalization.words,
      autofillHints: autofillHints,
      textInputAction: textInputAction,
      onChanged: onChanged,
      decoration: InputDecoration(labelText: hintText, errorText: errorText),
    );
  }
}
