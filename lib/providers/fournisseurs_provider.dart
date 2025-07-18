import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_service.dart';
import '../models/fournisseur.dart';

final fournisseursProvider = StateNotifierProvider<FournisseursNotifier, AsyncValue<List<Fournisseur>>>(
  (ref) => FournisseursNotifier(),
);

class FournisseursNotifier extends StateNotifier<AsyncValue<List<Fournisseur>>> {
  FournisseursNotifier() : super(const AsyncValue.loading()) {
    _fetch();
  }

  Future<void> _fetch({String? search}) async {
    state = const AsyncValue.loading();
    try {
      final response = await apiService.client.get(
        '/fournisseurs/',
        queryParameters: search != null ? {'search': search} : null,
      );

      if (response.data is! List) {
        throw const FormatException('Expected list of fournisseurs');
      }

      final fournisseurs = (response.data as List)
          .map((e) => Fournisseur.fromJson(e))
          .toList();
      
      state = AsyncValue.data(fournisseurs);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> create(FournisseurRequest request) async {
    try {
      state = const AsyncValue.loading();
      await apiService.client.post(
        '/fournisseurs/',
        data: request.toJson(),
      );
      await _fetch();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> updateItem(int id, FournisseurRequest request) async {
    try {
      state = const AsyncValue.loading();
      await apiService.client.put(
        '/fournisseurs/$id/',
        data: request.toJson(),
      );
      await _fetch();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> deleteItem(int id) async {
    try {
      state = const AsyncValue.loading();
      await apiService.client.delete('/fournisseurs/$id/');
      await _fetch();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> search(String term) async {
    await _fetch(search: term);
  }

  Future<void> refresh() async {
    await _fetch();
  }
}