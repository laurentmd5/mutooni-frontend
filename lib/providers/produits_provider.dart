import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_service.dart';
import '../models/produit.dart';
import '../models/produit_request.dart';

final produitsProvider = AsyncNotifierProvider<ProduitsNotifier, List<Produit>>(ProduitsNotifier.new);

class ProduitsNotifier extends AsyncNotifier<List<Produit>> {
  @override
  Future<List<Produit>> build() async {
    return await _fetchProduits();
  }

  Future<List<Produit>> _fetchProduits({String? search, int? categorieId}) async {
    try {
      final params = {
        if (search != null) 'search': search,
        if (categorieId != null) 'categorie': categorieId,
      };
      final response = await ref.read(apiServiceProvider).client.get(
        '/produits/',
        queryParameters: params,
      );
      return (response.data as List).map((e) => Produit.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Erreur de chargement: ${e.toString()}');
    }
  }

  Future<Produit> _createProduit(ProduitRequest request) async {
    final response = await ref.read(apiServiceProvider).client.post(
      '/produits/',
      data: request.toJson(),
    );
    return Produit.fromJson(response.data);
  }

  Future<Produit> _updateProduit(int id, ProduitRequest request) async {
    final response = await ref.read(apiServiceProvider).client.put(
      '/produits/$id/',
      data: request.toJson(),
    );
    return Produit.fromJson(response.data);
  }

  Future<void> _deleteProduit(int id) async {
    await ref.read(apiServiceProvider).client.delete('/produits/$id/');
  }

  Future<void> addProduit(ProduitRequest request, BuildContext context) async {
    try {
      state = const AsyncValue.loading();
      final newProduit = await _createProduit(request);
      state = AsyncValue.data([...state.value ?? [], newProduit]);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produit ajouté avec succès')),
        );
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> updateProduit(int id, ProduitRequest request, BuildContext context) async {
    try {
      state = const AsyncValue.loading();
      final updated = await _updateProduit(id, request);
      state = AsyncValue.data([
        for (final p in state.value ?? [])
          if (p.id == id) updated else p
      ]);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produit mis à jour')),
        );
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> deleteProduit(int id, BuildContext context) async {
    try {
      state = const AsyncValue.loading();
      await _deleteProduit(id);
      state = AsyncValue.data([
        for (final p in state.value ?? [])
          if (p.id != id) p
      ]);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produit supprimé')),
        );
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> searchProduits(String query) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchProduits(search: query));
  }

  Future<void> filterByCategory(int? categorieId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchProduits(categorieId: categorieId));
  }
}