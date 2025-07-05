import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_service.dart';
import '../models/rapport.dart';
import '../core/constants.dart';

final rapportsProvider = AsyncNotifierProvider<RapportsNotifier, List<Rapport>>(RapportsNotifier.new);

class RapportsNotifier extends AsyncNotifier<List<Rapport>> {
  @override
  Future<List<Rapport>> build() => _fetch();

  Future<List<Rapport>> _fetch() async {
    final res = await apiService.client.get(Constants.rapports);
    return (res.data as List).map((e) => Rapport.fromJson(e)).toList();
  }

  Future<void> save(Rapport rapport, {bool isEdit = false}) async {
    if (isEdit) {
      await apiService.client.put('${Constants.rapports}/${rapport.id}', data: rapport.toJson());
    } else {
      await apiService.client.post(Constants.rapports, data: rapport.toJson());
    }
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _fetch());
  }

  Future<void> delete(String id) async {
    await apiService.client.delete('${Constants.rapports}/$id');
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _fetch());
  }
}