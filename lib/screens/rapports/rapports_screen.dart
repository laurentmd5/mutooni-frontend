import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mutooni_frontend/widgets/main_layout.dart';
import 'package:mutooni_frontend/providers/rapports_provider.dart';
import 'package:mutooni_frontend/models/rapport.dart';
import 'package:go_router/go_router.dart';


class RapportsScreen extends ConsumerWidget {
  const RapportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rapports = ref.watch(rapportsProvider);
    final selectedIndex = 6; // Rapports est à l'index 5

    return MainLayout(
      selectedIndex: selectedIndex,
      onItemTap: (i) => _navigate(context, i),
      title: 'Rapports Financiers',
      child: rapports.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erreur: $err')),
        data: (rapports) => ListView.separated(
          itemCount: rapports.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (_, i) {
            final r = rapports[i];
            return ListTile(
              title: Text(r.titre),
              subtitle: Text('Créé le ${r.dateCreation.day}/${r.dateCreation.month}/${r.dateCreation.year}'),
              trailing: const Icon(Icons.download),
              onTap: () => _showReport(context, r),
            );
          },
        ),
      ),
    );
  }

  void _showReport(BuildContext context, Rapport rapport) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(rapport.titre),
        content: SingleChildScrollView(
          child: Text(rapport.contenu),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, int index) {
  final routes = ['/', '/ventes', '/achats', '/produits', '/clients', '/rh', '/rapports', '/transactions', '/settings'];
  if (index < routes.length) context.go(routes[index]);
  }
}