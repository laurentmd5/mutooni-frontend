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
    try {
      return Vente(
        id: json['id'] as int,
        client: json['client'] as String,
        lignes: (json['lignes'] as List)
            .map((e) => LigneVente.fromJson(e as Map<String, dynamic>))
            .toList(),
        date: DateTime.parse(json['date'] as String),
        total: double.tryParse(json['total']?.toString() ?? '0') ?? 0,
        montantPaye: double.tryParse(json['montant_paye']?.toString() ?? '0') ?? 0,
        modePaiement: json['mode_paiement'] as String? ?? '',
        statut: VenteStatut.values.firstWhere(
          (e) => e.name.toUpperCase() == (json['statut'] as String?)?.toUpperCase(),
          orElse: () => VenteStatut.enCours,
        ),
      );
    } catch (e) {
      throw FormatException('Failed to parse Vente: $e');
    }
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
    try {
      return LigneVente(
        id: json['id'] as int,
        produit: json['produit'] as String,
        quantite: json['quantite'] as String,
        prixUnitaire: json['prix_unitaire'] as String,
        remise: json['remise'] as String,
        vente: json['vente'] as int,
      );
    } catch (e) {
      throw FormatException('Failed to parse LigneVente: $e');
    }
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
        if (statut != null) 'statut': statut!.name.toUpperCase(),
      }..removeWhere((key, value) => value == null);
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