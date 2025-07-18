class Fournisseur {
  final int id;
  final String nom;
  final String telephone;
  final String? email;
  final String adresse;
  final double solde;

  Fournisseur({
    required this.id,
    required this.nom,
    required this.telephone,
    this.email,
    required this.adresse,
    required this.solde,
  });

  factory Fournisseur.fromJson(Map<String, dynamic> json) {
    try {
      return Fournisseur(
        id: json['id'] as int,
        nom: json['nom'] as String,
        telephone: json['telephone'] as String,
        email: json['email'] as String?,
        adresse: json['adresse'] as String? ?? '',
        solde: double.tryParse(json['solde']?.toString() ?? '0') ?? 0,
      );
    } catch (e) {
      throw FormatException('Failed to parse Fournisseur: $e');
    }
  }
}

class FournisseurRequest {
  final String nom;
  final String telephone;
  final String? email;
  final String adresse;
  final double solde;

  FournisseurRequest({
    required this.nom,
    required this.telephone,
    this.email,
    required this.adresse,
    required this.solde,
  });

  Map<String, dynamic> toJson() => {
        'nom': nom,
        'telephone': telephone,
        if (email != null) 'email': email,
        'adresse': adresse,
        'solde': solde.toStringAsFixed(2),
      }..removeWhere((key, value) => value == null);
}

class PatchedFournisseurRequest {
  final String? nom;
  final String? telephone;
  final String? email;
  final String? adresse;
  final double? solde;

  PatchedFournisseurRequest({
    this.nom,
    this.telephone,
    this.email,
    this.adresse,
    this.solde,
  });

  Map<String, dynamic> toJson() => {
        if (nom != null) 'nom': nom,
        if (telephone != null) 'telephone': telephone,
        if (email != null) 'email': email,
        if (adresse != null) 'adresse': adresse,
        if (solde != null) 'solde': solde!.toStringAsFixed(2),
      }..removeWhere((key, value) => value == null);
}