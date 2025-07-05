class DashboardStats {
  final double totalVente;
  final double totalAchat;
  final int totalStock;

  DashboardStats({
    required this.totalVente,
    required this.totalAchat,
    required this.totalStock,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalVente: json['total_vente'].toDouble(),
      totalAchat: json['total_achat'].toDouble(),
      totalStock: json['total_stock'],
    );
  }

  Map<String, dynamic> toJson() => {
        'total_vente': totalVente,
        'total_achat': totalAchat,
        'total_stock': totalStock,
      };
}
