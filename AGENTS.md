# `AGENTS.md` — Guía operativa para agentes y humanos

> Guía operativa para quien toca código en Cogni (agentes o humanos). **No sustituye** a `docs/DOCUMENTACION.md`: ese es la fuente única de verdad. **Regla de precedencia:** si algo de este documento contradice a `docs/DOCUMENTACION.md`, **gana `DOCUMENTACION.md`** y hay que **corregir `AGENTS.md`**. Las decisiones están numeradas (`D-0XX`) y **no se renumeran**: si el código cita `D-017`, esa referencia es estable.
>
> **Referencias:** en este documento, `§N` (o `§N.M`) apunta a una sección de `docs/DOCUMENTACION.md`, y `D-0XX` a una fila de su §2. Los números de sección de `AGENTS.md` no tienen nada que ver con los de la doc.

---

## 1. Qué es Cogni

App de **entrenamiento cognitivo gamificado**, local y de código abierto. Framework de juegos desde el día uno (D-001), con dos juegos iniciales: **memorización de π** y **cálculo mental**. Escritorio primero (Windows/Linux/macOS, D-007); Android es futuro. Sin backend, sin cuentas, sin sync en v1 (D-010).

Documentación completa: `docs/DOCUMENTACION.md`.
Registro de cambios de funcionalidades: `docs/progress.md`.

---

## 2. Stack (no improvisar)

| Capa | Elección |
|---|---|
| UI | Flutter (stable), escritorio primero |
| Estado | `flutter_riverpod` + `riverpod_annotation` (`@riverpod`) |
| Navegación | `go_router` (D-025) |
| Persistencia | `drift` + `drift_dev` (sin `sqlite3_flutter_libs`, D-034) |
| Codegen | `build_runner` |
| Identidad global | `uuid` (v4, client-generated) |
| Rutas de ficheros | `path` + `path_provider` (`app.db`, auto-copia de backup) |
| Motor de juego | Flutter puro (sin Flame en v1, D-006) |
| L10n | `gen_l10n` (ARB) + `flutter_localizations` (D-027) |
| Lint | `very_good_analysis` (D-026), `flutter analyze --fatal-infos` |
| Testing | `flutter_test` + `test` + `crypto` (solo `dev_dependencies`) |

Antes de añadir una dependencia: comprobar §4 de la doc y, si no está, **proponer la
decisión** antes de codificar.

---

## 3. Estructura de carpetas

```text
lib/
├── main.dart              # bootstrap: ProviderScope, precarga de secuencias, DB, runApp
├── app.dart               # MaterialApp.router, tema
├── core/                  # utilidades sin reglas de negocio (theme, timing, input, utils)
├── framework/             # núcleo genérico (Game, Session, DigitSequence, Progression, events)
├── data/
│   ├── db/                # @DriftDatabase, tablas, conexión
│   ├── dao/               # consultas concretas
│   ├── sequences/         # implementaciones de DigitSequence sobre assets
│   └── repositories/      # único punto que habla con Drift
├── features/
│   ├── home/
│   ├── settings/
│   ├── pi_memory/{domain,application,presentation}/
│   └── mental_sums/{domain,application,presentation}/
├── shared/widgets/        # numpad iluminado, botones, tarjetas
└── l10n/                  # app_es.arb → AppLocalizations
```

Fuera de `lib/` (lo que un agente suele necesitar):

```text
assets/sequences/   # *.txt, 1 byte por dígito; integridad en test/data/sequences/
test/               # framework/ · features/*/domain/ · data/
tool/               # generate_sequences.dart (se ejecuta a mano, no en el build)
docs/               # DOCUMENTACION.md (fuente de verdad) · progress.md
```

Reglas de dependencia (no negociables):

- `framework/` y `core/` **no** importan de `features/`. Al revés sí.
- Los **widgets no importan `data/`**: solo hablan con providers de su feature (§6).
- Los **notifiers no tocan Drift**: solo repositorios (§3.1).
- **Un solo `ProviderScope`** en `main.dart`; overrides solo en tests.

---

## 4. Reglas que un agente NO puede violar

Si crees que hay que cambiar alguna, **propón la decisión** (fila nueva en §2 de
`DOCUMENTACION.md`) antes de tocar código.

1. **Sin condicionales por juego.** Nada de `if (game == 'pi')`. Cada juego implementa el
   contrato `Game`; el framework no conoce sus detalles. (D-001, §3.1)
2. **Lógica pura separada de la UI.** `features/*/domain/` y `framework/` no importan
   Flutter ni leen `assets/`. Tests con `dart test` puro. (§3.1, §7)
3. **Los tests de `domain/`/`framework/` no leen assets.** Usan `FakeDigitSequence` o un
   `Uint8List` montado en el test. La integridad del asset real se testea aparte en
   `test/data/sequences/`. (§3.4)
4. **`status` de sesión tiene 3 valores: `active` | `completed` | `abandoned`.**
   **No existe `paused`** y no debe añadirse. Pausar es estado en memoria del session
   engine y **no escribe nada en la DB**. (D-017, §5.2)
5. **A lo sumo una sesión `active` por `(game_id, mode)`.** Lo impone un índice único
   **parcial** de SQLite declarado con `@TableIndex.sql`. No delegar al repositorio. Si un
   merge/import trae dos activas, **degradar al perdedor a `abandoned` antes de escribir**.
   (D-019, §5.2, §5.4.2)
6. **Los archivos generados se commitean y no se editan a mano.**
   `*.g.dart`, `*.drift.dart`, `*.steps.dart` van al repo. Se regeneran con
   `build_runner`. CI falla si `git diff --exit-code` deja diffs tras regenerar. (D-018)
7. **Identidad global desde la primera migración.** `game_sessions.uuid` (UUID v4
   client-generated, es la PK), `(game_id, mode)` como clave natural en `game_progress`,
   `key` en `settings`. `updated_at DATETIME NOT NULL` y `deleted_at DATETIME?` en toda
   tabla sincronizable. Borrados = tombstones, nunca `DELETE` físico. (D-015, §5.4)
8. **Un solo punto de escritura.** Solo los repositorios tocan Drift y generan `uuid` /
   escriben `updated_at` / `deleted_at`. Ni widgets ni notifiers. (§3.1, §5.3)
9. **Entrada normalizada en presentation.** El dominio solo ve *acciones* (`digit`,
   `backspace`, `confirm`, `cancel`), jamás `KeyEvent` ni distingue numpad de teclado.
   (§3.5, D-023)
10. **Cero literales visibles en widgets.** Todo texto va al ARB (`lib/l10n/app_es.arb`) y
    se lee con `AppLocalizations`. (§3.6, D-027) **Sin emojis en la UI** (D-030).
11. **Accesibilidad no es un extra.** `Semantics` en lo interactivo, `textScaler`
    respetado, sin alturas fijas, contraste AA verificado, no depender solo del color.
    (D-028, §3.6)
12. **El progreso del jugador se protege por encima de todo.** Migraciones versionadas,
    nunca borrar la DB. Import con confirmación + auto-copia previa. Export antes de
    import. (§5.1, §5.5)
13. **Persistencia solo en momentos clave:** `checkpoint alcanzado`, `sesión completada`,
    `app en background`. Nada de escribir en cada dígito. `app en background` es
    *best-effort*: si el proceso muere antes (kill, cuelgue, apagón), se retoma desde el
    último estado persistido, no desde la posición exacta. (§5.2)
14. **Errores con `developer.log`, nunca `print`.** Tres zonas, no intercambiables (§7):
    1. Arranque → `runZonedGuarded` en `main()` (cubre la precarga de secuencias).
    2. Framework → `FlutterError.onError`.
    3. Global → `PlatformDispatcher.onError`.
15. **Precarga de secuencias antes de `runApp`** (`assets/sequences/*.txt` vía `rootBundle`,
    D-021). Si `pi.txt` falta o está corrupto, el fallo debe ser legible al arrancar, no un
    `RangeError` al llegar al dígito 4.000.

---

## 5. Workflow de desarrollo

```bash
# setup inicial
flutter pub get

# tras añadir tabla Drift o @riverpod:
dart run build_runner watch --delete-conflicting-outputs

# antes de cada commit (debe quedar sin diff):
dart run build_runner build --delete-conflicting-outputs
git diff --exit-code

# formato y análisis:
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos

# tests:
flutter test

# ejecutar en escritorio:
flutter run -d windows    # o -d linux / -d macos

# build de distribución:
flutter build windows     # / linux / macos
```

**Antes de proponer un PR, un agente debe verificar como mínimo:** formato, `analyze
--fatal-infos`, `flutter test`, y que regenerar no deja diffs. Eso es exactamente lo que
hace CI (`.github/workflows/ci.yml`, §4 de la doc).

---

## 6. Registro de progreso

Al finalizar cada tarea, genera un resumen **en español** y añade una entrada al final de
`docs/progress.md` con este formato:

```markdown
### Nombre tarea (versión en la que se está trabajando)
**Fecha:** YYYY-MM-DD
**Resumen:** (2-3 frases de lo logrado)
**Archivos creados:**
- ruta/archivo.dart
**Archivos modificados:**
- ruta/archivo.dart
**Tests:** X/Y pasando
**Notas:** (si hay algo relevante; decisiones nuevas → añadir fila en §2 de DOCUMENTACION.md)
```

---

## 7. Convención de commits

Los commits se escriben **siempre en inglés** (D-029). El asunto tiene este formato:

```text
tipo(scope opcional): Descripción en imperativo
```

- **Tipo** (minúscula): `feat` | `fix` | `docs` | `style` | `refactor` | `test` | `chore` |
  `perf`.
- **Scope** (opcional, minúscula): zona afectada — p. ej. `pi_memory`, `data`, `ci`.
- **Descripción**: empieza en mayúscula, en imperativo ("Add", no "Added"), sin punto final.
- **Asunto completo:** máximo 50 caracteres.

Ejemplos:

```bash
git commit -m "feat(pi_memory): Add keyboard input"
git commit -m "fix(data): Stop writing position on every digit"
git commit -m "chore: Regenerate Drift code"
```

- **Cuerpo** (opcional):
  - Separado del asunto por una línea en blanco.
  - Máximo 72 caracteres por línea.
  - Usar imperativo (ej. "Add" no "Added").

**Tipos de commit**:

- `feat`: nueva funcionalidad
- `fix`: corrección de bug
- `docs`: cambios en documentación (incluye `docs/DOCUMENTACION.md` y `docs/progress.md`)
- `style`: cambios de formato (espacios, punto y coma, etc.)
- `refactor`: refactorización de código
- `test`: añadir o modificar tests
- `chore`: tareas de mantenimiento, build, dependencias (incluye regenerar codegen y actualizar `*.g.dart`)
- `perf`: mejora de rendimiento

**Branching — GitHub Flow (D-031).** `main` es la única rama permanente.

- `main` siempre verde: formato + `analyze --fatal-infos` + `flutter test` + codegen sin
  diffs (§5). Nada se integra roto.
- Sin `develop` ni ramas de release. Las ramas de trabajo son cortas y se borran al mergear:
  `tipo/descripcion-en-kebab` — p. ej. `feat/pi-keyboard`, `fix/active-session-index`.
- Trabajando en solitario: un cambio pequeño y local puede ir directo a `main`; usa rama
  cuando toques varias áreas o quieras que CI actúe de puerta antes de integrar.
- Integra con **squash** para que cada tarea deje un commit y cuadre con `docs/progress.md`.

**Regla crítica**: el commit **nunca** debe incluir archivos generados desactualizados.
Regenera primero y comprueba `git diff --exit-code`.

---

## 8. Subagentes

**Modo de planificación:**

- **Nunca des por supuesto el diseño, el stack ni las funcionalidades.** Todo está en `DOCUMENTACION.md`; si no está, pregunta.
- Usa subagentes de análisis profundo para investigar cuando haga falta.
- Usa subagentes especializados para revisar los distintos aspectos del plan antes de presentarlo al usuario.
- Respeta el roadmap (§8): no implementes features de fases futuras si la fase actual no está cerrada.

**Modo de edición:**

- **Nunca modifiques por ti mismo cuando sea posible**: delega en subagentes.
- Identifica cambios paralelizables del plan y repártelos entre subagentes.
- Cuando uses subagentes para implementar, actúa **únicamente como coordinador**.
- Objetivo: mantener legibilidad, controlar la ventana de contexto y el límite de visualización del historial.

**Manejo de errores:**

- Si encuentras un error o hay varias opciones sobre cómo proceder, **repórtalo o pregunta de inmediato**. Mejor preguntar que adivinar, salvo indicación explícita en sentido contrario para una tarea o sesión concreta.
- **No inventes decisiones.** Si algo no está cubierto por `DOCUMENTACION.md` ni por el usuario, detente y pregunta. Las decisiones nuevas se registran como `D-0XX` en §2 antes de implementarlas.

---

## 9. Gotchas

- **Codegen**: olvidar `build_runner` tras tocar Drift o `@riverpod` deja el proyecto sin compilar o con salidas obsoletas. CI lo detecta con `git diff --exit-code` (D-018).
- **Precarga de secuencias (D-021)**: si `pi.txt` falta o está corrupto, el fallo debe ser legible al arrancar (`runZonedGuarded`), no un `RangeError` al llegar al dígito 4.000.
- **Índice parcial de sesión activa (D-019)**: SQLite rechaza dos sesiones `active` para el mismo `(game_id, mode)`. En import/sync, degradar a `abandoned` **antes** de escribir (§5.4.2).
- **`game_progress.unlocked_up_to`** está acotado por `DigitSequence.length`: al leer, aplicar `min(unlocked_up_to, length)`. El asset **solo crece**.
- **`id` de secuencia ≠ `game_id`**: `'pi'` ≠ `'pi_memory'`. No guardar el id de secuencia en `game_id`.
- **Pausa (D-017)**: no añadir `paused` al enum de `status`. Es una máquina de 3 estados.
- **`deleted_at IS NULL`** en el índice parcial: la restricción cubre solo filas vivas; un tombstone de sesión activa libera el hueco sin cambiar `status`.
- **Escritorio primero (D-007)**: Android no es v1. No añadir plugins que rompan el build de escritorio.
- **`flutter_localizations`** es necesaria desde F0 aunque `gen_l10n` venga con Flutter: sin ella, Material cae al inglés (D-027).
- **Código generado**: los `*.g.dart` traen `// GENERATED CODE - DO NOT MODIFY BY HAND`; los `*.drift.dart`/`*.steps.dart` no traen cabecera, así que la regla se ancla en el prefijo, no en una cabecera universal.

---

## 10. Cómo añadir un juego nuevo

Para que el framework cumpla su promesa (D-001):

1. Copiar `features/<juego>/` desde uno existente (`pi_memory` o `mental_sums`).
2. Implementar el contrato `Game` en `domain/` (identidad, validación, checkpoints, datos de progreso).
3. Registrar en el selector de `features/home/`.
4. Reutilizar `shared/widgets/` (numpad, botones) — **no** duplicar.
5. Si necesita una secuencia de datos, añadir su `DigitSequence` en `data/sequences/` y su asset en `assets/sequences/`, con su test de integridad en `test/data/sequences/`.

**No** debe hacer falta tocar `framework/`, `core/` ni `data/db/` para añadir un juego.

---

## 11. Qué NO hacer sin discutirlo antes

- Añadir `paused` a `status` o persistir en pausa (D-017).
- Leer assets desde `domain/` o desde tests de `domain/`/`framework/`.
- Meter `if (game == ...)` en `framework/` o en `core/`.
- Escribir en Drift desde un notifier o un widget.
- Editar un archivo generado a mano.
- Cambiar el contrato `DigitSequence` sin actualizar sus tests de integridad.
- Añadir dependencias grandes (Flame, paquetes de gráficas, backend) sin registrar antes la decisión en §2.
- Introducir literales visibles en widgets o emojis en la UI (D-027, D-030).
- Implementar features de fases futuras sin cerrar la fase actual (§8).
- Proceder con decisiones pendientes (abiertas) para la tarea o fase sin consultar.

---

## 12. Roadmap (resumen)

| Fase | Contenido |
| ---- | --------- |
| **F0 — Setup** | Proyecto Flutter escritorio, tooling y CI. Criterios en §8.1 |
| **F1 — Datos** | Tablas Drift con `uuid`/`updated_at`/`deleted_at` de entrada, conexión escritorio, repositorios (incl. export/import), seeds |
| **F2 — Framework** | `Game`, motor de sesiones, progreso/checkpoints, eventos, `DigitSequence` |
| **F3 — Juego π** | UI + numpad + teclado, validación, checkpoint=20, guardado y retoma. Asset `pi.txt` + test de integridad + botones Exportar/Importar |
| **F4 — Juego sumas** | Rondas con velocidad/dificultad; valida que el framework es reutilizable |
| **F5 — Métricas** | Tiempos de respuesta, tasas, gráficas y estadísticas por juego |
| **F6 — Logros** | `AchievementManager` escuchando eventos |
| **F7 — Distribución** | Instaladores Windows/Linux/macOS |

**Fuera de alcance por ahora**: cuentas, nube, sync, ranking online, Android, sistema social, más de dos juegos, Flame.

---

## 13. Documentación y cierre de sesión

- **Fuente de verdad:** `docs/DOCUMENTACION.md`.
- **Registro de progreso:** `docs/progress.md`.
- Toda decisión nueva → **fila nueva en §2** de `DOCUMENTACION.md` con ID correlativo, estado (`✅ Decidido` o `⚠️ Pendiente`), y las secciones afectadas actualizadas.
- Una decisión tomada **no se renumera**: los IDs son referencias estables.
- Las preguntas abiertas viven en §9 de la doc; si tu tarea depende de una, **no improvises**: párate y propón cerrarla antes.
- **Antes de terminar la sesión**, al finalizar cada tarea, **pregunta al usuario** si desea hacer el commit de los cambios. Recuerda: regenerar codegen antes y comprobar `git diff --exit-code`.

---

> Este `AGENTS.md` es deliberadamente operativo. Si algo de aquí contradice a `docs/DOCUMENTACION.md`, **gana el documento largo** y hay que **corregir este archivo**.