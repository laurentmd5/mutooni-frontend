import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mutooni_frontend/widgets/main_layout.dart';
import 'package:mutooni_frontend/providers/client_provider.dart';
//import 'package:mutooni_frontend/models/client.dart';
import 'client_form.dart';
import 'package:go_router/go_router.dart';


class ClientsScreen extends ConsumerWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clients = ref.watch(clientProvider);
    final selectedIndex = 3; // Clients est à l'index 3

    return MainLayout(
      selectedIndex: selectedIndex,
      onItemTap: (i) => _navigate(context, i),
      title: 'Gestion des Clients',
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => showDialog(
            context: context,
            builder: (_) => const ClientForm(),
          ),
        ),
      ],
      child: clients.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erreur: $err')),
        data: (clients) => ListView.separated(
          itemCount: clients.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (_, i) {
            final c = clients[i];
            return ListTile(
              title: Text(c.nom),
              subtitle: Text(c.email),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => ClientForm(initial: c),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => ref.read(clientProvider.notifier).delete(c.id),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _navigate(BuildContext context, int index) {
    final routes = ['/', '/ventes', '/achats', '/rh', '/rapports', '/settings'];
    context.go(routes[index]);
  }
}