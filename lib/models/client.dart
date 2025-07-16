// models/client.dart
class Client {
  final int id;
  final String nom;
  final String? email;
  final String? telephone;
  final String? adresse;
  final String solde;

  Client({
    required this.id,
    required this.nom,
    this.email,
    this.telephone,
    this.adresse,
    required this.solde,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      nom: json['nom'],
      email: json['email'],
      telephone: json['telephone'],
      adresse: json['adresse'],
      solde: json['solde'] ?? '0.00',
    );
  }

  Map<String, dynamic> toJson() => {
        'nom': nom,
        'email': email,
        'telephone': telephone,
        'adresse': adresse,
        'solde': solde,
      };
}
