import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mutooni_frontend/providers/produits_provider.dart';
import 'package:mutooni_frontend/screens/produits/produit_detail.dart';
import 'package:mutooni_frontend/screens/produits/produit_form.dart';
import 'package:mutooni_frontend/widgets/main_layout.dart';
import 'package:go_router/go_router.dart';

class ProduitsScreen extends ConsumerStatefulWidget {
  const ProduitsScreen({super.key});

  @override
  ConsumerState<ProduitsScreen> createState() => _ProduitsScreenState();
}

class _ProduitsScreenState extends ConsumerState<ProduitsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final produitsAsync = ref.watch(produitsProvider);

    return MainLayout(
      selectedIndex: 3,
      onItemTap: (i) => _navigate(context, i),
      title: 'Produits',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => ref.invalidate(produitsProvider),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => showDialog(
            context: context,
            builder: (_) => const ProduitForm(),
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
                    ref.read(produitsProvider.notifier).searchProduits('');
                  },
                ),
              ),
              onChanged: (query) {
                ref.read(produitsProvider.notifier).searchProduits(query);
              },
            ),
          ),
          Expanded(
            child: produitsAsync.when(
              data: (produits) => ListView.builder(
                itemCount: produits.length,
                itemBuilder: (context, index) {
                  final produit = produits[index];
                  return ListTile(
                    title: Text(produit.nom),
                    subtitle: Text(
                      'Stock: ${produit.stockActuel} ${produit.unite}',
                      style: produit.stockLow
                          ? const TextStyle(color: Colors.red)
                          : null,
                    ),
                    trailing: Text('${produit.formattedPrice} F'),
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
              error: (e, _) => Center(child: Text('Erreur: ${e.toString()}')),
            ),
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