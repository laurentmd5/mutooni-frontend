import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_service.dart';
import '../models/vente.dart';
import '../core/constants.dart';

final ventesProvider =
    AsyncNotifierProvider<VentesNotifier, List<Vente>>(VentesNotifier.new);

class VentesNotifier extends AsyncNotifier<List<Vente>> {
  @override
  Future<List<Vente>> build() => _fetch();

  Future<List<Vente>> _fetch({Map<String, String>? query}) async {
    final res = await apiService.client.get(Constants.ventes, queryParameters: query);
    return (res.data as List).map((e) => Vente.fromJson(e)).toList();
  }

  Future<void> create(VenteRequest request) async {
    await apiService.client.post(Constants.ventes, data: request.toJson());
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> updateVente(int id, VenteRequest request) async {
    await apiService.client.put('${Constants.ventes}/$id/', data: request.toJson());
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> delete(int id) async {
    await apiService.client.delete('${Constants.ventes}/$id/');
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> filterByClient(int clientId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetch(query: {'client': clientId.toString()}),
    );
  }

  Future<void> filterByStatut(VenteStatut statut) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetch(query: {'statut': statut.name}),
    );
  }

  Future<void> clearFilters() => refresh();
}
