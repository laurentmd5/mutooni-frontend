class Transaction {
  final int id;
  final DateTime date;
  final String type; // RECETTE | DEPENSE
  final String module;
  final int referenceId;
  final double montant; // décimal comme chaîne
  final String? description;

  Transaction({
    required this.id,
    required this.date,
    required this.type,
    required this.module,
    required this.referenceId,
    required this.montant,
    this.description,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      date: DateTime.parse(json['date']),
      type: json['type'],
      module: json['module'],
      referenceId: json['reference_id'],
      montant: json['montant'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'type': type,
        'module': module,
        'reference_id': referenceId,
        'montant': montant,
        'description': description,
      };
}
