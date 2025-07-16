// ignore_for_file: unnecessary_this
/// Modèle conforme au schéma *Achat* de l’API Mutooni.
class Achat {
  final int id;
  final String fournisseur;          // lecture seule
  final List<LigneAchat> lignes;     // lecture seule côté API
  final DateTime date;               // lecture seule
  final double total;
  final double montantPaye;
  final AchatStatut statut;

  Achat({
    required this.id,
    required this.fournisseur,
    required this.lignes,
    required this.date,
    required this.total,
    required this.montantPaye,
    required this.statut,
  });

  /// Désérialisation depuis le JSON renvoyé par l’API
  factory Achat.fromJson(Map<String, dynamic> json) => Achat(
        id: json['id'] as int,
        fournisseur: json['fournisseur'] as String,
        lignes: (json['lignes'] as List)
            .map((e) => LigneAchat.fromJson(e as Map<String, dynamic>))
            .toList(),
        date: DateTime.parse(json['date'] as String),
        total: double.parse(json['total'] as String),
        montantPaye: double.parse(json['montant_paye'] as String),
        statut: AchatStatut.values.byName(json['statut'] as String),
      );

  /// Corps attendu par **POST /achats/**
  /// – Les champs lecture-seule (id, date, fournisseur, lignes) ne sont pas envoyés
  Map<String, dynamic> toRequestJson({
    required int fournisseurId,
    required List<LigneAchatRequest> lignesRequest,
  }) =>
      {
        'fournisseur_id': fournisseurId,
        'lignes': lignesRequest.map((e) => e.toJson()).toList(),
        'total': total.toStringAsFixed(2),
        if (montantPaye > 0) 'montant_paye': montantPaye.toStringAsFixed(2),
        if (statut != AchatStatut.EN_ATTENTE) 'statut': statut.name,
      };
}

/// Enum conforme à *AchatStatutEnum*
enum AchatStatut { EN_ATTENTE, PAYE, PARTIEL, ANNULE }

/// Ligne d’achat retournée par l’API
class LigneAchat {
  final int id;
  final String produit;
  final double quantite;
  final double prixUnitaire;
  final int achatId;

  LigneAchat({
    required this.id,
    required this.produit,
    required this.quantite,
    required this.prixUnitaire,
    required this.achatId,
  });

  factory LigneAchat.fromJson(Map<String, dynamic> json) => LigneAchat(
        id: json['id'] as int,
        produit: json['produit'] as String,
        quantite: double.parse(json['quantite'] as String),
        prixUnitaire: double.parse(json['prix_unitaire'] as String),
        achatId: json['achat'] as int,
      );
}

/// Ligne d’achat *à envoyer* lors d’une création / mise-à-jour
class LigneAchatRequest {
  final int produitId;
  final double quantite;
  final double prixUnitaire;

  LigneAchatRequest({
    required this.produitId,
    required this.quantite,
    required this.prixUnitaire,
  });

  Map<String, dynamic> toJson() => {
        'produit_id': produitId,
        'quantite': quantite.toStringAsFixed(2),
        'prix_unitaire': prixUnitaire.toStringAsFixed(2),
      };
}
