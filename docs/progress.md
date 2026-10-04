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

---

### Cierre de F1 — capa de datos completa (A1 + A2 + backup)
**Fecha:** 2026-10-03
**Resumen:** Fase F1 completada y cerrada: esquema Drift v1 con identidad global, DAOs, los tres repositorios como único punto de escritura, backup export/import con auto-copia (D-035) y su validación estricta (D-037). Revisión independiente (`reviewer`) sin blockers; sus findings se corrigieron todos antes de cerrar.
**Archivos creados:**
- lib/data/db/tables/game_progress.dart, game_sessions.dart, settings.dart
- lib/data/db/app_database.dart, lib/data/db/connection.dart
- lib/data/dao/game_progress_dao.dart, game_sessions_dao.dart, settings_dao.dart
- lib/data/repositories/game_session_repository.dart, game_progress_repository.dart, settings_repository.dart, backup_codec.dart, backup_repository.dart
- lib/data/providers.dart
- test/data/db/app_database_test.dart, test/data/helpers/test_database.dart
- test/data/repositories/game_session_repository_test.dart, game_progress_repository_test.dart, settings_repository_test.dart, backup_codec_test.dart, backup_repository_test.dart
**Archivos modificados:**
- lib/data/dao/settings_dao.dart (upsert por companion; permite reactivar tombstones con `deletedAt: Value(null)`)
- docs/DOCUMENTACION.md (§2 D-033…D-037, §4 stack, §5.2/§5.4.1/§5.5, §8 fila F1, §8.2 criterios, §9 fila 7)
- AGENTS.md (§2 stack: sin `sqlite3_flutter_libs`, `path` + `path_provider`)
- build.yaml (`store_date_time_values_as_text`, D-033), pubspec.yaml (drift 2.35.1, path, path_provider, uuid)
**Tests:** 57/57 pasando (15 de F0 + 23 de esquema/DAOs + 19 de repositorios)
**Notas:** Puerta completa en verde: `dart format` 0 cambios, `flutter analyze --fatal-infos` 0 issues, `flutter test` 57/57, `build_runner` sin diffs en generados (D-018), `flutter build windows` compila (Release). Nuevas decisiones de la fase: D-033 (fechas ISO-8601 UTC), D-034 (sin `sqlite3_flutter_libs`), D-035 (`BackupCodec`/`BackupRepository`), D-036 (`settings` como JSON), D-037 (import estricto: duplicados y negativos rechazados antes de escribir). Correcciones post-revisión: `record` atómico en transacción (monotonía §5.4.2 verificada con un probe: sin transacción la escritura se perdía), `_decode` con `FormatException` en vez de `TypeError`, desempate por UUID en el degradado de activas duplicadas. Quedan para F3 los botones de Ajustes y la confirmación explícita del import (§5.5/§8.2).
