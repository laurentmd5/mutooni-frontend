import 'package:flutter/material.dart';
import 'package:mutooni_frontend/models/produit.dart';

class ProduitDetail extends StatelessWidget {
  final Produit produit;
  const ProduitDetail({super.key, required this.produit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(produit.nom),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editProduit(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Catégorie', produit.categorie.nom),
            _buildDetailRow('Unité', produit.unite),
            _buildDetailRow('Prix unitaire', '${produit.formattedPrice} F'),
            _buildDetailRow(
              'Stock actuel', 
              '${produit.stockActuel} ${produit.unite}',
              style: produit.stockLow 
                  ? const TextStyle(color: Colors.red)
                  : null,
            ),
            _buildDetailRow('Seuil minimum', '${produit.seuilMin} ${produit.unite}'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {TextStyle? style}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text('$label : ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, style: style)),
        ],
      ),
    );
  }

  void _editProduit(BuildContext context) {
    // TODO: Implémenter l'édition
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité d\'édition à implémenter')),
    );
  }
}