import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_service.dart';

class LocalStorageService {
  static const _jwtKey = 'jwt';

  Future<void> writeJwt(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_jwtKey, value);
  }

  Future<String?> readJwt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_jwtKey);
  }

  Future<void> deleteJwt() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_jwtKey);
  }
}

final _storage = LocalStorageService();

/*─────────────── ÉTAT UTILISATEUR ────────────────*/
final authStateProvider = StreamProvider<User?>(
  (ref) => FirebaseAuth.instance.authStateChanges().distinct(),
);

final userProvider = Provider<User?>(
  (ref) => ref.watch(authStateProvider).valueOrNull,
);

final isAuthenticatedProvider = Provider<bool>(
  (ref) => ref.watch(userProvider) != null,
);

/*─────────────── AUTH CONTROLLER ────────────────*/
class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController(this.ref) : super(const AsyncData(null));
  final Ref ref;
  final _auth = FirebaseAuth.instance;

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    try {
      // 1. Authentification Firebase
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      final idToken = await _auth.currentUser!.getIdToken();
      
      // 2. Échange contre JWT Django
      final dio = ref.read(apiServiceProvider).client;
      final res = await dio.post(
        '/auth/firebase/',
        data: {'id_token': idToken}, // Format spécifique attendu par Django
      );
      
      // 3. Stockage du JWT Django
      final accessToken = res.data['access'] as String;
      await _storage.writeJwt(accessToken);
      
      state = const AsyncData(null);
    } on FirebaseAuthException catch (e, st) {
      state = AsyncError(e.message ?? 'Erreur d\'authentification', st);
    } catch (e, st) {
      state = AsyncError('Erreur inconnue: $e', st);
    }
  }

  Future<void> signUp({required String email, required String password}) async {
    state = const AsyncLoading();
    try {
      // 1. Création utilisateur Firebase
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final idToken = await _auth.currentUser!.getIdToken();
      print('🔥 TOKEN: $idToken'); // Ajouté pour déboguer
      
      // 2. Échange contre JWT Django
      final dio = ref.read(apiServiceProvider).client;
      final res = await dio.post(
        '/auth/firebase/',
        data: {'id_token': idToken}, // Format spécifique attendu par Django
      );
      
      // 3. Stockage du JWT Django
      final accessToken = res.data['access'] as String;
      await _storage.writeJwt(accessToken);
      
      state = const AsyncData(null);
    } on FirebaseAuthException catch (e, st) {
      state = AsyncError(e.message ?? 'Erreur de création', st);
    } catch (e, st) {
      state = AsyncError('Erreur inconnue: $e', st);
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    await _auth.signOut();
    await _storage.deleteJwt();
    state = const AsyncData(null);
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<void>>(
  (ref) => AuthController(ref),
);