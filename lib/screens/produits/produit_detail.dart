import 'package:flutter/material.dart';
import 'package:mutooni_frontend/models/produit.dart';

class ProduitDetail extends StatelessWidget {
  final Produit produit;
  const ProduitDetail({super.key, required this.produit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(produit.nom)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Catégorie : ${produit.categorie.nom}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Unité : ${produit.unite}'),
            Text('Prix unitaire : ${produit.prixUnitaire} F'),
            Text('Stock actuel : ${produit.stockActuel} ${produit.unite}'),
            Text('Seuil minimum : ${produit.seuilMin}'),
          ],
        ),
      ),
    );
  }
}
