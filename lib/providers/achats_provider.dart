import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mutooni_frontend/core/api_service.dart';
import 'package:mutooni_frontend/models/achat.dart';

final achatsProvider = AsyncNotifierProvider<AchatsNotifier, List<Achat>>(AchatsNotifier.new);

class AchatsNotifier extends AsyncNotifier<List<Achat>> {
  @override
  Future<List<Achat>> build() async {
    // Chargement initial des achats
    return await _fetchAchats();
  }

  Future<List<Achat>> _fetchAchats() async {
    try {
      final response = await apiService.client.get('/achats/');
      final achats = (response.data as List)
          .map((json) => Achat.fromJson(json))
          .toList();
      return achats;
    } catch (e) {
      throw Exception('Erreur lors du chargement des achats: ${e.toString()}');
    }
  }

  Future<void> save(Achat achat, {bool isEdit = false}) async {
    try {
      state = const AsyncValue.loading();
      
      if (isEdit) {
        await apiService.client.put(
          '/achats/${achat.id}/',
          data: achat.toJson(),
        );
      } else {
        await apiService.client.post(
          '/achats/',
          data: achat.toJson(),
        );
      }

      // Recharger la liste après modification
      state = await AsyncValue.guard(() => _fetchAchats());
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    try {
      state = const AsyncValue.loading();
      await apiService.client.delete('/achats/$id/');
      // Recharger la liste après suppression
      state = await AsyncValue.guard(() => _fetchAchats());
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() => _fetchAchats());
  }
}