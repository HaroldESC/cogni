import 'package:cogni/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Contraste WCAG 2.1 AA para el tema (D-028, §3.6).
///
/// §3.6 es tajante: el contraste **no se «estima mirando», se comprueba**.
/// Este test es la comprobación de la paleta de `AppTheme`, en claro y en
/// oscuro, para los pares de color que la app usa como texto:
///
/// - ≥ 4.5:1 es el requisito AA de texto normal (WCAG 1.4.3);
/// - el cálculo usa la luminancia relativa de cada color.
///
/// El par `onSurface`/`background` de la propuesta original no se incluye
/// porque `ColorScheme.background` está deprecado desde Flutter 3.18: en
/// Material 3 su equivalente vivo es `surface`, ya cubierto arriba.
///
/// Es un test puro, sin `pump`, porque no toca `BuildContext` ni assets.
void main() {
  final schemes = <String, ColorScheme>{
    'claro': AppTheme.light.colorScheme,
    'oscuro': AppTheme.dark.colorScheme,
  };

  for (final entry in schemes.entries) {
    final name = entry.key;
    final scheme = entry.value;

    group('Tema $name', () {
      final pairs = <String, (Color, Color)>{
        'onSurface sobre surface': (scheme.onSurface, scheme.surface),
        'onSurfaceVariant sobre surface': (
          scheme.onSurfaceVariant,
          scheme.surface,
        ),
        'onSurface sobre surfaceContainerHighest': (
          scheme.onSurface,
          scheme.surfaceContainerHighest,
        ),
        'onPrimary sobre primary': (scheme.onPrimary, scheme.primary),
        'onSecondary sobre secondary': (scheme.onSecondary, scheme.secondary),
        'onTertiary sobre tertiary': (scheme.onTertiary, scheme.tertiary),
        'onError sobre error': (scheme.onError, scheme.error),
      };

      for (final pair in pairs.entries) {
        final colors = pair.value;

        test('${pair.key} cumple AA (≥ 4.5:1)', () {
          final first = colors.$1.computeLuminance();
          final second = colors.$2.computeLuminance();
          final light = first > second ? first : second;
          final dark = first > second ? second : first;
          final ratio = (light + 0.05) / (dark + 0.05);

          expect(
            ratio,
            greaterThanOrEqualTo(4.5),
            reason:
                'Contraste ${ratio.toStringAsFixed(2)}:1 en el tema $name '
                'para ${pair.key}; por debajo de AA para texto normal.',
          );
        });
      }
    });
  }
}
