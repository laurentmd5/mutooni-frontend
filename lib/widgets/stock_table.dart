import 'package:flutter/material.dart';
import '../models/stock.dart';

/// Tableau simple des mouvements de stock.
class StockTable extends StatelessWidget {
  final List<Stock> stocks;
  const StockTable({super.key, required this.stocks});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Produit')),
          DataColumn(label: Text('Qté')),
          DataColumn(label: Text('Date')),
        ],
        rows: stocks
            .map((s) => DataRow(cells: [
                  DataCell(Text(s.produit)),
                  DataCell(Text('${s.quantite}')),
                  DataCell(Text(
                      '${s.date.day}/${s.date.month}/${s.date.year}')),
                ]))
            .toList(),
      ),
    );
  }
}
