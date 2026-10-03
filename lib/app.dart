import 'package:cogni/core/theme/app_theme.dart';
import 'package:cogni/features/home/presentation/home_screen.dart';
import 'package:cogni/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Tabla de rutas de la aplicación.
///
/// Es un `Provider` —una dependencia singleton según §6— y no un campo
/// `static final`: cada `ProviderScope`, incluidos los de los tests, crea su
/// propio `GoRouter` y lo destruye cuando el scope se deshace. Con un router
/// compartido en un `static`, su estado (pila de navegación, listeners)
/// se filtraba de un test al siguiente.
final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    routes: <RouteBase>[
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    ],
  );
  // Se libera junto con el scope: nada de listeners vivos entre tests.
  ref.onDispose(router.dispose);
  return router;
});

/// Raíz de la aplicación.
///
/// Configura MaterialApp.router con `go_router` (D-025) y engancha la
/// localización generada desde el ARB (D-027). El idioma de la app es el
/// español; el título se genera con `onGenerateTitle` porque en el
/// constructor todavía no existe un `BuildContext` con las localizaciones.
class CogniApp extends ConsumerWidget {
  /// Crea la raíz de la aplicación.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      routerConfig: ref.read(routerProvider),
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // Los delegates de Material/Cupertino/Widgets son necesarios además de
      // los de la app: sin ellos Material cae al inglés (D-027).
      localizationsDelegates: const <LocalizationsDelegate<Object?>>[
        ...AppLocalizations.localizationsDelegates,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
    );
  }
}
