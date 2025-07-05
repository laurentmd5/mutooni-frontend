import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_service.dart';
import '../models/employe.dart';
import '../core/constants.dart';

final rhProvider = AsyncNotifierProvider<RHNotifier, List<Employe>>(RHNotifier.new);

class RHNotifier extends AsyncNotifier<List<Employe>> {
  @override
  Future<List<Employe>> build() => _fetch();

  Future<List<Employe>> _fetch() async {
    final res = await apiService.client.get(Constants.employes);
    return (res.data as List).map((e) => Employe.fromJson(e)).toList();
  }

  Future<void> save(Employe employe, {bool isEdit = false}) async {
    if (isEdit) {
      await apiService.client.put('${Constants.employes}/${employe.id}', data: employe.toJson());
    } else {
      await apiService.client.post(Constants.employes, data: employe.toJson());
    }
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _fetch());
  }

  Future<void> delete(String id) async {
    await apiService.client.delete('${Constants.employes}/$id');
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _fetch());
  }
}