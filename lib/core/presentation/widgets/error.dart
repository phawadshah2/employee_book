import 'package:flutter/material.dart';

class FailureWidget extends StatelessWidget {
  const FailureWidget({
    required this.errMessage,
    super.key,
    this.buttonTitle,
    this.onButtonTap,
  });

  final String errMessage;
  final String? buttonTitle;
  final void Function()? onButtonTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(errMessage, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            if (onButtonTap != null)
              FilledButton(
                onPressed: onButtonTap,
                child: Text(buttonTitle ?? 'Retry'),
              ),
          ],
        ),
      ),
    );
  }
}
