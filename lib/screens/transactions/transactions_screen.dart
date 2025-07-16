import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mutooni_frontend/widgets/main_layout.dart';
import '../../providers/transactions_provider.dart';
import '../../models/transaction.dart';



class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(transactionsProvider);
    final selectedIndex = 7; // ⚠️ adapte la position si le SideMenu change

    return MainLayout(
      selectedIndex: selectedIndex,
      onItemTap: (i) {},     // la navigation est déjà gérée par SideMenu
      title: 'Transactions',
      actions: [
        IconButton(
          tooltip: 'Rafraîchir',
          icon: const Icon(Icons.refresh),
          onPressed: () =>
              ref.read(transactionsProvider.notifier).updateFilter(
                    const TransactionFilter(), // remet le filtre à vide
                  ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FiltersBar(),
            const SizedBox(height: 16),
            Expanded(
              child: list.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (err, _) =>
                    Center(child: Text('Erreur: $err')),
                data: (txs) => _TransactionsTable(items: txs),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*──────────────────────── Filtres UI ────────────────────────*/

class _FiltersBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(transactionsProvider.notifier);
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Type
        DropdownButton<String>(
          hint: const Text('Type'),
          items: const [
            DropdownMenuItem(value: 'RECETTE', child: Text('Recette')),
            DropdownMenuItem(value: 'DEPENSE', child: Text('Dépense')),
          ],
          onChanged: (v) =>
              notifier.updateFilter(TransactionFilter(type: v)),
        ),
        // Module
        SizedBox(
          width: 150,
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Module',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (v) =>
                notifier.updateFilter(TransactionFilter(module: v.trim())),
          ),
        ),
        // Date
        ElevatedButton.icon(
          icon: const Icon(Icons.date_range),
          label: const Text('Date'),
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              initialDate: DateTime.now(),
            );
            if (picked != null) {
              notifier.updateFilter(TransactionFilter(date: picked));
            }
          },
        ),
      ],
    );
  }
}

/*─────────────────────── Table des données ───────────────────*/

class _TransactionsTable extends StatelessWidget {
  final List<Transaction> items;
  const _TransactionsTable({required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Type')),
            DataColumn(label: Text('Module')),
            DataColumn(label: Text('Réf.')),
            DataColumn(label: Text('Montant')),
            DataColumn(label: Text('Description')),
          ],
          rows: items.map(_toRow).toList(),
        ),
      ),
    );
  }

  DataRow _toRow(Transaction t) => DataRow(
        cells: [
          DataCell(Text(
              '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}-${t.date.day.toString().padLeft(2, '0')}')),
          DataCell(Text(t.type)),
          DataCell(Text(t.module)),
          DataCell(Text('${t.referenceId}')),
          DataCell(Text(t.montant.toStringAsFixed(2))),
          DataCell(Text(t.description ?? '—')),
        ],
      );

 
}
