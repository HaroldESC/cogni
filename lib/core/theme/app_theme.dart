import 'package:flutter/material.dart';

/// Temas de la aplicación.
///
/// Se generan con Material 3 a partir de una única semilla de color para que
/// los tonos claros y oscuros mantengan la misma identidad visual.
///
/// El contraste **no se estima mirando** (§3.6): los pares de color que la
/// pantalla usa como texto se comprueban con una métrica WCAG en
/// `test/core/theme/app_theme_test.dart`, tanto en claro como en oscuro.
///
/// Nota: desde aquí no se filtran detalles de ningún juego concreto (D-001);
/// solo se define la paleta y los estilos globales.
class AppTheme {
  /// Tema claro.
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
  );

  /// Tema oscuro.
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: Brightness.dark,
    ),
  );
}
