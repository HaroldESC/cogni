import 'package:cogni/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

/// Pantalla inicial de la aplicación.
///
/// En esta fase (F0) solo muestra el título y el subtítulo; el selector de
/// juegos se añadirá más adelante.
///
/// Accesibilidad (D-028):
/// - Los textos salen del ARB, nunca hay literales visibles.
/// - Sin alturas fijas: todo el layout se adapta a `textScaler`.
/// - D-028 pide `Semantics` en lo **interactivo**, y aquí no hay nada
///   interactivo: un `Text` ya publica su propio nodo semántico, así que
///   envolverlo en un `Semantics(label: ...)` solo duplicaría el anuncio del
///   lector de pantalla. Cuando aparezcan botones o el numpad, cada uno
///   llevará su `Semantics` con etiqueta y estado.
class HomeScreen extends StatelessWidget {
  /// Crea la pantalla inicial.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeTitle)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Sin `Semantics` envolvente: el `Text` ya se anuncia solo y un
            // `label` con el mismo texto lo leería dos veces.
            Text(
              l10n.homeSubtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
