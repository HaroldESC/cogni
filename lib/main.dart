import 'dart:async';
import 'dart:developer' as developer;

import 'package:cogni/app.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Punto de entrada de la aplicación.
///
/// Los errores se reportan con `developer.log`, nunca con `print` (regla 14 de
/// AGENTS.md). Las tres zonas no son intercambiables:
///
/// 1. **Arranque**: el `runZonedGuarded` cubre lo que ocurre antes de
///    `runApp` (por ejemplo, la precarga de secuencias desde `assets/`, D-021).
///    Si `pi.txt` falta o está corrupto, el fallo es legible aquí y no un
///    `RangeError` al llegar al dígito 4.000.
/// 2. **Framework**: `FlutterError.onError` captura los errores de
///    construcción de widgets y los presenta por consola sin perder el
///    reporte completo.
/// 3. **Global**: `PlatformDispatcher.onError` recoge los errores no
///    controlados que escapan del árbol de widgets.
///
/// Un único `ProviderScope` vive aquí; los overrides son solo para tests.
Future<void> main() async {
  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Zona 2: errores del framework de widgets.
      FlutterError.onError = (details) {
        developer.log('FlutterError: ${details.exception}', name: 'cogni');
        FlutterError.presentError(details);
      };

      // Zona 3: errores no controlados del proceso.
      PlatformDispatcher.instance.onError = (error, stackTrace) {
        developer.log('Uncaught: $error', name: 'cogni');
        return true;
      };

      runApp(const ProviderScope(child: CogniApp()));
    },
    // Zona 1: errores durante el arranque, antes de `runApp`.
    (error, stackTrace) {
      developer.log('Zone: $error', name: 'cogni');
    },
  );
}
