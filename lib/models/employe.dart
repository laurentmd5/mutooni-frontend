class Employe {
  final String id;
  final String nom;
  final String poste;
  final String salaireBase;
  final DateTime dateEmbauche;
  final bool actif;

  Employe({
    required this.id,
    required this.nom,
    required this.poste,
    required this.salaireBase,
    required this.dateEmbauche,
    required this.actif,
  });

  factory Employe.fromJson(Map<String, dynamic> json) {
    return Employe(
      id: json['id'].toString(),
      nom: json['nom'],
      poste: json['poste'],
      salaireBase: json['salaire_base'],
      dateEmbauche: DateTime.parse(json['date_embauche']),
      actif: json['actif'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'nom': nom,
        'poste': poste,
        'salaire_base': salaireBase,
        'date_embauche': dateEmbauche.toIso8601String(),
        'actif': actif,
      };
}