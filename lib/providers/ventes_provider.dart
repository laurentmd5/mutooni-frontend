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
    try {
      final response = await apiService.client.get(
        Constants.ventes,
        queryParameters: query,
      );
      
      if (response.data is! List) {
        throw const FormatException('Expected list of ventes');
      }
      
      return (response.data as List).map((e) => Vente.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load ventes: ${e.toString()}');
    }
  }

  Future<void> create(VenteRequest request) async {
    try {
      state = const AsyncValue.loading();
      await apiService.client.post(
        Constants.ventes,
        data: request.toJson(),
      );
      state = await AsyncValue.guard(() => _fetch());
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> updateVente(int id, VenteRequest request) async {
    try {
      state = const AsyncValue.loading();
      await apiService.client.put(
        '${Constants.ventes}/$id/',
        data: request.toJson(),
      );
      state = await AsyncValue.guard(() => _fetch());
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> delete(int id) async {
    try {
      state = const AsyncValue.loading();
      await apiService.client.delete('${Constants.ventes}/$id/');
      state = await AsyncValue.guard(() => _fetch());
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() => _fetch());
  }

  Future<void> filterByClient(int clientId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _fetch(query: {'client': clientId.toString()}),
    );
  }

  Future<void> filterByStatut(VenteStatut statut) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _fetch(query: {'statut': statut.name.toUpperCase()}),
    );
  }

  Future<void> clearFilters() => refresh();
}