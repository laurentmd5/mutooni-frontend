import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_service.dart';
import '../models/historique_vente.dart';

final historiqueVentesProvider =
    FutureProvider<List<HistoriqueVente>>((ref) async {
  final res = await apiService.client.get('/stats/historique-ventes/');
  return (res.data as List)
      .map((e) => HistoriqueVente.fromJson(e))
      .toList();
});
