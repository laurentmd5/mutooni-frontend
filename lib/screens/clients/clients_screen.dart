import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mutooni_frontend/widgets/main_layout.dart';
import 'package:mutooni_frontend/providers/client_provider.dart';
import 'client_form.dart';
import 'package:go_router/go_router.dart';
import 'dart:async'; 

class ClientsScreen extends ConsumerStatefulWidget {
  const ClientsScreen({super.key});

  @override
  ConsumerState<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends ConsumerState<ClientsScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clients = ref.watch(clientProvider);
    final selectedIndex = 4;

    return MainLayout(
      selectedIndex: selectedIndex,
      onItemTap: (i) => _navigate(context, i),
      title: 'Gestion des Clients',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => ref.invalidate(clientProvider),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => showDialog(
            context: context,
            builder: (_) => const ClientForm(),
          ),
        ),
      ],
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Rechercher',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(clientProvider.notifier).search('');
                  },
                ),
              ),
              onChanged: (query) {
                _searchDebounce?.cancel();
                _searchDebounce = Timer(const Duration(milliseconds: 500), () {
                  ref.read(clientProvider.notifier).search(query);
                });
              },
            ),
          ),
          Expanded(
            child: clients.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Erreur: $err')),
              data: (clients) => clients.isEmpty
                  ? const Center(child: Text('Aucun client trouvé'))
                  : ListView.separated(
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
                              if (c.telephone != null) Text(c.telephone!),
                              Text(
                                'Solde: ${c.formattedSolde} CFA',
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
                                onPressed: () => _confirmDelete(c.id, context),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(int id, BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment supprimer ce client?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(clientProvider.notifier).delete(id, context);
    }
  }

  void _navigate(BuildContext context, int index) {
    final routes = ['/', '/ventes', '/achats', '/produits', '/clients', '/rh', '/rapports', '/transactions', '/settings'];
    if (index < routes.length) context.go(routes[index]);
  }
}