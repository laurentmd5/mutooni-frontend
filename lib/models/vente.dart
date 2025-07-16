class Vente {
  final int id;
  final String client;
  final List<LigneVente> lignes;
  final DateTime date;
  final double total;
  final double montantPaye;
  final String modePaiement;
  final VenteStatut statut;

  Vente({
    required this.id,
    required this.client,
    required this.lignes,
    required this.date,
    required this.total,
    required this.montantPaye,
    required this.modePaiement,
    required this.statut,
  });

  factory Vente.fromJson(Map<String, dynamic> json) {
    return Vente(
      id: json['id'],
      client: json['client'],
      lignes: (json['lignes'] as List)
          .map((e) => LigneVente.fromJson(e as Map<String, dynamic>))
          .toList(),
      date: DateTime.parse(json['date']),
      total: double.tryParse(json['total'] ?? '0') ?? 0,
      montantPaye: double.tryParse(json['montant_paye'] ?? '0') ?? 0,
      modePaiement: json['mode_paiement'] ?? '',
      statut: VenteStatut.values.firstWhere(
        (e) => e.name == json['statut'],
        orElse: () => VenteStatut.enCours,
      ),
    );
  }
}

class LigneVente {
  final int id;
  final String produit;
  final String quantite;
  final String prixUnitaire;
  final String remise;
  final int vente;

  LigneVente({
    required this.id,
    required this.produit,
    required this.quantite,
    required this.prixUnitaire,
    required this.remise,
    required this.vente,
  });

  factory LigneVente.fromJson(Map<String, dynamic> json) {
    return LigneVente(
      id: json['id'],
      produit: json['produit'],
      quantite: json['quantite'],
      prixUnitaire: json['prix_unitaire'],
      remise: json['remise'],
      vente: json['vente'],
    );
  }
}

class VenteRequest {
  final int clientId;
  final List<LigneVenteRequest> lignes;
  final String total;
  final String? montantPaye;
  final String? modePaiement;
  final VenteStatut? statut;

  VenteRequest({
    required this.clientId,
    required this.lignes,
    required this.total,
    this.montantPaye,
    this.modePaiement,
    this.statut,
  });

  Map<String, dynamic> toJson() => {
        'client_id': clientId,
        'lignes': lignes.map((e) => e.toJson()).toList(),
        'total': total,
        if (montantPaye != null) 'montant_paye': montantPaye,
        if (modePaiement != null) 'mode_paiement': modePaiement,
        if (statut != null) 'statut': statut!.name,
      };
}

class LigneVenteRequest {
  int produitId;
  String quantite;
  String prixUnitaire;
  String remise;
  int vente;

  LigneVenteRequest({
    required this.produitId,
    required this.quantite,
    required this.prixUnitaire,
    required this.remise,
    required this.vente,
  });

  Map<String, dynamic> toJson() => {
        'produit_id': produitId,
        'quantite': quantite,
        'prix_unitaire': prixUnitaire,
        'remise': remise,
        'vente': vente,
      };
}

enum VenteStatut { enCours, payee, annulee }
