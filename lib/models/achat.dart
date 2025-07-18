class Achat {
  final int id;
  final String fournisseur;
  final List<LigneAchat> lignes;
  final DateTime date;
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

  factory Achat.fromJson(Map<String, dynamic> json) {
    try {
      return Achat(
        id: json['id'] as int,
        fournisseur: json['fournisseur'] as String,
        lignes: (json['lignes'] as List)
            .map((e) => LigneAchat.fromJson(e as Map<String, dynamic>))
            .toList(),
        date: DateTime.parse(json['date'] as String),
        total: double.tryParse(json['total']?.toString() ?? '0') ?? 0,
        montantPaye: double.tryParse(json['montant_paye']?.toString() ?? '0') ?? 0,
        statut: AchatStatut.values.firstWhere(
          (e) => e.name == json['statut'],
          orElse: () => AchatStatut.EN_ATTENTE,
        ),
      );
    } catch (e) {
      throw FormatException('Failed to parse Achat: $e');
    }
  }

  Map<String, dynamic> toRequestJson({
    required int fournisseurId,
    required List<LigneAchatRequest> lignesRequest,
  }) {
    return {
      'fournisseur_id': fournisseurId,
      'lignes': lignesRequest.map((e) => e.toJson()).toList(),
      'total': total.toStringAsFixed(2),
      if (montantPaye > 0) 'montant_paye': montantPaye.toStringAsFixed(2),
      if (statut != AchatStatut.EN_ATTENTE) 'statut': statut.name,
    }..removeWhere((key, value) => value == null);
  }
}

enum AchatStatut { EN_ATTENTE, PAYE, PARTIEL, ANNULE }

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

  factory LigneAchat.fromJson(Map<String, dynamic> json) {
    try {
      return LigneAchat(
        id: json['id'] as int,
        produit: json['produit'] as String,
        quantite: double.tryParse(json['quantite']?.toString() ?? '0') ?? 0,
        prixUnitaire: double.tryParse(json['prix_unitaire']?.toString() ?? '0') ?? 0,
        achatId: json['achat'] as int,
      );
    } catch (e) {
      throw FormatException('Failed to parse LigneAchat: $e');
    }
  }
}

class LigneAchatRequest {
  int produitId;
  double quantite;
  double prixUnitaire;
  int achat;

  LigneAchatRequest({
    required this.produitId,
    required this.quantite,
    required this.prixUnitaire,
    required this.achat,
  });

  Map<String, dynamic> toJson() => {
    'produit_id': produitId,
    'quantite': quantite.toStringAsFixed(2),
    'prix_unitaire': prixUnitaire.toStringAsFixed(2),
    'achat': achat,
  };
}