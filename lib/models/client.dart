class Client {
  final String id;
  final String nom;
  final String email;
  final String telephone;
  final String adresse;
  final DateTime dateInscription;

  Client({
    required this.id,
    required this.nom,
    required this.email,
    required this.telephone,
    required this.adresse,
    required this.dateInscription,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      nom: json['nom'],
      email: json['email'],
      telephone: json['telephone'],
      adresse: json['adresse'],
      dateInscription: DateTime.parse(json['date_inscription']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'email': email,
        'telephone': telephone,
        'adresse': adresse,
        'date_inscription': dateInscription.toIso8601String(),
      };
}
