import 'package:cogni/app.dart';
import 'package:cogni/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pruebas de widget de la pantalla inicial.
///
/// Arranca la app completa (router + localizaciones, D-027) con el sistema de
/// tipografía al doble de tamaño y comprueba que:
///
/// - el idioma efectivo es el español y los textos visibles coinciden con lo
///   generado desde el ARB, sin literales sueltos en el widget;
/// - la pantalla se construye sin desbordes ni excepciones de layout, porque
///   el layout se adapta a `textScaler` en lugar de fijar alturas (D-028).
void main() {
  testWidgets('arranca en español y no desborda a escala x2', (tester) async {
    // Escalado x2 (D-028): el caso que rompe los layouts con alturas fijas.
    // `clearAllTestValues` restaura el valor original al terminar el test,
    // de modo que no se filtra a los siguientes.
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearAllTestValues);

    await tester.pumpWidget(const ProviderScope(child: CogniApp()));
    await tester.pumpAndSettle();

    // Los literales que se buscan en pantalla tienen que ser los mismos que
    // produce el ARB: si divergen, o el widget está hardcodeando texto o la
    // localización no está enganchada.
    final l10n = await AppLocalizations.delegate.load(const Locale('es'));
    expect(l10n.homeTitle, 'Cogni');
    expect(l10n.homeSubtitle, 'Entrenamiento cognitivo');

    expect(find.text('Cogni'), findsWidgets);
    expect(find.text('Entrenamiento cognitivo'), findsOneWidget);

    // Cualquier desbordamiento de RenderFlex o error de render en la
    // pantalla inicial se propaga como excepción y deja el test en rojo.
    expect(tester.takeException(), isNull);
  });
}
