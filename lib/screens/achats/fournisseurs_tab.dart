import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/fournisseur.dart';
import '../../providers/fournisseurs_provider.dart';
import 'fournisseur_form.dart';

class FournisseursTab extends ConsumerWidget {
  const FournisseursTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fournisseursAsync = ref.watch(fournisseursProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Rechercher un fournisseur',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              if (value.length > 2) {
                ref.read(fournisseursProvider.notifier).search(value);
              } else if (value.isEmpty) {
                ref.read(fournisseursProvider.notifier).refresh();
              }
            },
          ),
        ),
        Expanded(
          child: fournisseursAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Erreur: ${err.toString()}')),
            data: (fournisseurs) => _buildFournisseursList(context, ref, fournisseurs),
          ),
        ),
      ],
    );
  }

  Widget _buildFournisseursList(BuildContext context, WidgetRef ref, List<Fournisseur> fournisseurs) {
    if (fournisseurs.isEmpty) {
      return const Center(child: Text('Aucun fournisseur trouvé'));
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(fournisseursProvider.notifier).refresh(),
      child: ListView.builder(
        itemCount: fournisseurs.length,
        itemBuilder: (context, index) {
          final fournisseur = fournisseurs[index];
          return ListTile(
            leading: const Icon(Icons.business),
            title: Text(fournisseur.nom),
            subtitle: Text(fournisseur.telephone),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditForm(context, ref, fournisseur),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDelete(context, ref, fournisseur.id),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditForm(BuildContext context, WidgetRef ref, Fournisseur fournisseur) {
    showDialog(
      context: context,
      builder: (_) => FournisseurForm(initial: fournisseur),
      barrierDismissible: false,
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer suppression'),
        content: const Text('Voulez-vous vraiment supprimer ce fournisseur ?'),
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
      await ref.read(fournisseursProvider.notifier).deleteItem(id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fournisseur supprimé')),
        );
      }
    }
  }
}