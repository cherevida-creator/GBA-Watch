# GBA Watch

Emulador nativo de Game Boy Advance para Apple Watch. La interfaz inicial incluye una pantalla con proporción GBA, controles táctiles y pausa.

## Estado

La interfaz está implementada. watchOS no ofrece el selector de archivos del iPhone, así que la transferencia de ROM desde el iPhone sigue pendiente. Tampoco se ejecutan juegos ni se generan imagen, audio o partidas guardadas; falta integrar un núcleo compatible con watchOS y conectarlo a los botones y a la pantalla de 240 × 160.

No se incluyen BIOS ni juegos. Importa únicamente ROMs que tengas derecho a usar.

## Generar y compilar

Se necesita Xcode en macOS y XcodeGen. Desde la raíz del repositorio:

```sh
brew install xcodegen
xcodegen generate
xcodebuild -project GBAWatch.xcodeproj -scheme GBAWatch \
  -destination 'generic/platform=watchOS Simulator' \
  CODE_SIGNING_ALLOWED=NO build
```

GitHub Actions ejecuta esa compilación para Apple Watch Simulator en cada push y pull request.
