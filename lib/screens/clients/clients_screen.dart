import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mutooni_frontend/widgets/main_layout.dart';
import 'package:mutooni_frontend/providers/client_provider.dart';
import 'client_form.dart';
import 'package:go_router/go_router.dart';

class ClientsScreen extends ConsumerWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clients = ref.watch(clientProvider);
    final selectedIndex = 4;

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
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (c.email != null) Text(c.email!),
                  Text(
                    'Solde: ${c.solde} CFA',
                    style: TextStyle(
                      color: double.tryParse(c.solde) != null && double.parse(c.solde) < 0
                          ? Colors.red
                          : Colors.black,
                    ),
                  ),
                ],
              ),
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
  final routes = ['/', '/ventes', '/achats', '/produits', '/clients', '/rh', '/rapports', '/transactions', '/settings'];
  if (index < routes.length) context.go(routes[index]);
  }
}