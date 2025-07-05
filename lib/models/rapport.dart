class Rapport {
  final String id;
  final String titre;
  final String contenu;
  final DateTime dateCreation;
  final String auteur;

  Rapport({
    required this.id,
    required this.titre,
    required this.contenu,
    required this.dateCreation,
    required this.auteur,
  });

  factory Rapport.fromJson(Map<String, dynamic> json) {
    return Rapport(
      id: json['id'],
      titre: json['titre'],
      contenu: json['contenu'],
      dateCreation: DateTime.parse(json['date_creation']),
      auteur: json['auteur'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'titre': titre,
        'contenu': contenu,
        'date_creation': dateCreation.toIso8601String(),
        'auteur': auteur,
      };
}
