import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_service.dart';
import '../models/achat.dart';

final achatsProvider = AsyncNotifierProvider<AchatsNotifier, List<Achat>>(AchatsNotifier.new);

class AchatsNotifier extends AsyncNotifier<List<Achat>> {
  @override
  Future<List<Achat>> build() => _fetch();

  Future<List<Achat>> _fetch({Map<String, String>? query}) async {
    try {
      final res = await apiService.client.get(
        '/achats/',
        queryParameters: query,
      );
      
      if (res.data is! List) {
        throw const FormatException('Expected list of achats');
      }
      
      return (res.data as List).map((e) => Achat.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load achats: ${e.toString()}');
    }
  }

  Future<void> create({
    required int fournisseurId,
    required List<LigneAchatRequest> lignes,
    required double total,
    double montantPaye = 0,
    AchatStatut statut = AchatStatut.EN_ATTENTE,
  }) async {
    try {
      state = const AsyncValue.loading();
      final body = {
        'fournisseur_id': fournisseurId,
        'lignes': lignes.map((e) => e.toJson()).toList(),
        'total': total.toStringAsFixed(2),
        if (montantPaye > 0) 'montant_paye': montantPaye.toStringAsFixed(2),
        if (statut != AchatStatut.EN_ATTENTE) 'statut': statut.name,
      };

      await apiService.client.post('/achats/', data: body);
      state = await AsyncValue.guard(() => _fetch());
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> delete(int id) async {
    try {
      state = const AsyncValue.loading();
      await apiService.client.delete('/achats/$id/');
      state = await AsyncValue.guard(() => _fetch());
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() => _fetch());
  }

  Future<void> filterByStatut(AchatStatut statut) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _fetch(query: {'statut': statut.name}),
    );
  }

  Future<void> clearFilters() => refresh();
}