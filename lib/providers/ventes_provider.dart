import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_service.dart';
import '../models/vente.dart';
import '../core/constants.dart';

final ventesProvider = AsyncNotifierProvider<VentesNotifier, List<Vente>>(VentesNotifier.new);

class VentesNotifier extends AsyncNotifier<List<Vente>> {
  @override
  Future<List<Vente>> build() => _fetch();

  Future<List<Vente>> _fetch() async {
    final res = await apiService.client.get(Constants.ventes);
    return (res.data as List).map((e) => Vente.fromJson(e)).toList();
  }

  Future<void> save(Vente vente, {bool isEdit = false}) async {
    if (isEdit) {
      await apiService.client.put('${Constants.ventes}/${vente.id}', data: vente.toJson());
    } else {
      await apiService.client.post(Constants.ventes, data: vente.toJson());
    }
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _fetch());
  }

  Future<void> delete(String id) async {
    await apiService.client.delete('${Constants.ventes}/$id');
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _fetch());
  }
}