import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_service.dart';
import '../models/employe.dart';

final rhProvider = FutureProvider.family<List<Employe>, String>((ref, search) async {
  final res = await apiService.client.get('/employes/', queryParameters: {
    if (search.isNotEmpty) 'search': search,
  });
  return (res.data as List).map((e) => Employe.fromJson(e)).toList();
});

final rhControllerProvider = AsyncNotifierProvider<RHController, void>(RHController.new);

class RHController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> save(Employe employe, {bool isEdit = false}) async {
    if (isEdit) {
      await apiService.client.put('/employes/${employe.id}/', data: employe.toJson());
    } else {
      await apiService.client.post('/employes/', data: employe.toJson());
    }
  }

  Future<void> delete(String id) async {
    await apiService.client.delete('/employes/$id/');
  }
}