# Registro de progreso — Cogni

> Una entrada por tarea terminada, **al final** del archivo. El formato está en AGENTS.md
> §6. Las decisiones nuevas **no** van aquí: van a §2 de docs/DOCUMENTACION.md.

Este archivo no se poda: es el historial de lo que se ha hecho y cuándo.

<!-- Añadir nuevas entradas debajo de esta línea. -->

### F0 — Setup: proyecto Flutter escritorio, tooling y CI
**Fecha:** 2026-10-02
**Resumen:** Proyecto Flutter 3.47.6 (escritorio windows/linux/macos, org `com.cogni`) con el andamiaje completo de §3.3, arranque con `MaterialApp.router` + `go_router` y localización en español desde `app_es.arb` (D-027), lint `very_good_analysis` y pipeline de CI (§4) que ejecuta `flutter gen-l10n` antes del chequeo de codegen (D-032).
**Archivos creados:**
- pubspec.yaml, pubspec.lock, analysis_options.yaml, l10n.yaml, .gitattributes, .gitignore, .github/workflows/ci.yml
- lib/main.dart, lib/app.dart, lib/core/theme/app_theme.dart
- lib/features/home/presentation/home_screen.dart
- lib/l10n/app_es.arb, lib/l10n/generated/app_localizations.dart, lib/l10n/generated/app_localizations_es.dart
- test/features/home/home_screen_test.dart
- test/core/theme/app_theme_test.dart
- 21 carpetas de §3.3 con `.gitkeep` (core/{timing,input,utils}, framework, data/{db,dao,sequences,repositories}, features/settings, features/{pi_memory,mental_sums}/{domain,application,presentation}, shared/widgets, assets/sequences, tool, test/{framework,features,data})
**Archivos modificados:**
- docs/DOCUMENTACION.md (§2 fila D-032, §4 pipeline con `gen-l10n`, §8.1 nota de estado)
- README.md (reemplaza la plantilla de `flutter create` por una descripción real)
- analysis_options.yaml (deja de excluir `lib/l10n/generated/**` para que D-026 cubra el generado)
- pubspec.yaml (descripción con acentos)
**Tests:** 15/15 pasando
**Notas:** Flutter 3.47.6 / Dart 3.13.5 instalado en `C:\src\flutter` (PATH de usuario vía `setx`); Visual Studio Build Tools 2022 para compilar escritorio (D-007). `flutter analyze --fatal-infos` 0 incidencias, `dart format` estable, codegen sin diffs. `synthetic-package` eliminado de `l10n.yaml` porque está obsoleto y crashea en Flutter 3.47.6 → D-032.

Tras revisión independiente (`reviewer`) se corrigieron: router `static final` → `routerProvider` (patrón §6, evita fuga de estado entre tests), `Semantics` redundante sobre el `Text` (duplicaba el anuncio; D-028 aplica a lo interactivo) y doc comment del tema que prometía contraste AA sin comprobarlo — ahora se comprueba en `test/core/theme/app_theme_test.dart` (14 pares, claro y oscuro, ≥ 4.5:1; el par con `background` se omitió porque `ColorScheme.background` está deprecado desde Flutter 3.18).

**Pendientes para cerrar F0:** ninguno. El arranque (§8.1.2) se verificó con `flutter build windows --debug` y ejecutando el binario, y la pipeline de §4 está **passing** en GitHub Actions sobre `main` (§8.1.6). F0 marcada como cerrada en §8.

