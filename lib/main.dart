import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dio/dio.dart'; // Import pour DioException
import 'firebase_options.dart';
import 'routes/app_router.dart';
import 'core/app_theme.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(const ProviderScope(child: MutooniApp()));
}

class MutooniApp extends ConsumerWidget {
  const MutooniApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (error, stackTrace) {
        // Gestion des erreurs Dio
        String errorMessage = 'Erreur : $error';
        if (error is DioException) {
          errorMessage = 'Erreur réseau: ${error.message}';
          if (error.response != null) {
            errorMessage += '\nStatus: ${error.response?.statusCode}';
          }
        }
        
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(body: Center(child: Text(errorMessage))),
        );
      },
      data: (user) {
        final goRouter = ref.watch(goRouterProvider);

        return MaterialApp.router(
          title: 'Mutooni ERP',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.light,
          routerConfig: goRouter,
          builder: (context, child) => ResponsiveBreakpoints.builder(
            child: child!,
            breakpoints: [
              const Breakpoint(start: 0, end: 450, name: MOBILE),
              const Breakpoint(start: 451, end: 800, name: TABLET),
              const Breakpoint(start: 801, end: 1920, name: DESKTOP),
              const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
            ],
          ),
        );
      },
    );
  }
}