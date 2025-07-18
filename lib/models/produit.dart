import '../../models/categorie_produit.dart';

class Produit {
  final int id;
  final CategorieProduit categorie;
  final String nom;
  final String unite;
  final String prixUnitaire;
  final int seuilMin;
  final int stockActuel;

  Produit({
    required this.id,
    required this.categorie,
    required this.nom,
    required this.unite,
    required this.prixUnitaire,
    required this.seuilMin,
    required this.stockActuel,
  });

  factory Produit.fromJson(Map<String, dynamic> json) {
    return Produit(
      id: json['id'],
      categorie: CategorieProduit.fromJson(json['categorie']),
      nom: json['nom'],
      unite: json['unite'],
      prixUnitaire: json['prix_unitaire'],
      seuilMin: json['seuil_min'] ?? 0,
      stockActuel: json['stock_actuel'] ?? 0,
    );
  }

  String get formattedPrice => double.tryParse(prixUnitaire)?.toStringAsFixed(2) ?? '0.00';
  bool get stockLow => stockActuel < seuilMin;
}