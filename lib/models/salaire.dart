class Salaire {
  final int id;
  final String employe;
  final String periode;
  final double brut;
  final double net;
  final double montantPaye;
  final DateTime datePaiement;

  Salaire({
    required this.id,
    required this.employe,
    required this.periode,
    required this.brut,
    required this.net,
    required this.montantPaye,
    required this.datePaiement,
  });

  factory Salaire.fromJson(Map<String, dynamic> json) {
    return Salaire(
      id: json['id'],
      employe: json['employe'],
      periode: json['periode'],
      brut: double.parse(json['brut']),
      net: double.parse(json['net']),
      montantPaye: double.parse(json['montant_paye']),
      datePaiement: DateTime.parse(json['date_paiement']),
    );
  }
}