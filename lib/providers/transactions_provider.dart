import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_service.dart';
import '../models/transaction.dart';
import '../core/constants.dart';

/// Filtre local (type / module / date).
class TransactionFilter {
  final String? type;      // "RECETTE" ou "DEPENSE"
  final String? module;    // ex. "ventes"
  final DateTime? date;    // filtre exact (backend attends date-time)

  const TransactionFilter({this.type, this.module, this.date});

  Map<String, String> toQuery() {
    final map = <String, String>{};
    if (type != null)   map['type']  = type!;
    if (module != null) map['module'] = module!;
    if (date != null)   map['date']  = date!.toIso8601String();
    return map;
  }

  TransactionFilter copyWith({String? type, String? module, DateTime? date}) =>
      TransactionFilter(
        type:   type   ?? this.type,
        module: module ?? this.module,
        date:   date   ?? this.date,
      );
}

/// Provider “source de vérité” : liste filtrée de transactions.
final transactionsProvider = AsyncNotifierProvider<
    TransactionsNotifier,
    List<Transaction>>(TransactionsNotifier.new);

class TransactionsNotifier extends AsyncNotifier<List<Transaction>> {
  /// Filtre courant (modifiable via setter).
  TransactionFilter _filter = const TransactionFilter();

  @override
  Future<List<Transaction>> build() => _fetch();

  /// MAJ du filtre puis re-fetch automatique.
  Future<void> updateFilter(TransactionFilter f) async {
    _filter = f;
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _fetch());
  }

  Future<List<Transaction>> _fetch() async {
    final res = await apiService.client.get(
      Constants.transactions,
      queryParameters: _filter.toQuery(),
    );
    return (res.data as List)
        .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
