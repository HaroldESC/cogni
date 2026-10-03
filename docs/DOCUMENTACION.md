# Cogni — Documentación técnica y decisiones

> **Documento central del proyecto.** Aquí se concentra el estado actual de las decisiones
> técnicas, la arquitectura, el modelo de datos y el roadmap.
>
> - Las decisiones ya tomadas se marcan ✅.
> - Lo que sigue abierto se marca ⚠️ **Pendiente de decisión**.

---

## 1. Resumen del producto

**Cogni** es una aplicación de **entrenamiento cognitivo gamificado**,
local y de código abierto, que nace con dos minijuegos:

1. **Memorización de π** (secuencia de dígitos, checkpoints, numpad iluminado y teclado
   físico).
2. **Cálculo mental** (sumas, rondas con velocidad y dificultad).

### Decisión de alcance

✅ **Se construye un framework de juegos de entrenamiento, no un juego suelto.**

Núcleo genérico (`Game`, `Sesión`, `Progreso`, `Estadísticas`, `Logros`) desde el día uno;
π y sumas son los dos primeros juegos que lo implementan. Añadir un juego nuevo no debe
requerir modificar media aplicación.

Árbol de evolución previsto:

```text
Memorización            Cálculo                 Álgebra / Trigo / etc (futuro)
├── π                   ├── sumas               ├── ecuaciones
├── e                   ├── restas              ├── seno / coseno
├── √2                  ├── multiplicaciones    └── ...
├── fracciones           ├── divisiones
└── raíces               └── operaciones combinadas
```

---

## 2. Registro de decisiones

> Las decisiones se agrupan **por área**. Los **ID no se renumeran** —se citan en §3-§10—, así
> que los huecos entre grupos son normales: cada grupo contiene solo lo suyo.

### Producto y alcance

| ID | Tema | Decisión | Estado |
|---|---|---|---|
| D-001 | Framework vs juego simple | Framework de juegos desde el inicio | ✅ Decidido |
| D-007 | Plataforma v1 | **Escritorio primero** (Windows/Linux/macOS); Android es futuro | ✅ Decidido |
| D-010 | Backend / nube / cuentas | **No en la v1.** Todo local, sin autenticación | ✅ Decidido |
| D-012 | Nombre del producto | "Cogni" | ✅ Decidido |

### Stack y tooling

| ID | Tema | Decisión | Estado |
|---|---|---|---|
| D-002 | Stack de UI | **Flutter** (Dart, una sola base de código) | ✅ Decidido |
| D-003 | Gestión de estado | **Riverpod** | ✅ Decidido |
| D-005 | Code generation | **Sí**: `drift_dev` + `riverpod_generator` vía `build_runner` | ✅ Decidido |
| D-018 | Archivos generados | `*.g.dart`, `*.drift.dart`, `*.steps.dart` **se commitean** y **nunca** se editan a mano; los `*.g.dart` conservan `// GENERATED CODE - DO NOT MODIFY BY HAND` y CI comprueba que regenerar no deja diffs | ✅ Decidido |
| D-022 | Integridad de los assets | **SHA-256 en test** (`test/data/sequences/`, nunca en runtime) + `crypto` en `dev_dependencies`; complementa a `length`/prefijo/rango | ✅ Decidido |
| D-025 | Navegación | **`go_router`**: rutas declarativas y back de escritorio ya resueltos; Navigator 2.0 a mano no compensa (§4) | ✅ Decidido |
| D-026 | Linter | **`very_good_analysis`**: más estricto y ya alineado con el estilo que describe este documento | ✅ Decidido |
| D-029 | Convención de commits | **`tipo(scope opcional): Descripción`** en inglés, imperativo, asunto ≤ 50 y cuerpo ≤ 72; tipos `feat`/`fix`/`docs`/`style`/`refactor`/`test`/`chore`/`perf`. Detalle operativo en `AGENTS.md` §7 | ✅ Decidido |
| D-031 | Branching | **GitHub Flow** con `main` como única rama permanente y siempre verde; ramas de trabajo cortas `tipo/descripcion`, sin `develop`. Detalle en `AGENTS.md` §7 | ✅ Decidido |
| D-032 | l10n generado | **`lib/l10n/generated/` se versiona** (no es `package:flutter_gen`; la opción `synthetic-package` está obsoleta y es crasheante en Flutter ≥ 3.47). `flutter gen-l10n` se ejecuta en CI **antes** de `git diff --exit-code`, para que un ARB y su Dart divergentes rompan el pipeline. Complementa a D-018 y D-027 | ✅ Decidido |

### Datos y persistencia

| ID | Tema | Decisión | Estado |
|---|---|---|---|
| D-004 | Persistencia | **Drift** (sobre SQLite) | ✅ Decidido |
| D-008 | Tablas iniciales en Drift | Mínimas: `game_progress`, `game_sessions`, `settings` | ✅ Decidido |
| D-011 | Base de datos | SQLite embebido (`app.db`), sin servidor | ✅ Decidido |
| D-015 | Sincronización futura | Capa de datos **diseñada** para sync: identidad global (UUID donde no hay clave natural), `updated_at` + `deleted_at` obligatorios y política de conflictos en §5.4. La sync en sí sigue fuera de alcance | ✅ Decidido (diseño) |
| D-017 | Pausa de sesión | **No es un estado persistido**: `status` mantiene 3 valores (`active`/`completed`/`abandoned`) y pausar es estado en memoria (§5.2) | ✅ Decidido |
| D-019 | Invariantes en el esquema | Las restricciones clave (`(game_id, mode)` único; **una sola sesión `active`**) se declaran en el esquema con índices — el parcial con `@TableIndex.sql` — y no se delegan al repositorio | ✅ Decidido |
| D-020 | Fuente de las secuencias (π, e, √2) | **Asset `.txt`** por secuencia (`assets/sequences/`) bajo el contrato `DigitSequence` (§3.4). A, C, D y E descartadas — análisis en §9.1 | ✅ Decidido |
| D-021 | Carga de las secuencias | **Precarga en `main.dart`** antes de `runApp`: el controlador recibe un `DigitSequence` resuelto y su código queda síncrono; fallo legible al arrancar. Plan B (`AsyncValue`) documentada en §3.4 | ✅ Decidido |
| D-024 | Backup del progreso | **Export a JSON** versionado desde Ajustes; **import en v1 = *restaurar*** (con confirmación y auto-copia). *Fusionar* dos imports ⚠️ futuro (§5.5) | ✅ Decidido |

### Juegos y features

| ID | Tema | Decisión | Estado |
|---|---|---|---|
| D-006 | Motor de juego | **Flutter puro** (sin Flame en la v1) | ✅ Decidido |
| D-009 | Checkpoints por defecto en π | `checkpoint_every = 20` dígitos (configurable) | ✅ Decidido |
| D-013 | Logros | Se **diseñan** ahora (eventos desacoplados), se **implementan** después | ⚠️ Pendiente |
| D-016 | Dependencias de terceros para gráficas | Por definir cuando se llegue a la fase de métricas | ⚠️ Pendiente |

### Interacción, idiomas y accesibilidad

| ID | Tema | Decisión | Estado |
|---|---|---|---|
| D-023 | Entrada de usuario | **Numpad iluminado + teclado físico** (desktop-first): la UI normaliza a acciones de dominio y el dominio no distingue el origen (§3.5) | ✅ Decidido |
| D-027 | Internacionalización | **`gen_l10n` (ARB) + `flutter_localizations` desde F0** — cero literales en widgets y sin caer al inglés de Material. Las APIs de `intl` (plurales, formatos) no se usan hasta el primer idioma distinto del español (§3.6) | ✅ Decidido |
| D-028 | Accesibilidad | No es un extra: contraste AA en claro/oscuro, escalado de texto respetado, `Semantics` en lo interactivo y test de escalado en la primera pantalla (§3.6) | ✅ Decidido |
| D-030 | Emojis en la UI | **No se usan**: la UI usa iconos de Material o SVG propios. El renderizado de un emoji depende de la fuente del sistema y no es consistente entre plataformas | ✅ Decidido |

> **D-014** (placeholder de «paquete de navegación») se cerró con **D-025**. No se renumera el
> resto del registro: los IDs son referencias estables.

### Motivos cortos de las decisiones clave

- **Flutter** → multiplataforma real (escritorio nativo + Android futuro), UI rica y
  personalizada (numpad, animaciones), un solo lenguaje, ecosistema `pub.dev` abierto.
- **Riverpod** → dependencias explícitas, testeado sin mocks de `BuildContext`, soporte
  nativo de código generado (`@riverpod`), escala bien a muchas pantallas y juegos.
- **Drift** → SQLite con **consultas tipadas, migraciones versionadas y codegen**; ideal
  porque el progreso del jugador es dato relacional (progreso ↔ sesiones ↔ ajustes) y las
  migraciones protegen el progreso del usuario en actualizaciones futuras.
- **Flutter puro (sin Flame)** → memorización y cálculo no necesitan física ni entidades:
  basta `AnimatedContainer`, `Ticker` y `Stopwatch`. Flame queda como opción si algún juego
  futuro lo necesita.

---

## 3. Arquitectura

### 3.1. Principios

1. **Sin condicionales por juego.** Nada de `if game == PI`. Cada juego implementa un
   contrato; el sistema general no conoce sus detalles.
2. **Lógica pura separada de la UI.** Toda la lógica de juego (validar entrada, calcular
   puntuación, aplicar checkpoints) vive en clases sin dependencias de Flutter ni de
   `assets/` → testeable con `dart test` puro. Los dígitos entran por contrato
   (`DigitSequence`), nunca leyéndose el asset desde el dominio (§3.4).
3. **Un único centro de persistencia.** Solo los repositorios hablan con Drift. Ni widgets
   ni notifiers tocan la base de datos directamente.
4. **El tiempo manda.** `Stopwatch` como fuente de verdad del tiempo de juego; `Ticker` /
   `AnimationController` solo para refrescar la UI.
5. **Diseñar para crecer, implementar lo mínimo.** Se modelan (en la doc) logros, perfiles y
   sync, pero no se codifican hasta que hagan falta.

### 3.2. Piezas del framework

```text
                    ┌─────────────────────┐
                    │   App / Router /    │
                    │   Settings / Theme  │
                    └──────────┬──────────┘
                               │
              ┌────────────────┴────────────────┐
              │                                 │
      ┌───────▼────────┐               ┌────────▼───────┐
      │ _framework_    │               │   _data_       │
      │ Game contract  │               │ AppDatabase    │
      │ Session engine │◄──────────────┤ DAOs           │
      │ DigitSequence  │               │ Repositories   │
      │ Progression    │               │ Sequences      │
      │ Game events    │               └────────────────┘
      └───────┬────────┘
              │ implementado por
   ┌──────────┼──────────────┐
   │          │              │
┌──▼───────┐ ┌▼───────────┐ ┌▼──────────┐
│ pi_memory│ │ mental_sums│ │ (futuros) │
└──────────┘ └────────────┘ └───────────┘
```

- **`Game` (contrato):** identidad, UI de juego, reglas de entrada/validación — sobre
  **acciones ya normalizadas**, da igual si vienen del numpad o del teclado físico (§3.5) —,
  definición de checkpoints y de qué datos de progreso necesita.
- **Session engine:** crea `Sesiones`, las divide en `Rondas` (ejercicios, velocidad,
  dificultad, puntuación, resultado) y gestiona el ciclo `iniciar → jugar → pausar →
  completar/abandonar`. El ciclo es del **estado en memoria** (`SessionState`, en
  `framework/session.dart`): lo que se persiste solo admite `active` | `completed` |
  `abandoned`, porque **pausar no es un estado guardado** (§5.2).
- **`DigitSequence` (contrato):** acceso aleatorio a los dígitos de una secuencia canónica
  (π, e, √2) sin saber de dónde salen: `id`, `length`, `digitAt(position)`. El contrato vive en
  `framework/` (agnóstico, igual que `Game`); la implementación vive en `data/` sobre un
  asset (§3.4). Es lo que permite que el motor de juego pida "el dígito 87" sin conocer
  el origen del dato.
- **Progression:** separa **progreso desbloqueado** (récord, etapas) de **partida actual**
  (posición, checkpoint) y aplica la política de checkpoints.
- **Game events:** emite hechos ("llegó a 50 dígitos", "10 rondas perfectas") que un futuro
  `AchievementManager` escuchará **sin que cada juego conozca los logros**.

### 3.3. Estructura de carpetas (feature-first)

```text
.github/workflows/ci.yml         # format + analyze + codegen + test (§4)
.gitattributes                   # *.g.dart = linguist-generated (§4)

assets/
└── sequences/                # secuencias canónicas: 1 dígito = 1 byte, sin separadores
    ├── pi.txt                # 10.000 dígitos
    ├── e.txt                 # (futuro)
    └── sqrt2.txt             # (futuro)

lib/
├── main.dart                    # bootstrap: ProviderScope, precarga de secuencias, DB, runApp
├── app.dart                     # MaterialApp, router, tema
│
├── core/                        # utilidades transversales y sin reglas de negocio
│   ├── theme/                   # colores, tipografía, animaciones base
│   ├── timing/                  # fuentes de tiempo (Stopwatch wrapper, Ticker)
│   ├── input/                   # KeyEvent → acciones de dominio (§3.5)
│   └── utils/
│
├── l10n/                        # ARB (app_es.arb) → AppLocalizations (D-027)
│
├── framework/                   # núcleo genérico de juegos (NO conoce ningún juego)
│   ├── game.dart                # contrato Game
│   ├── session.dart             # Sesión, Ronda, estados
│   ├── sequence.dart            # contrato DigitSequence (§3.4)
│   ├── progression.dart         # checkpoints y desbloqueos
│   └── events.dart              # eventos para logros futuros
│
├── data/
│   ├── db/
│   │   ├── app_database.dart    # @DriftDatabase (entry point)
│   │   ├── tables/              # tablas Drift
│   │   └── connection.dart      # apertura de app.db (sqlite3 ffi en escritorio)
│   ├── dao/                     # consultas concretas
│   ├── sequences/               # DigitSequence sobre assets/ (§3.4)
│   └── repositories/            # API de dominio que usan los notifiers
│
├── features/
│   ├── home/                    # pantalla inicial / selector de juegos
│   ├── settings/                # ajustes (checkpoint_every, velocidades, etc.)
│   ├── pi_memory/
│   │   ├── domain/              # lógica pura: validación de entrada, checkpoints
│   │   ├── application/         # providers @riverpod (estado de la partida)
│   │   └── presentation/        # pantallas y widgets propios del juego
│   └── mental_sums/
│       ├── domain/
│       ├── application/
│       └── presentation/
│
└── shared/
    └── widgets/                 # numpad iluminado, botones, tarjetas reutilizables

test/
├── framework/                   # tests del motor de sesiones y progreso
├── features/
│   └── pi_memory/domain/        # tests puros de la lógica de π
└── data/                        # repositorios en memoria + integridad de assets/ (§3.4)

tool/
└── generate_sequences.dart      # regenera assets/sequences/; a mano, no forma parte del build

docs/
├── DOCUMENTACION.md             # este archivo (fuente única de verdad)
└── progress.md                  # registro de tareas terminadas (AGENTS.md §6)
```

Notas:

- `framework/` y `core/` **no** importan de `features/`; al revés sí está permitido.
- `assets/sequences/` se declara en `pubspec.yaml`; `tool/` solo se ejecuta a mano, nunca
  como parte del build normal (§3.4).
- `shared/widgets/numpad` es candidato a subirse a `core/` si lo usan ≥ 2 juegos.
- Cada `features/<juego>/` es autocontenido: para clonar un juego nuevo se copia la carpeta
  y se registra en el selector.

### 3.4. Secuencias de dígitos (assets)

π, e y √2 son **datos**, no código: no se calculan en runtime ni viven en la base de datos.
Cada secuencia es un archivo de texto plano, cargado una sola vez y expuesto por contrato.

```text
assets/
└── sequences/
    ├── pi.txt        # 10.000 dígitos, sin separadores, sin salto final
    ├── e.txt         # (futuro)
    └── sqrt2.txt     # (futuro)
```

**Formato:** solo caracteres `0`-`9`; sin `\n`, sin comas, sin espacios. Un separador
complica `digitAt(position)` a cambio de nada: nadie va a leer el archivo a ojo, y con un
byte por dígito el acceso queda en O(1) con ~10 KB en memoria.

**Cantidad inicial:** 10.000 dígitos ≈ 10 KB. Cubre a prácticamente cualquier aficionado
(el récord mundial de memorización ronda los 70.000, fuera del alcance de un juego local).
Si algún día hace falta más, se sustituye el asset — no se reimplementa nada (D-020).

**Contrato genérico** — pieza del núcleo, tan agnóstico como `Game`:

```dart
// lib/framework/sequence.dart
abstract class DigitSequence {
  String get id;               // 'pi', 'e', 'sqrt2'
  int get length;
  int digitAt(int position);   // 0..9, throw RangeError si fuera de rango
}
```

El `id` de la secuencia **no** es el `game_id` (`'pi'` ≠ `'pi_memory'`): son identificadores
de cosas distintas, y es el `Game` el que declara qué secuencia usa. Nada guarda el `id` de
la secuencia en `game_id`.

**Implementación por defecto:**

```dart
// lib/data/sequences/asset_digit_sequence.dart
class AssetDigitSequence implements DigitSequence {
  AssetDigitSequence(this.id, this._digits);
  @override final String id;
  final Uint8List _digits;
  @override int get length => _digits.length;
  @override int digitAt(int position) => _digits[position] - 0x30;
}
```

El **loader** (no el constructor) valida que `length > 0` y que todos los bytes están en
`0x30..0x39`, y falla al arrancar con un error legible. Sin esa validación, un `\n` final
se convierte en un dígito negativo y el problema aparece cuando el jugador llega al dígito
4.000, no al abrir la app.

**Convención de posiciones:** `digitAt(0)` es el primer dígito. `game_sessions.position`
cuenta **dígitos ya introducidos** (`0` = ninguno), de modo que el siguiente en mostrar es
`digitAt(position)` y el último mostrado, `digitAt(position - 1)`. Una sola regla, escrita
aquí, para que no haya un off-by-one entre `framework/`, `domain/` y la UI.

**Carga — D-021: precarga en `main.dart`.** El asset se declara en `pubspec.yaml` y se
lee con `rootBundle` **una vez, antes de `runApp`**, desde un provider de `data/` (nunca de
`features/`). `PiSessionController` recibe un `DigitSequence` **ya resuelto** y su código
queda **síncrono**: validación de entrada, cálculo de checkpoint, retoma. Razones:

- Es un dato estático, pequeño y **siempre necesario**: ~10 KB y, desde que existe F3, hay
  un juego que lo usa. No es un recurso pesado ni perezoso.
- Evita modelar `AsyncLoading` en el controlador para algo que debe estar en memoria antes
  de pintar la primera pantalla: la secuencia es requisito para jugar, no un estado de UI.
- Hace deterministas los tests de widget: el árbol arranca con la dependencia disponible,
  sin bombear `AsyncValue` ni simular `rootBundle`.
- **Fallar pronto es mejor que fallar tarde:** si `pi.txt` falta o está corrupto, hay un
  error legible en el arranque (`runZonedGuarded` → diálogo), no un `RangeError` en el
  dígito 4.000 ni un spinner eterno en una pantalla secundaria.
- Coste: milisegundos. Leer 10 KB y validar rangos de bytes es despreciable.

**Plan B (documentada, no usada):** el controlador recibe un
`AsyncValue<DigitSequence>` en lugar de un valor resuelto. Solo se activa si el catálogo
lo justifica — decenas de secuencias con carga diferida, no tres archivos de 10 KB (�7).

**Tests.** Los tests de `domain/` y `framework/` **nunca leen `assets/`**: reciben un
`FakeDigitSequence` o un `Uint8List` construido en el test.

La integridad del asset publicado se testea **aparte**, en
`test/data/sequences/pi_test.dart`: es lo que evita que un archivo mal recortado pase
desapercibido hasta el dígito 4.000. Cuatro comprobaciones:

1. `length == 10000`.
2. Primeros 100 dígitos contra una constante escrita **en el test** (no leída del asset).
   El literal va agrupado por 10 para contrastarlo a ojo con la fuente; en la comparación
   se quitan los espacios, porque el asset no los tiene:

   ```dart
   const piGrouped = '1415926535 8979323846 2643383279 5028841971 6939937510 '
       '5820974944 5923078164 0628620899 8628034825 3421170679';
   final expected = piGrouped.replaceAll(' ', '');

   expect(txt.substring(0, expected.length), expected);
   ```

3. Todos los bytes en `'0'..'9'` (detecta separadores y basura).
4. **SHA-256** del archivo completo contra una constante (D-022).

   ```dart
   // crypto va en dev_dependencies. El hash se calcula una sola vez al añadir el
   // asset, se pega aquí y a partir de ahí vive en el repo: si el .txt cambia a
   // propósito, se actualiza la constante a mano.
   const piSha256 = '<hash calculado una sola vez>';

   expect(sha256.convert(bytes).toString(), piSha256);
   ```

   Es **solo un test, nunca runtime**: no se valida el hash al cargar el asset.

El test lee el archivo **desde disco** (`File('assets/sequences/pi.txt')`), no con
`rootBundle`: es un test de datos, no de Flutter, y así no necesita binding.

**Qué cubre cada cosa.** `length` detecta recortes; el prefijo detecta un archivo
equivocado o desplazado; el rango detecta separadores y basura. Los tres **se quedan
aunque esté el hash**, porque diagnostican: dicen «hay un byte `0x0A` en la posición 1234»,
mientras que el SHA-256 solo diría «el hash no cuadra». El hash aporta lo que a los otros
tres se les escapa: un dígito alterado en la posición 6.000.

**Cómo se genera:** un script en `tool/` (Dart puro o shell) que produce el `.txt` desde
una fuente fiable y **se commitea junto con el resultado**. No forma parte del build
normal: se ejecuta a mano cuando se quiera ampliar. En el propio script se documenta la
fuente (p. ej. "primeros 10.000 dígitos de π de Project Gutenberg / OEIS / cálculo propio
verificado").

### 3.5. Entrada: numpad y teclado físico (D-023)

La v1 es **desktop-first** (D-007) y lo normal es teclear con el teclado físico, no con el
ratón. El numpad iluminado es la UI de juego, **no la única vía**: ambos se soportan desde
el primer juego, para no rehacer la entrada cuando llegue Android.

**Regla:** la entrada se **normaliza en presentation** y el dominio solo ve *acciones*.
Jamás un `if (origen == teclado)` en `domain/` ni en `framework/`.

```text
KeyEvent (Flutter) ─┐
                   ├──→ normalizador (core/input/) ──→ acción ──→ Game / controlador
Tocado en numpad ──┘
```

Acciones mínimas y su mapeo de teclado:

| Acción | Teclado físico |
|---|---|
| `digit(0..9)` | Fila superior `0`-`9` **y** bloque `Keypad0`-`Keypad9` |
| `backspace` | `Backspace` |
| `confirm` | `Enter` / `Space` |
| `cancel` (con confirmación) | `Escape` |

Lo que decide que esto sea cómodo y no un puente a medio construir:

- **Las dos filas de dígitos cuentan**, bloque numérico incluido: en desktop se usan
  indistintamente y una app que ignora `Keypad4` se siente rota.
- **Foco:** el juego toma foco al entrar y lo suelta cuando hay un diálogo (Ajustes, pausa,
  confirmación); si no, `Escape` cierra dos cosas a la vez.
- El numpad iluminado y el teclado llaman **al mismo callback**: si el numpad acepta un
  dígito, el teclado también. Por eso la frontera son las acciones y no los `KeyEvent` —
  un test de dominio no debe poder notar la diferencia.
- `mental_sums` pide números de varias cifras: mismas acciones (`digit`, `backspace`,
  `confirm`); lo que cambia es la validación, que es del juego.

### 3.6. Internacionalización y accesibilidad

**Textos — D-027.** En la v1 solo hay español, pero el andamiaje entra **en F0**: todo
literal visible va en `lib/l10n/app_es.arb` y se lee con `AppLocalizations`. Escribir el
literal dentro de un widget es deuda que se paga en **cada** pantalla nueva.

**`flutter_localizations` sí entra en F0**, aunque `gen_l10n` venga en el propio Flutter: el
`app_localizations.dart` generado expone un `localizationsDelegates` que incluye
`GlobalMaterialLocalizations`, `GlobalCupertinoLocalizations` y `GlobalWidgetsLocalizations`,
y esos delegados **son** `flutter_localizations`. Sin el paquete no existen, y Material cae
al inglés por defecto en tooltips, `SelectableText` y diálogos
(`MaterialLocalizations.of`), aunque toda la app esté en español. Es una línea en
`pubspec.yaml` y evita mezclar idiomas en la UI del sistema.

**`intl` no se usa en F0**: llega igualmente como dependencia transitiva de
`flutter_localizations`, pero ninguna parte del código depende de sus APIs (plurales,
`DateFormat`, `NumberFormat`) hasta que haya un idioma distinto del español (§9). Empezar a
usarlas entonces es barato si el ARB ya está montado; al revés cuesta mucho más.

**Accesibilidad — D-028.** No es un extra del final; son decisiones de diseño que se
toman ahora o se pagan como deuda:

- **Contraste:** paleta sobre `ColorScheme` de Material 3, verificada en claro **y**
  oscuro — ≥ 4.5:1 en texto normal y ≥ 3:1 en texto grande y bordes de componentes
  (WCAG AA). El contraste no se «estima mirando»: se comprueba.
- **Escalado de texto:** nada de alturas fijas ni de multiplicar fuentes a mano; todo pasa
  por `Theme.textTheme` y se respeta `textScaler`. El numpad y las tarjetas aguantan ×2 sin
  desbordarse, y eso se testea.
- **Semántica:** todo widget interactivo con etiqueta (`Semantics`), incluidos los botones
  del numpad (dígito + nombre) y sus estados (`activa`, `bloqueado`).
- **No solo color:** un dígito fallido se marca con icono o texto además del rojo —
  depender de rojo/verde es el fallo clásico de accesibilidad cromática.
- **Sin emojis (D-030):** la UI usa iconos de Material o SVG propios, no emojis; su
  renderizado depende de la fuente del sistema y cambia entre plataformas.
- **Teclado:** todo es navegable con teclado físico en escritorio (converge con §3.5).
- **Tests de a11y:** la primera pantalla con
  `tester.platformDispatcher.textScaleFactorTestValue = 2.0`, y una comprobación de contraste
  en el tema.

**Qué significa esto en F0:** `gen_l10n` configurado, `very_good_analysis` en
`analysis_options.yaml` (D-026) y **un** test de escalado de texto en la primera pantalla
que exista. No es una fase de accesibilidad: es no dejar que se acumule.

---

## 4. Stack técnico

| Capa | Elección | Comentario |
|---|---|---|
| Framework | Flutter (stable) | Escritorio primero |
| Lenguaje | Dart | |
| Estado | `flutter_riverpod` + `riverpod_annotation` | Código generado (`@riverpod`) |
| Navegación | `go_router` | Rutas declarativas y back de escritorio ya resueltos (D-025) |
| Localización | `gen_l10n` (ARB) + `flutter_localizations` | `intl` solo cuando haya un 2º idioma (D-027) |
| Persistencia | `drift` + `drift_dev` + `sqlite3_flutter_libs` | SQLite embebido |
| Codegen | `build_runner` | Un solo comando para ambas cosas |
| Identidad global | `uuid` (paquete pub) | UUID v4 client-generated para sync (D-015) |
| Motor de juego | Flutter puro | Flame excluido de la v1 |
| Testing | `flutter_test` + `test` + `crypto` | Lógica pura con `test`; `crypto` solo en `dev_dependencies` (SHA-256 de assets, D-022) |
| Linting | `very_good_analysis` | Estricto y coherente con el estilo del doc; `analyze --fatal-infos` en CI (D-026) |

### Workflow de desarrollo

```bash
# tras añadir una tabla Drift o un @riverpod:
dart run build_runner watch --delete-conflicting-outputs

# antes de commitear: regenerar y comprobar que no queda nada sin generar (D-018)
dart run build_runner build --delete-conflicting-outputs
git diff --exit-code

# tests
flutter test

# ejecutar en escritorio
flutter run -d windows    # o -d linux / -d macos

# build de distribución
flutter build windows     # / linux / macos
```

> **Regla (D-018): los archivos generados se commitean.** `*.g.dart`, `*.drift.dart` y
> `*.steps.dart` van al repo (**no** al `.gitignore`) y **nunca** se editan a mano: se
> regeneran con `build_runner`.
> Motivo: el output canónico queda fijado en el repo, de modo que una versión distinta de
> `build_runner` / `drift_dev` / `riverpod_generator` se manifiesta como **diff real y
> revocable** sobre ese canónico (regeneras o igualas versiones), en vez de artefactos
> distintos en cada máquina que nadie llega a ver. Acompaña a `pubspec.lock` commiteado
> (convención en apps Flutter): mismas versiones, mismo output.
>
> **Cabecera "no tocar":** los `*.g.dart` ya la traen de serie —
> `// GENERATED CODE - DO NOT MODIFY BY HAND`, tanto en drift_dev como en
> `riverpod_generator` — y se conserva tal cual. Ojo con el resto de salidas de drift:
> `schema.dart` usa `// GENERATED CODE, DO NOT EDIT BY HAND.` y `*.drift.dart` /
> `*.steps.dart` **no traen cabecera** (empiezan por `// dart format width=80`); al ser
> generadas no se les puede "añadir" a mano, porque la regeneración las pisa. Por eso la
> regla se ancla en el prefijo `*.g.dart` y no en una cabecera universal.
>
> **En los PR** no se revisan línea a línea: se comprueba que el diff del código fuente y
> el de lo generado cuentan la misma historia.
>
> **En CI (F0):** `dart run build_runner build --delete-conflicting-outputs` y después
> `git diff --exit-code` → el pipeline falla si alguien cambia código sin regenerar, o si
> regenera con otra versión. Complemento en `.gitattributes`:
> `*.g.dart linguist-generated=true` (GitHub pliega esos diffs en el PR).

### CI (GitHub Actions)

Una sola pipeline en `.github/workflows/ci.yml`, que hace exactamente lo mismo que el
workflow local de arriba (F0):

```yaml
name: CI
on:
  push: { branches: [main] }
  pull_request:

jobs:
  analyze-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true
      - run: flutter pub get

      # D-027/D-032: el l10n generado se versiona; falla si el ARB y el
      # código Dart generado dejan de coincidir
      - run: flutter gen-l10n

      # D-018: si lo generado no está al día con el código, falla aquí
      - run: dart run build_runner build --delete-conflicting-outputs
      - run: git diff --exit-code

      - run: dart format --output=none --set-exit-if-changed .
      - run: flutter analyze --fatal-infos
      - run: flutter test
```

Tres detalles, que es donde esta pipeline se gana o se pierde:

1. **`--fatal-infos`** (`flutter analyze`, no `build_runner`): `very_good_analysis` trata los
   lints como errores (D-026), así que si el analyze solo falla con *warnings* deja pasar
   justo lo que el linter señala. Ojo con el nombre: `build_runner` **no** tiene
   `--fail-on-severe`; su equivalente en esta pipeline es el `git diff --exit-code`.
2. **`git diff --exit-code`** es lo que delata una versión divergente de `build_runner`: el
   diff sale en el repo y es visible, en vez de que cada máquina genere algo distinto en
   silencio (D-018).
3. **Build de escritorio, opcional y en job aparte:** `flutter build linux --release` con
   `clang`/`ninja`/`libgtk-3-dev` vía `apt`. Windows y macOS no compilan en un runner
   Linux, así que ese job es un extra, no la puerta de calidad del código.

Además, el mismo `git diff --exit-code` cubre el l10n: como
`lib/l10n/generated/` se versiona (D-032), si alguien cambia `app_es.arb` sin regenerar,
`flutter gen-l10n` deja un diff que rompe la pipeline.

### Versionado y releases (planificado para F7)

⚠️ Enfoque propuesto; se confirma en F7 (§9, fila 4). No se implementa antes.

Sitio canónico para la versión`pubspec.yaml`:

- **Fuente única de verdad:** `version: MAYOR.MENOR.PARCHE+BUILD` en `pubspec.yaml`. El
  toolchain (escritorio, Android) y los instaladores la leen de ahí; **no** se duplica en
  constantes Dart ni en otros archivos.
- **SemVer:** pre-1.0 hasta la primera release pública (F7 → `1.0.0`).
- **Build number (`+N`):** entero que **siempre crece**, aunque no cambie el SemVer (lo
  necesitan Android y los instaladores). El bump lo sube siempre.
- **UI «Acerca de»:** `package_info_plus` (Windows/Linux/macOS/Android/iOS/Web) lee la
  versión del **binario** en runtime, no de un literal. Ojo: no llamar
  `PackageInfo.fromPlatform()` antes de `runApp()` (puede lanzar); va en un provider.
- **`CHANGELOG.md`** con formato *Keep a Changelog*: cada bump añade
  `## [x.y.z] - YYYY-MM-DD`; el cuerpo de la GitHub Release se extrae de esa sección.
- **`tool/bump_version.dart`** (Dart puro, junto a `generate_sequences.dart`): recibe
  `major|minor|patch|build`, actualiza `pubspec.yaml`, exige/crea la entrada del CHANGELOG y,
  opcionalmente, hace el commit `chore(release): Bump version to x.y.z` + tag `vX.Y.Z`. Al
  ser `pubspec.yaml` la fuente única, el script toca **un** archivo, no cinco.
- **CI de release (job aparte, F7):** disparado por tag `v*`, compila instaladores y publica
  la GitHub Release con la sección del CHANGELOG. La pipeline de arriba (PR/push) no cambia.
- **Badge del README:** si se pone, que sea dinámico (release/tag de GitHub), no un número
  hardcodeado que el script deba reemplazar.

---

## 5. Modelo de datos (Drift)

### 5.1. Base de datos

- Archivo local `app.db` en el directorio de datos de la app (escritorio).
- SQLite embebido vía Drift; **sin servidor, sin cuentas, sin sincronización** en la v1.
- **Preparado para sync (D-015):** toda tabla sincronizable lleva identidad global
  (UUID o clave natural), `updated_at` y `deleted_at` desde su primera migración. Añadir
  esas columnas *después* obligaría a migrar datos ya instalados; añadirlas *ahora* no
  cuesta nada (§5.4).
- Todas las migraciones se hacen con el sistema versionado de Drift
  (`schemaVersion` + `onUpgrade`), nunca borrando la base de datos: **el progreso del
  jugador se protege por encima de todo**.

### 5.2. Tablas de la primera versión (decisión D-008)

Solo tres tablas. El esquema completo (logros, perfiles, estadísticas agregadas) se añade
en fases posteriores con migración.

```text
app.db
├── game_progress     # progreso durable: qué ha desbloqueado y sus récords
├── game_sessions     # historial + partida en curso (la activa = partida actual)
└── settings          # ajustes clave-valor (checkpoint_every, velocidades, tema...)
```

#### `game_progress` — lo desbloqueado

Una fila por (juego, modo). Responde a: *"¿hasta dónde ha llegado el jugador?"*

| Columna | Tipo | Descripción |
|---|---|---|
| `id` | `INTEGER PK` | autogenerado; **surrogate local** (no es la identidad global, D-015) |
| `game_id` | `TEXT` | identificador estable del juego (`"pi_memory"`, `"mental_sums"`) |
| `mode` | `TEXT NOT NULL DEFAULT 'default'` | modo de entrenamiento; permite modos futuros sin romper datos |
| `unlocked_up_to` | `INTEGER NOT NULL DEFAULT 0` | siguiente umbral desbloqueado, **en dígitos** (π: 120); avanza en bloques de `checkpoint_every` (D-009) |
| `best_score` | `INTEGER NOT NULL DEFAULT 0` | mejor puntuación |
| `updated_at` | `DATETIME NOT NULL` | última actualización (obligatoria para sync, D-015) |
| `deleted_at` | `DATETIME?` | *tombstone*: `NULL` = fila viva; nunca `DELETE` físico (D-015) |

> **Unique:** `(game_id, mode)` — declarado con `@TableIndex(..., unique: true)` en §5.3;
> lo cumple SQLite, no el código (D-019).
>
> **Identidad global (D-015):** `(game_id, mode)` **es** la clave natural y ya es
> globalmente única, así que esta tabla **no** necesita uuid: la sync identifica la fila
> por esa pareja, nunca por `id` (`id` es un surrogate local). Si algún día hay perfiles,
> la clave natural pasa a `(profile_id, game_id, mode)`.

Ejemplo π: `unlocked_up_to = 120` con `best_score = 120`.

> **De dónde salen los dígitos:** la secuencia canónica **no** está en la base de datos —
> vive en `assets/sequences/` (§3.4). La DB solo guarda hasta dónde se ha llegado, y tanto
> `unlocked_up_to` como `game_sessions.position` están acotados por
> `DigitSequence.length`. Corolario: **el asset solo crece**. Si un PR lo redujera por
> debajo del progreso de un jugador existente, al leer se aplica
> `min(unlocked_up_to, length)`; y antes de que eso llegue a nadie, el test de integridad
> (`length == 10000`) falla en CI (§3.4).

#### `game_sessions` — partida en curso e histórico

Una fila por sesión jugada. La fila con `status = 'active'` **es** la partida actual: si la
app se cierra ordenadamente en el dígito 87, esa fila sobrevive y se retoma mañana (ver
*Durabilidad* al final de esta subsección para el caso de cierre abrupto).

| Columna | Tipo | Descripción |
|---|---|---|
| `uuid` | `TEXT PK` | **UUID v4 generado en cliente** antes del insert; identidad global (D-015) |
| `game_id` | `TEXT` | igual que en `game_progress` |
| `mode` | `TEXT NOT NULL DEFAULT 'default'` | modo de juego |
| `status` | `TEXT NOT NULL` | `active` \| `completed` \| `abandoned` — **no hay `paused`** (ver nota) |
| `checkpoint` | `INTEGER NOT NULL` | último checkpoint alcanzado (π: 80) |
| `position` | `INTEGER NOT NULL` | posición actual (π: 87) |
| `score` | `INTEGER NOT NULL DEFAULT 0` | puntuación de la sesión |
| `state_json` | `TEXT?` | estado específico del juego en curso (JSON) |
| `started_at` | `DATETIME NOT NULL` | |
| `ended_at` | `DATETIME?` | `NULL` mientras está activa |
| `updated_at` | `DATETIME NOT NULL` | última modificación; base del **last-write-wins** (§5.4) |
| `deleted_at` | `DATETIME?` | *tombstone* de borrado distribuido (§5.4) |

> **Identidad global (D-015):** `game_sessions` **no** tiene clave natural, y un
> `INTEGER autoIncrement` solo es único dentro de un dispositivo. Por eso su PK **es** el
> `uuid` (texto, v4, generado en cliente): en cuanto haya sync no hace falta ninguna tabla
> de mapeo `local_id ↔ remote_id`. El orden cronológico se obtiene por `started_at`, no por la PK.

> **Regla de negocio:** a lo sumo **una** sesión `active` por `(game_id, mode)`. Al iniciar
> una nueva sesión, la activa anterior pasa a `abandoned` (o se retoma si existe).
>
> **Ojo en sync/import:** como esta regla la impone un índice parcial (abajo, D-019), un
> merge que traiga dos `active` para la misma pareja **debe** degradar al perdedor a
> `abandoned` *antes* de escribir; si no, SQLite rechaza la segunda. Es el paso previo
> obligatorio de la fila «Varias sesiones `active`» de §5.4.2, no una preferencia.
>
> **La garantiza SQLite, no solo el repositorio (D-019).** Un índice único **parcial**
> impone la regla a nivel de almacenamiento:
>
> ```sql
> CREATE UNIQUE INDEX idx_one_active_session
>   ON game_sessions (game_id, mode)
>   WHERE status = 'active' AND deleted_at IS NULL
> ```
>
> Declarado con `@TableIndex.sql` en §5.3. Así, una escritura concurrente o un bug del
> repositorio no pueden dejar dos activas: la segunda operación la rechaza SQLite antes de
> corromper la retoma. Va con `deleted_at IS NULL` porque la restricción debe cubrir **las
> filas vivas**, que son las que leen las consultas: de este modo, hacer *tombstone* de una
> sesión activa libera el hueco sin que nadie tenga que recordar que hay que cambiar
> `status` antes. (La versión corta `WHERE status = 'active'` solo sería válida si además
> se garantizara que una sesión activa nunca se borra sin pasar antes a `abandoned`.)
>
> **La pausa no se persiste (D-017).** Los únicos valores de `status` son
> `active` | `completed` | `abandoned`: **no existe `paused`** y no debe añadirse al enum.
> "Pausar" del ciclo `iniciar → jugar → pausar → …` (§3.2) es **estado en memoria** del
> session engine, y al pausar **no se escribe nada en la base de datos**: la fila sigue
> `active`, `position`/`checkpoint` no cambian y `updated_at` no se toca. Por eso cerrar la
> app con la sesión en pausa es indistinguible de cerrarla jugando — la fila `active`
> sobrevive y se retoma desde la última `position` **persistida** (87 solo si hubo cierre
> ordenado; ver *Durabilidad*, abajo). Si algún día hiciera falta
> saber que está "en pausa" (métricas de tiempo, sync), se expone como columna nueva o
> dentro de `state_json`, **nunca** ampliando el enum de `status`: `status` es una máquina
> de 3 estados con reglas de negocio encima ("solo una `active`"), y un cuarto valor las
> rompería.

**Ejemplo flujo π** (checkpoints cada 20, decisión D-009):

```text
Juega hasta 87  →  checkpoint 80, position 87, status active  →  se cierra la app
Pausa a mitad   →  NO se escribe nada: sigue active, position intacta (D-017)
Al reabrir      →  se lee la sesión active y se continúa en 87
Si pierde       →  la sesión sigue viva, pero position vuelve a checkpoint (80)
Al superar 100  →  game_progress.unlocked_up_to pasa de 100 a 120...
                    (nueva sesión opcional desde el bloque 120)
```

> **Durabilidad: el ejemplo vale para cierres ordenados.** El `87` sobrevive **si** el cierre
> dispara `AppLifecycleState.paused`/`detached` y se persiste ahí — en escritorio suele ser
> así, pero no siempre. Si el proceso **muere sin ese paso** —`kill -9`, cuelgue, apagón— la
> fila conserva la última `position` **persistida**, que normalmente es el último checkpoint
> (`80`), y se retoma desde ahí. Por eso la UI no debe prometer reanudación exacta: promete
> «vuelves a tu último checkpoint». El diseño no cambia; escribir en **cada** dígito
> multiplicaría I/O sin mejorar la experiencia, porque el checkpoint es la unidad de retoma.

#### `settings` — ajustes clave-valor

| Columna | Tipo | Descripción |
|---|---|---|
| `key` | `TEXT PK` | p. ej. `pi.checkpoint_every`; con namespacing es **clave global** (D-015) |
| `value` | `TEXT` | valor serializado (JSON/texto) |
| `updated_at` | `DATETIME NOT NULL` | |
| `deleted_at` | `DATETIME?` | *tombstone*; `NULL` = ajuste presente (§5.4) |

Semilla inicial:

| key | value | Nota |
|---|---|---|
| `pi.checkpoint_every` | `20` | D-009; ajustable por el usuario |
| `sums.initial_speed_ms` | `1000` | velocidad de la ronda 1 |
| `app.theme` | `"system"` | |

### 5.3. Esquema Drift (referencia)

> En Drift las columnas son **`NOT NULL` por defecto**: lo que debe admitir `NULL` se
> marca con `.nullable()`.

```dart
// lib/data/db/tables/game_progress.dart
import 'package:drift/drift.dart';

// Identidad global de la tabla: la pareja (gameId, mode) es la que viaja a sync,
// nunca `id` (D-015). El índice no solo documenta la restricción: la cumple SQLite
// (no se pueden insertar dos filas con el mismo juego+modo) (D-019).
@TableIndex(name: 'progress_game_mode', columns: {#gameId, #mode}, unique: true)
class GameProgress extends Table {
  IntColumn get id => integer().autoIncrement()(); // surrogate local (no viaja a sync)
  TextColumn get gameId => text()();
  TextColumn get mode => text().withDefault(const Constant('default'))();
  IntColumn get unlockedUpTo => integer().withDefault(const Constant(0))();
  IntColumn get bestScore => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()(); // tombstone (D-015)
}
```

```dart
// lib/data/db/tables/game_sessions.dart

// "A lo sumo una sesión active por (game_id, mode)" (§5.2) no se delega al repositorio:
// la impone un índice único PARCIAL (D-019). `@TableIndex.sql` acepta la sentencia
// completa, `WHERE` incluido, y `m.createAll()` (el `onCreate` por defecto de Drift)
// crea los índices junto con las tablas: no hace falta `customStatement` a mano.
//
// Si en una versión futura del esquema se añadiera este índice a una base ya existente,
// se crea en `onUpgrade`; y si ya hubiera dos filas activas, SQLite rechaza el índice,
// así que habría que resolver los duplicados antes de crearlo.
@TableIndex.sql('''
  CREATE UNIQUE INDEX idx_one_active_session
    ON game_sessions (game_id, mode)
    WHERE status = 'active' AND deleted_at IS NULL
''')
class GameSessions extends Table {
  // UUID v4 generado en el cliente ANTES del insert: es la PK y la identidad global.
  // Sin él, un autoIncrement solo sería único por dispositivo (D-015).
  TextColumn get uuid => text()();
  TextColumn get gameId => text()();
  TextColumn get mode => text().withDefault(const Constant('default'))();
  TextColumn get status => text()(); // active | completed | abandoned (sin paused, D-017)
  IntColumn get checkpoint => integer()();
  IntColumn get position => integer()();
  IntColumn get score => integer().withDefault(const Constant(0))();
  TextColumn get stateJson => text().nullable()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()(); // base del last-write-wins (§5.4)
  DateTimeColumn get deletedAt => dateTime().nullable()(); // tombstone (§5.4)

  @override
  Set<Column<Object>> get primaryKey => {uuid};
}
```

Los DAOs exponen intenciones de dominio, no SQL crudo a los notifiers:

```dart
// lib/data/dao/ — intenciones de dominio, no SQL crudo hacia los notifiers
// Quien genera el uuid y escribe `updated_at`/`deleted_at` es SIEMPRE el repositorio
// (único punto de escritura, §3.1) → añadir sync no toca ni tablas ni DAOs (D-015).
Future<GameProgressData> upsertProgress(String gameId, {required int unlockedUpTo});
Stream<List<GameSession>> watchActiveSessions();
Future<String> startSession(String gameId, {String mode = 'default'}); // devuelve uuid
```

> `settings` no se reproduce aquí: es una tabla clave-valor trivial de dos columnas
> (`key`, `value`) más `updated_at`/`deleted_at`; el DAO expone `read/writeSetting(String key)`.

### 5.4. Preparación para sync y tablas futuras (D-015)

#### 5.4.1. Identidad global: por qué el esquema es así

Objetivo de D-015: **añadir sync sin reescribir la capa de datos**. Un
`INTEGER ... autoIncrement()` no sirve como identidad global porque solo es único dentro
del dispositivo. Reglas ya aplicadas en §5.2/§5.3:

| Tabla | Identidad global | Motivo |
|---|---|---|
| `game_sessions` | **`uuid` (PK, UUID v4 client-generated)** | No tiene clave natural; el autoincrement se descarta como PK |
| `game_progress` | **`(game_id, mode)`** (clave natural, `UNIQUE`) | Ya es estable y única entre dispositivos; `id` queda como surrogate local |
| `settings` | **`key`** (PK) | Con namespacing por feature (`pi.`, `sums.`, `app.`) es globalmente única |

Consecuencias deliberadas:

1. **Nunca tablas de mapeo `local_id ↔ remote_id`:** el id que se guarda es ya el id
   global, o una clave natural que no cambia.
2. **`updated_at DATETIME NOT NULL`** en toda tabla sincronizable; lo escribe el
   repositorio en cada insert/update. Es la base de la resolución de conflictos.
3. **`deleted_at DATETIME?`** en toda tabla sincronizable: los borrados son
   ***tombstones*** (`NULL` = fila viva), no `DELETE`. El remoto necesita enterarse del
   borrado; el `DELETE` físico se deja para la poda, y solo tras confirmar replicación.
4. **Un único punto de escritura** (§3.1): solo los repositorios tocan Drift, así que el
   día que haya sync el cambio es *añadir transporte*, no migrar esquema.
5. `store_date_time_values_as_text` recomendado en `build.yaml` (ISO-8601): los timestamps
   de sync comparan texto de forma determinísticamente ordenable. ⚠️ *decidir en F1 — §9, fila 7*.

#### 5.4.2. Política de conflictos prevista

Definida ya para que nadie diseñe tablas que no la soporten:

| Situación | Regla |
|---|---|
| Dos dispositivos modifican la misma fila | **Last-write-wins por `updated_at`**: gana la fila con timestamp más reciente |
| Campos **monotónicos** (`unlocked_up_to`, `best_score`, `score`) | **Merge con `MAX`**: nunca retroceden, aunque un reloj atrasado traiga una fila "más nueva" |
| Borrado vs. edición simultáneos | Gana el más reciente por `updated_at`; el borrado viaja como `deleted_at` |
| Varias sesiones `active` | No se mergea `status`: gana la fila con mayor `updated_at`, y el perdedor **se degrada a `abandoned` antes de escribir** (§5.2, D-019: el índice parcial rechaza dos activas) |
| `state_json` | Tratado como **valor atómico** (sin merge por campo) |
| `settings` | LWW por `updated_at` sobre la pareja `(key, value)` |

Limitaciones conocidas, a resolver cuando se implemente la sync (fila 5 de §9):

- LWW depende de relojes: un dispositivo con la hora atrasada podría pisar cambios
  recientes. Alternativa prevista: **HLC (hybrid logical clock)** o timestamp del servidor
  en el intercambio.
- Los tombstones hay que podar con criterio (p. ej. > 30 días y replicación confirmada).

#### 5.4.3. Tablas futuras (diseñadas, no implementadas)

Se dejan aquí para que las migraciones futuras no sorprendan a nadie:

- **`achievements`** + **`achievement_unlocks`**: logros globales y desbloqueos del jugador.
  Se poblarán a partir de los eventos de `framework/events.dart` (D-013).
- **`session_events`** o métricas por ejercicio (tiempo de respuesta por dígito, tasa de
  acierto) → gráficas de evolución.
- **`profiles`**: solo si algún día hay varios perfiles locales o sync.
- **`sequences`** (`id`, `display_name`, `length`, `asset_path`): ⚠️ **futuro**. Solo haría
  falta si crece el catálogo y conviene no hardcodearlo en `data/sequences/` (§3.4);
  mientras haya 2-3 secuencias, el registro en código es más simple. No implementar.
- Tablas de **estadísticas agregadas**: probablemente derivadas bajo demanda en vez de
  tablas propias (⚠️ se decidirá en la fase de métricas).

### 5.5. Export / import del progreso (D-024)

«El progreso del jugador se protege por encima de todo» (§5.1). Un botón de **Exportar a
JSON** en Ajustes es barato y da tranquilidad: el archivo sale del dispositivo y va a donde
el usuario quiera — nube, USB, carpeta compartida — sin cuentas ni backend (sigue vigente
D-010). **Import** es el otro lado: restaurar tras reinstalar o cambiar de equipo.

**Formato** versionado, para que un archivo de otra versión no se importe «a ver qué sale»:

```json
{
  "format": "cogni-backup",
  "format_version": 1,
  "app_version": "1.0.0",
  "exported_at": "2026-10-02T10:00:00Z",
  "data": {
    "game_progress": [ ],
    "game_sessions": [ ],
    "settings": [ ]
  }
}
```

Reglas:

- **Export = lectura pura.** Las tres tablas tal cual, con `uuid`, `updated_at` y
  `deleted_at` intactos: son la identidad global y la base de la resolución de conflictos
  (§5.4). Exportar no muta la base.
- **Import v1 = *restaurar*.** Sustituye el contenido por el del archivo. Siempre con
  confirmación explícita y, **antes de tocar nada, auto-export del estado actual** a un
  `cogni-preimport-<fecha>.json` en el directorio de datos (copia de salvaguarda):
  «proteger el progreso» no puede convertirse en la forma de perderlo.
- **Import *fusionar* es ⚠️ futuro** (§9): si algún día se importa en un dispositivo que ya
  tiene progreso, no se inventan reglas nuevas — se aplican las de §5.4 (monotónicos con
  `MAX`, LWW por `updated_at`, tombstones respetados).
- **Validar antes de escribir:** `format` y `format_version` desconocidos o JSON ilegible →
  error legible y no se importa. Nada de `json.decode` a ciegas encima de la base.
- **No es sync.** Es un archivo que mueve el usuario a mano; no cambia nada de D-010 ni de
  la política de conflictos de §5.4.

---

## 6. Gestión de estado con Riverpod

### Capas

```text
presentation (widgets/pantallas)
        │  escucha / lee
application (providers @riverpod: Notifier / AsyncNotifier / StreamNotifier)
        │  llama
repositories (contratos de dominio)
        │  usan
DAOs → Drift (AppDatabase)
```

### Convenciones

| Situación | Provider | Ejemplo |
|---|---|---|
| Dependencia singleton | `Provider` (no genera código) | `appDatabaseProvider`, `repositoryProvider` |
| Estado de una partida | `@riverpod` `Notifier`/`AsyncNotifier` | `PiSessionController` |
| Escuchar cambios de la DB | `@riverpod` `StreamNotifier` / `StreamProvider` | `progressProvider` |
| Valor derivado (calcular) | `@riverpod` `Provider` | `digitsToNextCheckpoint` |
| Ajuste persistido | `@riverpod` `Notifier` que escribe en `settings` | `settingsProvider` |

Reglas:

1. **Los widgets no importan `data/`**; solo hablan con providers de su feature.
2. Un solo `ProviderScope` en `main.dart`; overrides solo en tests.
3. Estado de UI efímero (si el numpad está pulsado) → `StateProvider` local o estado de
   widget; **nunca** en la base de datos.
4. Estado de dominio (posición, checkpoint, récord) → siempre en Riverpod **y** persistido
   a través del repositorio en los momentos clave: `checkpoint alcanzado`,
   `sesión completada`, `app en background`. **Pausar no es un momento de persistencia**
   (D-017): no escribe en la base de datos. Y `app en background` —igual que «cerrar la
   ventana»— es *best-effort*: si el proceso muere antes (`kill`, cuelgue, apagón), se
   retoma desde el último estado persistido, no desde la posición exacta (§5.2).

---

## 7. Convenciones de código

- **Idioma:** identificadores en **inglés** (`PiSessionController`), documentación y
  comentarios en **español** (este documento). Nombres de archivo `snake_case.dart`.
- **Tests:** toda lógica de `features/*/domain/` y de `framework/` tiene tests unitarios.
  Objetivo mínimo: la lógica de π (validación, checkpoints) y el motor de sesiones.
- **Los tests de `domain/` no leen `assets/`**: usan `DigitSequence` falsos (o un
  `Uint8List` montado en el test). La integridad del asset real se testea **aparte**, en
  `test/data/sequences/` (§3.4). El asset no puede ser una dependencia de la lógica.
- **Textos visibles:** nunca literales dentro de widgets; van al ARB de `lib/l10n/` y se
  leen con `AppLocalizations` (§3.6, D-027).
- **Widgets propios, accesibles:** todo lo interactivo lleva `Semantics` (etiqueta y estado)
  y respeta `textScaler`; nada de alturas fijas ni de tamaños calculados a mano (§3.6).
- **Animaciones:** `AnimatedContainer`/`AnimatedOpacity` para feedback visual;
  `RepaintBoundary` para zonas que se redibujan mucho (numpad); 60 FPS como objetivo.
- **Errores:** mostrar feedback visual al jugador (tecla roja), registrar con
  `developer.log`; nada de `print` en producción. **Tres zonas, y no son
  intercambiables (�7):**
  1. **Arranque** — `runZonedGuarded` en `main()`, envolviendo la precarga de secuencias y
     `runApp`. Cubre el `await` de `rootBundle` y todo lo anterior al primer frame →
     diálogo claro y arranque detenido, nunca un spinner eterno.
  2. **Framework** — `FlutterError.onError`: errores de build/layout/ticker, los que
     Flutter captura él mismo. Se registran; no se silencian con un `// ignore`.
  3. **Global** — `PlatformDispatcher.onError`: cualquier error no capturado **después** de
     `runApp` (timers, callbacks sueltos, una recarga futura de un asset). El
     `runZonedGuarded` de `main()` **no lo sustituye**: es la red de seguridad del runtime
     en marcha.
- **Commits:** en inglés, `tipo(scope opcional): Descripción` con la descripción en
  imperativo y mayúscula, asunto ≤ 50 y cuerpo ≤ 72 (D-029); tipos y ejemplos en
  `AGENTS.md` §7. Los archivos generados **se commitean** y no se editan a mano (D-018).
  El *branching* está decidido: GitHub Flow con `main` como única rama permanente (D-031,
  detalle en `AGENTS.md` §7). El versionado se planifica para F7 (§4 y §9).

---

## 8. Roadmap

| Fase | Contenido | Estado |
|---|---|---|
| **F0 — Setup** | Proyecto Flutter escritorio, tooling y CI; los criterios para darla por cerrada están en §8.1 | ✅ |
| **F1 — Datos** | Tablas Drift (`game_progress`, `game_sessions`, `settings`) **con `uuid`/`updated_at`/`deleted_at` de entrada (D-015)**, conexión escritorio, repositorios (incl. export/import, §5.5), seeds | ⬜ |
| **F2 — Framework** | Contrato `Game`, motor de sesiones, progreso/checkpoints, eventos y `DigitSequence` (§3.4) | ⬜ |
| **F3 — Juego π** | UI: secuencia, numpad iluminado **y teclado físico (§3.5)**, validación, checkpoint=20, guardado y retoma. **Explícito:** asset `pi.txt` (10.000 dígitos) + `AssetDigitSequence` + test de integridad (§3.4) y botones Exportar/Importar en Ajustes (§5.5) | ⬜ |
| **F4 — Juego sumas** | Rondas con velocidad/dificultad, puntuación (valida que el framework es reutilizable); reutiliza la entrada de F3 (§3.5) | ⬜ |
| **F5 — Métricas** | Tiempos de respuesta, tasas, gráficas, estadísticas por juego | ⬜ |
| **F6 — Logros** | `AchievementManager` escuchando eventos (D-013) | ⬜ |
| **F7 — Distribución** | Instalador Windows (Inno Setup), `.deb`/AppImage Linux, macOS | ⬜ |

**Explícitamente fuera de alcance por ahora:** cuentas, nube, sincronización, ranking
online, Android, sistema social, más de dos juegos, Flame.

### 8.1. Criterios de aceptación de F0

F0 se da por cerrada cuando, **desde un checkout limpio**, se cumplen estos siete puntos.
Cada uno tiene su decisión en §2; ninguno debería quedar «a medias».

1. **Estructura creada** según §3.3: `lib/{core,framework,data,features,shared,l10n}`,
   `test/`, `tool/` y `assets/sequences/`.
2. **Arranca**: `flutter run -d windows` (o `-d linux`/`-d macos`) abre la primera pantalla
   sobre `MaterialApp.router` + `go_router`, con `flutter_localizations` y
   `AppLocalizations` resolviendo en español — sin tooltips ni diálogos en inglés (D-025,
   D-027).
3. **Codegen al día**: `dart run build_runner build --delete-conflicting-outputs` seguido de
   `git diff --exit-code` no deja diffs (D-018).
4. **Lint y formato**: `flutter analyze --fatal-infos` y
   `dart format --output=none --set-exit-if-changed .` pasan con `very_good_analysis` (D-026).
5. **Tests**: `flutter test` pasa, incluido el test de widget que arranca la primera pantalla
   con `textScaleFactorTestValue = 2.0` y comprueba que no desborda (D-028).
6. **CI y configuración versionada**: la pipeline de §4 está en verde ejecutando los puntos
   3-5 (el arranque del punto 2 se verifica en local, o con el job opcional de build de
   escritorio), y están commiteados `pubspec.lock`, `analysis_options.yaml`, `l10n.yaml`,
   `.gitattributes` y `.github/workflows/ci.yml`. El `.gitignore` cubre artefactos (`build/`,
   `.dart_tool/`, `.idea/`, `*.iml`…) y **no** los generados (`*.g.dart`, `*.drift.dart`,
   `*.steps.dart`), que se commitean (D-018).
7. **Proceso en vigor**: la convención de commits (D-029) y el branching (D-031) están
   escritos en `AGENTS.md` §7, y `docs/progress.md` existe con su plantilla para el registro
   de tareas (§6 de `AGENTS.md`).

> *Estado 2026-10-03: **F0 cerrada** — los siete puntos se cumplen. Formato,
> `flutter analyze --fatal-infos` y `flutter test` (15 tests) en verde en local;
> codegen sin diffs tras regenerar; arranque verificado con `flutter build windows
> --debug` y ejecutando el binario; pipeline de §4 **passing** en GitHub Actions
> sobre `main`.*

---

## 9. Decisiones pendientes (abiertas)

| # | Tema | Opciones | Cuándo decidir |
|---|---|---|---|
| 1 | Logros | Solo eventos hoy; tabla después | F6 |
| 2 | Métricas granulares | ¿Tabla `session_events` o JSON por sesión? | F5 |
| 3 | Gráficas | Paquete a elegir (`fl_chart`, custom…) | F5 |
| 4 | Versionado y releases | Propuesta en §4: `pubspec.yaml` como fuente única, `CHANGELOG.md`, `tool/bump_version.dart` y Release por tag `v*` | F7 |
| 5 | Sync futuro | Backend (Firebase/Supabase/API propia) y relojes (LWW simple vs HLC) — el esquema y la política de conflictos ya están fijados en §5.4 | Cuando se necesite |
| 6 | Import de progreso | ¿Solo *restaurar* (v1, D-024) o también *fusionar* con las reglas de §5.4? | Cuando haya más de un dispositivo con progreso |
| 7 | Fechas en Drift | `store_date_time_values_as_text`: ISO-8601 (ordenable, recomendado para comparar timestamps de sync, §5.4) vs unix timestamps (el defecto de drift) | F1 |
| 8 | Segundo idioma | Empezar a usar `intl` (plurales, `DateFormat`/`NumberFormat`); el ARB y `flutter_localizations` ya están desde F0 (D-027) | Cuando haya traducción |
| 9 | Android | Cuando el core esté estable | Posterior a F7 |

### 9.1. Análisis: fuente de las secuencias (D-020, ya decidida)

| Opción | Ventaja | Coste | Techo práctico |
|---|---|---|---|
| **A. Constante en Dart** (`const piDigits = '1415...'`) | Síncrona, testeable, sin I/O, cero config | Literal enorme en fuente; hay que recompilar para cambiarlo | ~10.000 dígitos |
| **B. Asset `.txt`** (`assets/sequences/pi.txt`) | Actualizable sin tocar código, formato trivial, reemplazable | Carga asíncrona al inicio; declarar el asset en `pubspec.yaml` | 10⁶+ dígitos |
| **C. Archivo generado** (`pi_digits.g.dart` vía `tool/`) | Combina A y B: síncrono y regenerable | Un paso más en el build (aunque ya se usa `build_runner`) | ~50.000 dígitos |
| **D. Cálculo en runtime** (spigot / BigInt) | Sin datos que mantener; techo ilimitado | Lento y propenso a bugs: π es constante, no se calcula | — |
| **E. Paquete de pub.dev** | Menos código propio | Dependencia para lo que es un archivo de texto; la mayoría calculan, no almacenan | — |

**Se descartan D y E.** D es ingeniería invertida: computar lo que es un dato. E añade una
dependencia para un problema que se resuelve con un `.txt`.

**Se descarta A** porque ata el techo del juego a una decisión de código: el día que alguien
pase de 10.000 dígitos hay que recompilar. Un juego de memorización de π no debería tener
ese techo arbitrario.

**Se descarta C** porque ya se usa `build_runner` para Drift/Riverpod y meter ahí un
generador de secuencias mezcla dos ciclos distintos (esquema de datos vs contenido):
regenerar el esquema no debería regenerar π.

**Decisión: B (asset `.txt`).** Queda registrada como D-020; §3.3 y §3.4 describen esta
opción, y las alternativas se dejan arriba por si hay que revisarla al ampliar el catálogo.

---

## 10. Preguntas frecuentes / FAQ corto

**¿Por qué no Isar/Hive/SharedPreferences?**
Son válidos, pero el dato de Cogni es **relacional** (progreso ↔ sesiones ↔ ajustes) y
queremos migraciones versionadas para no perder el progreso del usuario. Drift sobre SQLite
cubre eso con consultas tipadas. SharedPreferences se usaría solo si aparece un ajuste
verdaderamente trivial fuera de `settings` (improbable).

**¿Por qué no Flame?**
Los dos juegos de la v1 son lógica + UI animada, no física ni entidades. Se añadiría como
dependencia opcional si un futuro juego lo necesita.

**¿Hace falta backend?**
No. Todo es local; el día que haya sync, la capa de repositorios es el único punto que
cambia, porque las tablas ya salen de fábrica con identidad global, `updated_at` y
`tombstones`, y la política de conflictos está definida en §5.4 (D-015).

**¿Y si me cambio de ordenador?**
**Exportar a JSON** desde Ajustes y **Importar** en el nuevo. Sin cuentas ni nube, y antes
de importar la app guarda copia de lo que había (§5.5, D-024).

**¿Se puede jugar con el teclado?**
Sí: numpad iluminado y teclado físico funcionan a la vez, fila de dígitos y bloque
numérico incluidos (§3.5, D-023).

**¿Habrá otros idiomas?**
En la v1, solo español. Los textos ya viven en un ARB (`gen_l10n`), así que añadir uno es
escribir `app_fr.arb` y registrar los locales. Las APIs de `intl` se empiezan a usar con el
primer idioma nuevo, y `flutter_localizations` ya va desde F0 para que Material no caiga al
inglés (D-027).

---

> **Última actualización:** 2026-10-03.
> Este documento se actualiza **junto con** cada decisión nueva (añadir fila en §2).
