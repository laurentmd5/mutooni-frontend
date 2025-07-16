import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/salaire.dart';
import '../core/api_service.dart';

final salairesProvider = FutureProvider.family<List<Salaire>, int>((ref, employeId) async {
  final res = await apiService.client.get('/salaires/', queryParameters: {
    'employe': employeId,
  });
  return (res.data as List).map((e) => Salaire.fromJson(e)).toList();
});
