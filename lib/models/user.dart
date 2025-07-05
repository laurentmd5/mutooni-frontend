class User {
  final String id;
  final String nom;
  final String email;
  final bool isAdmin;

  User({
    required this.id,
    required this.nom,
    required this.email,
    required this.isAdmin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nom: json['nom'],
      email: json['email'],
      isAdmin: json['is_admin'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'email': email,
        'is_admin': isAdmin,
      };
}
