import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_service.dart';
import '../models/achat.dart';

/// Provider principal : liste des achats
final achatsProvider =
    AsyncNotifierProvider<AchatsNotifier, List<Achat>>(AchatsNotifier.new);

class AchatsNotifier extends AsyncNotifier<List<Achat>> {
  /* ─────────── Chargement initial ─────────── */
  @override
  Future<List<Achat>> build() => _fetch();

  Future<List<Achat>> _fetch({Map<String, String>? query}) async {
    final res = await apiService.client.get('/achats/', queryParameters: query);
    return (res.data as List)
        .map((e) => Achat.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /* ─────────── CRUD ─────────── */
  Future<void> create({
    required int fournisseurId,
    required List<LigneAchatRequest> lignes,
    required double total,
    double montantPaye = 0,
    AchatStatut statut = AchatStatut.EN_ATTENTE,
  }) async {
    final body = {
      'fournisseur_id': fournisseurId,
      'lignes': lignes.map((e) => e.toJson()).toList(),
      'total': total.toStringAsFixed(2),
      if (montantPaye > 0) 'montant_paye': montantPaye.toStringAsFixed(2),
      if (statut != AchatStatut.EN_ATTENTE) 'statut': statut.name,
    };

    await apiService.client.post('/achats/', data: body);
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> delete(int id) async {
    await apiService.client.delete('/achats/$id/');
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(_fetch);
  }

  /* ─────────── Filtres rapides ─────────── */
  Future<void> filterByStatut(AchatStatut statut) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetch(query: {'statut': statut.name}),
    );
  }

  Future<void> clearFilters() => refresh();
}
