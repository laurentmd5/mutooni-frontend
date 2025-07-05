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
      onItemTap: (i) {
        switch (i) {
          case 0: context.go('/'); break;
          case 1: context.go('/ventes'); break;
          case 2: context.go('/achats'); break;
          case 3: context.go('/clients'); break;
          case 4: context.go('/rh'); break;
          case 5: context.go('/rapports'); break;
          case 6: context.go('/settings'); break;
        }
      },
      title: 'Gestion des Achats',
      actions: [
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
        error: (err, _) => Center(child: Text('Erreur de chargement : $err')),
        data: (achats) => _buildList(context, ref, achats),
      ),
    );
  }

  Widget _buildList(BuildContext context, WidgetRef ref, List<Achat> achats) {
    if (achats.isEmpty) {
      return const Center(child: Text('Aucun achat enregistré'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: achats.length,
      separatorBuilder: (_, __) => const Divider(height: 24),
      itemBuilder: (_, i) {
        final a = achats[i];
        return Card(
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange.shade100,
              child: const Icon(Icons.shopping_bag, color: Colors.orange),
            ),
            title: Text(
              '${a.montant} CFA',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text('${a.date.day}/${a.date.month}/${a.date.year}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => AchatForm(initial: a),
                    barrierDismissible: false,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteAchat(ref, a.id, context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteAchat(
    WidgetRef ref,
    String id,
    BuildContext outerCtx,
  ) async {
    final messenger = ScaffoldMessenger.of(outerCtx); // 🔒 capturé avant await
    
    final confirmed = await showDialog<bool>(
      context: outerCtx,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer suppression'),
        content: const Text('Voulez‑vous vraiment supprimer cet achat ?'),
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
      try {
        await ref.read(achatsProvider.notifier).delete(id);
        messenger.showSnackBar(
          const SnackBar(content: Text('Achat supprimé avec succès')),
        );
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    }
  }
}