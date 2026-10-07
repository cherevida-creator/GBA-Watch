# GBA Watch

Emulador de Game Boy Advance para Apple Watch, con una app compañera de iPhone para importar ROMs propias.

## Estado

La app de iPhone permite elegir archivos .gba desde Archivos y enviarlos al Watch por WatchConnectivity. El reloj guarda las ROMs recibidas en una biblioteca local, abre la más reciente y permite cambiar entre juegos desde el menú «Juegos».

La interfaz y los controles táctiles del Watch están preparados, pero todavía no ejecutan juegos ni producen imagen, audio o partidas guardadas. La siguiente fase es integrar un núcleo compatible con watchOS y conectar sus entradas y salida gráfica.

No se incluyen BIOS ni juegos. Las ROMs se conservan en el iPhone y el Watch; no se envían a servidores. Importa únicamente archivos que tengas derecho a usar.

## Compilar online

GitHub Actions usa XcodeGen para compilar ambas apps en simuladores en cada push y pull request. Desde macOS también se puede ejecutar:

```sh
brew install xcodegen
xcodegen generate
xcodebuild -project GBAWatch.xcodeproj -scheme GBAWatch -destination 'generic/platform=watchOS Simulator' CODE_SIGNING_ALLOWED=NO build
xcodebuild -project GBAWatch.xcodeproj -scheme GBACompanion -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```

La transferencia real requiere un iPhone y un Apple Watch emparejados con GBA Watch instalado.
