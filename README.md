# GBA Watch

Emulador nativo de Game Boy Advance para Apple Watch. El prototipo permite importar archivos .gba, muestra una pantalla con proporción GBA e incluye controles táctiles y pausa.

## Estado

La interfaz y la importación de ROM están implementadas. Aún falta integrar el núcleo de emulación: por ahora no se ejecutan juegos ni se generan imagen, audio o partidas guardadas. El siguiente paso es conectar un core compatible con watchOS a los botones, la pantalla de 240 × 160 y los archivos de guardado.

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
