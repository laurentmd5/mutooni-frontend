import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mutooni_frontend/core/api_service.dart';
import 'package:mutooni_frontend/core/constants.dart';
import 'package:mutooni_frontend/models/produit.dart';
import 'package:mutooni_frontend/models/produit_request.dart';

class ProduitsNotifier extends AsyncNotifier<List<Produit>> {
  late final _dio;

  @override
  Future<List<Produit>> build() async {
    _dio = ref.read(apiServiceProvider).client;
    return await _getProduits();
  }

  Future<List<Produit>> _getProduits() async {
    final response = await _dio.get(Constants.produits);
    return (response.data as List)
        .map((e) => Produit.fromJson(e))
        .toList();
  }

  Future<Produit> _addProduit(ProduitRequest request) async {
    final response = await _dio.post(Constants.produits, data: request.toJson());
    return Produit.fromJson(response.data);
  }

  Future<Produit> _updateProduit(int id, ProduitRequest request) async {
    final response = await _dio.put('${Constants.produits}$id/', data: request.toJson());
    return Produit.fromJson(response.data);
  }

  Future<void> _deleteProduit(int id) async {
    await _dio.delete('${Constants.produits}$id/');
  }

  /// Action publique : Ajouter un produit
  Future<void> add(ProduitRequest request) async {
    final produit = await _addProduit(request);
    state = AsyncData([...state.value ?? [], produit]);
  }

  /// Action publique : Modifier un produit
  Future<void> updateProduit(int id, ProduitRequest request) async {
    final updated = await _updateProduit(id, request);
    state = AsyncData([
      for (final p in state.value ?? [])
        if (p.id == id) updated else p
    ]);
  }

  /// Action publique : Supprimer un produit
  Future<void> delete(int id) async {
    await _deleteProduit(id);
    state = AsyncData([
      for (final p in state.value ?? [])
        if (p.id != id) p
    ]);
  }
}

final produitsProvider =
    AsyncNotifierProvider<ProduitsNotifier, List<Produit>>(ProduitsNotifier.new);
