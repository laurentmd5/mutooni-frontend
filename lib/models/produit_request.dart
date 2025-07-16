class ProduitRequest {
  final int categorieId;
  final String nom;
  final String unite;
  final String prixUnitaire;
  final int? seuilMin;
  final int? stockActuel;

  ProduitRequest({
    required this.categorieId,
    required this.nom,
    required this.unite,
    required this.prixUnitaire,
    this.seuilMin,
    this.stockActuel,
  });

  Map<String, dynamic> toJson() => {
        'categorie_id': categorieId,
        'nom': nom,
        'unite': unite,
        'prix_unitaire': prixUnitaire,
        if (seuilMin != null) 'seuil_min': seuilMin,
        if (stockActuel != null) 'stock_actuel': stockActuel,
      };
}