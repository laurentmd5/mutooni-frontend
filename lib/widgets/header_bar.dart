import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class HeaderBar extends ConsumerWidget implements PreferredSizeWidget {
  const HeaderBar({super.key, required this.title, this.actions});

  final String title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final actionState = ref.watch(authControllerProvider);

    return AppBar(
      elevation: 0,
      title: Text(title),
      actions: [
        if (actions != null) ...actions!,
        if (user != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(child: Text(user.email ?? '', style: const TextStyle(fontSize: 14))),
          ),
        if (user != null)
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: actionState.isLoading ? null : () => ref.read(authControllerProvider.notifier).signOut(),
            tooltip: 'Déconnexion',
          ),
      ],
    );
  }
}