import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_service.dart';
import '../models/client.dart';

/// Provider asynchrone qui expose toute la liste des clients.
/// `ref.watch(clientProvider)` renvoie un `AsyncValue<List<Client>>`.
final clientProvider = AsyncNotifierProvider<ClientNotifier, List<Client>>(ClientNotifier.new);

class ClientNotifier extends AsyncNotifier<List<Client>> {
  @override
  Future<List<Client>> build() => _fetch();

  /// Récupère la liste depuis l’API
  Future<List<Client>> _fetch() async {
    final res = await apiService.client.get('/clients/');
    return (res.data as List).map((e) => Client.fromJson(e)).toList();
  }

  /// Création / mise à jour (POST ou PUT)
  Future<void> save(Client client, {bool isEdit = false}) async {
    if (isEdit) {
      await apiService.client.put('/clients/${client.id}/', data: client.toJson());
    } else {
      await apiService.client.post('/clients/', data: client.toJson());
    }
    // rafraîchir la liste
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _fetch());
  }

  /// Suppression
  Future<void> delete(String id) async {
    await apiService.client.delete('/clients/$id/');
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _fetch());
  }
}
