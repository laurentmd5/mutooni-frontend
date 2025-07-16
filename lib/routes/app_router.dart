import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/ventes/ventes_screen.dart';
import '../screens/achats/achats_screen.dart';
import '../screens/clients/clients_screen.dart';
import '../screens/rh/rh_screen.dart';
import '../screens/rapports/rapports_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/transactions/transactions_screen.dart';
import '../screens/produits/produits_screen.dart';



final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    debugLogDiagnostics: true,

    redirect: (context, state) {
      // Correction du problème de paramètre monospaceUid
      final uri = state.uri;
      if (uri.queryParameters.containsKey('monospaceUid')) {
        final newUri = uri.replace(queryParameters: {});
        return newUri.toString();
      }

      final authState = ref.watch(authStateProvider);
      if (authState.isLoading || authState.hasError) return null;

      final isAuth = authState.valueOrNull != null;
      final isAuthRoute = ['/login', '/register'].contains(state.matchedLocation);

      if (!isAuth && !isAuthRoute) return '/login';
      if (isAuth && isAuthRoute) return '/';
      return null;
    },

    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (c, s) => MaterialPage(key: s.pageKey, child: const LoginScreen()),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        pageBuilder: (c, s) => MaterialPage(key: s.pageKey, child: const RegisterScreen()),
      ),
      GoRoute(
        path: '/',
        name: 'dashboard',
        pageBuilder: (c, s) => MaterialPage(key: s.pageKey, child: const DashboardScreen()),
      ),
      GoRoute(
        path: '/ventes',
        name: 'ventes',
        pageBuilder: (c, s) => MaterialPage(key: s.pageKey, child: const VentesScreen()),
      ),
      GoRoute(
        path: '/achats',
        name: 'achats',
        pageBuilder: (c, s) => MaterialPage(key: s.pageKey, child: const AchatsScreen()),
      ),
      GoRoute(
        path: '/produits',
        name: 'produits',
        pageBuilder: (c, s) => MaterialPage(key: s.pageKey, child: const ProduitsScreen()),
      ),
      GoRoute(
        path: '/clients',
        name: 'clients',
        pageBuilder: (c, s) => MaterialPage(key: s.pageKey, child: const ClientsScreen()),
      ),
      GoRoute(
        path: '/rh',
        name: 'rh',
        pageBuilder: (c, s) => MaterialPage(key: s.pageKey, child: const RhScreen()),
      ),
      GoRoute(
        path: '/rapports',
        name: 'rapports',
        pageBuilder: (c, s) => MaterialPage(key: s.pageKey, child: const RapportsScreen()),
      ),
      GoRoute(
        path: '/transactions',
        name: 'transactions',
        pageBuilder: (c, s) => MaterialPage(key: s.pageKey, child: const TransactionsScreen()),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        pageBuilder: (c, s) => MaterialPage(key: s.pageKey, child: const SettingsScreen()),
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Page non trouvée', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () => context.go('/'), child: const Text('Retour')),
          ],
        ),
      ),
    ),
  );
});