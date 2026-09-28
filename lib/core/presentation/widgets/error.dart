import 'package:flutter/material.dart';

class FailureWidget extends StatelessWidget {
  const FailureWidget({required this.errMessage, super.key, this.onRetry});

  final String errMessage;
  final void Function()? onRetry;

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
            if (onRetry != null)
              FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
