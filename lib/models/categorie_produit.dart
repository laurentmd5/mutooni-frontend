class CategorieProduit {
  final int id;
  final String nom;

  CategorieProduit({required this.id, required this.nom});

  factory CategorieProduit.fromJson(Map<String, dynamic> json) {
    return CategorieProduit(
      id: json['id'],
      nom: json['nom'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
      };
}