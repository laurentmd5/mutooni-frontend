import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/achat.dart';
import '../../providers/achats_provider.dart';
import '../../widgets/main_layout.dart';
import 'achat_form.dart';

class AchatsScreen extends ConsumerWidget {
  const AchatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achatsAsync = ref.watch(achatsProvider);

    return MainLayout(
      selectedIndex: 2,
      onItemTap: (i) => _nav(context, i),
      title: 'Gestion des Achats',
      actions: [
        PopupMenuButton<AchatStatut>(
          tooltip: 'Filtrer par statut',
          icon: const Icon(Icons.filter_alt),
          onSelected: (s) =>
              ref.read(achatsProvider.notifier).filterByStatut(s),
          itemBuilder: (_) => AchatStatut.values
              .map((e) => PopupMenuItem(value: e, child: Text(e.name)))
              .toList()
            ..insert(
              0,
              const PopupMenuItem(
                value: AchatStatut.EN_ATTENTE,
                child: Text('Tous les statuts'),
              ),
            ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: 'Nouvel achat',
          onPressed: () => showDialog(
            context: context,
            builder: (_) => const AchatForm(),
            barrierDismissible: false,
          ),
        ),
      ],
      child: achatsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erreur : $err')),
        data: (achats) => _list(context, ref, achats),
      ),
    );
  }

  /* ───────── ListView ───────── */
  Widget _list(
      BuildContext context, WidgetRef ref, List<Achat> achats) {
    if (achats.isEmpty) {
      return const Center(child: Text('Aucun achat trouvé'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: achats.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (_, i) {
        final a = achats[i];
        final date = '${a.date.day}/${a.date.month}/${a.date.year}';
        return ListTile(
          leading: const Icon(Icons.shopping_bag, color: Colors.orange),
          title: Text('${a.total.toStringAsFixed(2)} CFA'),
          subtitle: Text('Fournisseur: ${a.fournisseur}\n$date'),
          trailing: Wrap(
            spacing: 8,
            children: [
              Chip(
                label: Text(a.statut.name),
                backgroundColor:
                    a.statut == AchatStatut.PAYE ? Colors.green[100] : null,
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _delete(context, ref, a.id),
              ),
            ],
          ),
        );
      },
    );
  }

  /* ───────── Helpers ───────── */

  Future<void> _delete(
      BuildContext context, WidgetRef ref, int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer cet achat ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(achatsProvider.notifier).delete(id);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Achat supprimé')));
      }
    }
  }

  void _nav(BuildContext ctx, int i) {
    const routes = ['/', '/ventes', '/achats', '/clients', '/rh', '/rapports', '/settings'];
    ctx.go(routes[i]);
  }
}
