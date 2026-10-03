# Cogni

App de entrenamiento cognitivo gamificado, local y de código abierto.

Escrito primero para escritorio (Windows/Linux/macOS), sin backend ni cuentas: todo
el progreso vive en la propia máquina. Llega con dos juegos iniciales, la
memorización de π y el cálculo mental, construidos sobre un framework genérico de
juegos que permite añadir más sin tocar el núcleo.

## Documentación

- `docs/DOCUMENTACION.md` — fuente única de verdad del proyecto (decisiones,
  arquitectura, roadmap).
- `docs/progress.md` — registro de progreso de cada tarea.

## Desarrollo

```bash
flutter pub get
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
flutter analyze --fatal-infos
flutter test
flutter run -d windows
```

## Requisitos

- Flutter (canal stable).
- En Windows, Visual Studio 2022 con el workload "Desktop development with C++".