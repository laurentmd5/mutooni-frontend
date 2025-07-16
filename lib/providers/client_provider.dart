import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_service.dart';
import '../models/client.dart';

final clientProvider = AsyncNotifierProvider<ClientNotifier, List<Client>>(ClientNotifier.new);

class ClientNotifier extends AsyncNotifier<List<Client>> {
  @override
  Future<List<Client>> build() => _fetch();

  Future<List<Client>> _fetch({String? search}) async {
    final url = search != null && search.isNotEmpty
        ? '/clients/?search=$search'
        : '/clients/';
    final res = await apiService.client.get(url);
    return (res.data as List).map((e) => Client.fromJson(e)).toList();
  }

  Future<void> save(Client client, {bool isEdit = false}) async {
    if (isEdit) {
      await apiService.client.put('/clients/${client.id}/', data: client.toJson());
    } else {
      await apiService.client.post('/clients/', data: client.toJson());
    }
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _fetch());
  }

  Future<void> delete(int id) async {
    await apiService.client.delete('/clients/$id/');
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _fetch());
  }

  Future<void> search(String query) async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _fetch(search: query));
  }
}
