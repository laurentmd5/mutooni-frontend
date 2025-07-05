class Achat {
  final String id;
  final double montant;
  final DateTime date;

  Achat({
    required this.id,
    required this.montant,
    required this.date,
  });

  factory Achat.fromJson(Map<String, dynamic> json) {
    return Achat(
      id: json['id'],
      montant: json['montant'].toDouble(),
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'montant': montant,
        'date': date.toIso8601String(),
      };
}
