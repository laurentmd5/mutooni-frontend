class Employe {
  final String id;
  final String nom;
  final String poste;
  final String email;
  final DateTime dateEmbauche;
  final double salaire;

  Employe({
    required this.id,
    required this.nom,
    required this.poste,
    required this.email,
    required this.dateEmbauche,
    required this.salaire,
  });

  factory Employe.fromJson(Map<String, dynamic> json) {
    return Employe(
      id: json['id'],
      nom: json['nom'],
      poste: json['poste'],
      email: json['email'],
      dateEmbauche: DateTime.parse(json['date_embauche']),
      salaire: json['salaire'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'poste': poste,
        'email': email,
        'date_embauche': dateEmbauche.toIso8601String(),
        'salaire': salaire,
      };
}
