import 'package:flutter/material.dart';
import '../core/api_service.dart';
import '../models/dashboard_stats.dart';

/// Charge et expose les indicateurs principaux (statistiques tableau de bord).
class DashboardProvider extends ChangeNotifier {
  DashboardStats? _stats;
  bool _loading = false;
  String? _error;

  DashboardStats? get stats => _stats;
  bool get loading => _loading;
  String? get error => _error;

  /// Récupère les stats depuis le backend
  Future<void> fetchStats() async {
    _setLoading(true);
    try {
      final response = await apiService.client.get('/stats/dashboard/');
      _stats = DashboardStats.fromJson(response.data);
      _error = null;
    } catch (e) {
      _error = 'Impossible de charger les statistiques';
    } finally {
      _setLoading(false);
    }
  }

  /// Exemple de méthode pour refresh périodiquement
  Future<void> refresh() => fetchStats();

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
