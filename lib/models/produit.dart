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
      seuilMin: json['seuil_min'],
      stockActuel: json['stock_actuel'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'categorie': categorie.toJson(),
        'nom': nom,
        'unite': unite,
        'prix_unitaire': prixUnitaire,
        'seuil_min': seuilMin,
        'stock_actuel': stockActuel,
      };
}