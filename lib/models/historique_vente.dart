class HistoriqueVente {
  final DateTime date;
  final double totalVentes;
  final int nombreVentes;
  final double montantMoyen;

  HistoriqueVente({
    required this.date,
    required this.totalVentes,
    required this.nombreVentes,
    required this.montantMoyen,
  });

  factory HistoriqueVente.fromJson(Map<String, dynamic> json) {
    return HistoriqueVente(
      date: DateTime.parse(json['date']),
      totalVentes: double.parse(json['total_ventes']),
      nombreVentes: json['nombre_ventes'],
      montantMoyen: double.parse(json['montant_moyen']),
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'total_ventes': totalVentes.toStringAsFixed(2),
        'nombre_ventes': nombreVentes,
        'montant_moyen': montantMoyen.toStringAsFixed(2),
      };
}
