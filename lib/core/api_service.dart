import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ApiService {
  static const _defaultBaseUrl = 'http://192.168.61.131:8000/api';

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: const String.fromEnvironment('API_BASE_URL', defaultValue: _defaultBaseUrl),
        connectTimeout: const Duration(seconds: 15), // Timeout augmenté
        receiveTimeout: const Duration(seconds: 15),
        responseType: ResponseType.json,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Configuration des intercepteurs
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            // Récupération du JWT
            final prefs = await SharedPreferences.getInstance();
            final token = prefs.getString('jwt');
            
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
              log('🔑 JWT injecté: ${token.substring(0, 15)}...');
            } else {
              log('⚠️ Aucun JWT trouvé');
            }
            
            // Logs détaillés
            log('🌐 ${options.method} ${options.uri}');
            log('📦 Headers: ${options.headers}');
            if (options.data != null) {
              log('📤 Body: ${options.data}');
            }
            
            return handler.next(options);
          } catch (e) {
            log('❌ Erreur interceptor: $e');
            return handler.next(options);
          }
        },
        onResponse: (response, handler) {
          // Log de succès
          log('✅ ${response.statusCode} ${response.requestOptions.uri}');
          log('📥 Response: ${response.data}');
          return handler.next(response);
        },
        onError: (e, handler) {
          // Log d'erreur détaillé
          log('⛔ ERREUR DIO: ${e.type}');
          log('💬 Message: ${e.message}');
          log('🔗 URL: ${e.requestOptions.uri}');
          log('🧾 Request Headers: ${e.requestOptions.headers}');
          log('🧾 Response Headers: ${e.response?.headers}');
          log('📝 Response Data: ${e.response?.data}');
          
          return handler.next(e);
        },
      ),
    );
  }

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;
  Dio get client => _dio;
}

final apiService = ApiService();
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());