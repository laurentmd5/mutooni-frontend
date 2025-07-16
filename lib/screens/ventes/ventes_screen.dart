import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/main_layout.dart';
import '../../providers/ventes_provider.dart';
import 'vente_form.dart';

class VentesScreen extends ConsumerWidget {
  const VentesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ventes = ref.watch(ventesProvider);
    final selectedIndex = 1;

    return MainLayout(
      selectedIndex: selectedIndex,
      onItemTap: (i) => _navigate(context, i),
      title: 'Gestion des Ventes',
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => showDialog(
            context: context,
            builder: (_) => const VenteForm(),
            barrierDismissible: false,
          ),
        ),
      ],
      child: ventes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erreur: $err')),
        data: (ventes) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: ventes.length,
          separatorBuilder: (_, __) => const Divider(height: 24),
          itemBuilder: (_, i) {
            final v = ventes[i];
            return Card(
              elevation: 2,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                leading: CircleAvatar(
                  backgroundColor: Colors.green.shade100,
                  child: const Icon(Icons.point_of_sale, color: Colors.green),
                ),
                title: Text(
                  '${v.total} CFA',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${v.date.day}/${v.date.month}/${v.date.year}'),
                    Text('Client: ${v.client}')
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => VenteForm(initial: v),
                        barrierDismissible: false,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteVente(ref, v.id),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _navigate(BuildContext context, int index) {
    final routes = ['/', '/achats', '/clients', '/rh', '/rapports', '/settings'];
    if (index < routes.length) context.go(routes[index]);
  }

  Future<void> _deleteVente(WidgetRef ref, int id) async {
    final confirmed = await showDialog<bool>(
      context: ref.context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer suppression'),
        content: const Text('Voulez-vous vraiment supprimer cette vente?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(ventesProvider.notifier).delete(id);
    }
  }
}
