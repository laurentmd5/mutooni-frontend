// lib/screens/produits/produits_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mutooni_frontend/providers/produits_provider.dart';
import 'package:mutooni_frontend/screens/produits/produit_detail.dart';
import 'package:mutooni_frontend/widgets/main_layout.dart';
import 'package:go_router/go_router.dart';

class ProduitsScreen extends ConsumerWidget {
  const ProduitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final produitsAsync = ref.watch(produitsProvider);

    return MainLayout(
      selectedIndex: 3,
      onItemTap: (i) => _navigate(context, i),
      title: 'Produits',
      child: produitsAsync.when(
        data: (produits) => ListView.builder(
          itemCount: produits.length,
          itemBuilder: (context, index) {
            final produit = produits[index];
            return ListTile(
              title: Text(produit.nom),
              subtitle: Text('Stock: ${produit.stockActuel} ${produit.unite}'),
              trailing: Text('${produit.prixUnitaire} F'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProduitDetail(produit: produit),
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erreur: $e')),
      ),
    );
  }
  void _navigate(BuildContext context, int index) {
  final routes = ['/', '/ventes', '/achats', '/produits', '/clients', '/rh', '/rapports', '/transactions', '/settings'];
  if (index < routes.length) context.go(routes[index]);
  }
}