import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class KAppBar extends StatelessWidget implements PreferredSizeWidget {
  const KAppBar({super.key, this.titleText, this.canGoBack = true});

  final String? titleText;
  final bool canGoBack;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: titleText != null ? Text(titleText!) : null,
      leading: IconButton(
        onPressed: canGoBack ? () => context.pop() : null,
        icon: const Icon(Icons.arrow_back_ios_new),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
