class Stock {
  final String produit;
  final int quantite;
  final DateTime date;

  Stock({
    required this.produit,
    required this.quantite,
    required this.date,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      produit: json['produit'],
      quantite: json['quantite'],
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() => {
        'produit': produit,
        'quantite': quantite,
        'date': date.toIso8601String(),
      };
}
