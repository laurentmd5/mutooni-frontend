import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_service.dart';
import '../models/client.dart';

final clientProvider = AsyncNotifierProvider<ClientNotifier, List<Client>>(ClientNotifier.new);

class ClientNotifier extends AsyncNotifier<List<Client>> {
  @override
  Future<List<Client>> build() => _fetch();

  Future<List<Client>> _fetch({String? search}) async {
    try {
      final url = search != null && search.isNotEmpty
          ? '/clients/?search=$search'
          : '/clients/';
      final res = await apiService.client.get(url);
      return (res.data as List).map((e) => Client.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Erreur de chargement: ${e.toString()}');
    }
  }

  Future<void> save(Client client, {bool isEdit = false, BuildContext? context}) async {
    try {
      state = const AsyncValue.loading();
      if (isEdit) {
        await apiService.client.put('/clients/${client.id}/', data: client.toJson());
      } else {
        await apiService.client.post('/clients/', data: client.toJson());
      }
      state = AsyncValue.data(await _fetch());
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Client ${isEdit ? 'modifié' : 'ajouté'} avec succès')),
        );
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
      rethrow;
    }
  }

  Future<void> delete(int id, BuildContext context) async {
    try {
      state = const AsyncValue.loading();
      await apiService.client.delete('/clients/$id/');
      state = AsyncValue.data(await _fetch());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Client supprimé')),
        );
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
      rethrow;
    }
  }

  Future<void> search(String query) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch(search: query));
  }
}