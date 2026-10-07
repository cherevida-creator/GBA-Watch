import SwiftUI
import CoreFoundation
import mGBA

@MainActor
final class GBAEmulator: ObservableObject {
    @Published private(set) var frameImage: CGImage?
    @Published private(set) var errorMessage: String?

    private let width = 240
    private let height = 160
    private var core: UnsafeMutablePointer<mCore>?
    private var pixels: UnsafeMutableBufferPointer<UInt8>?
    private var pressedKeys: UInt32 = 0
    private var frameTask: Task<Void, Never>?
    private var paused = false

    func start(romURL: URL) {
        stop()
        errorMessage = nil
        guard let core = GBACoreCreate() else {
            errorMessage = "No se pudo iniciar mGBA."
            return
        }
        self.core = core
        mCoreInitConfig(core, nil)
        var options = mCoreOptions()
        options.useBios = false
        mCoreConfigLoadDefaults(&core.pointee.config, &options)
        guard core.pointee.`init`(core) else {
            errorMessage = "No se pudo inicializar el núcleo GBA."
            mCoreConfigDeinit(&core.pointee.config)
            core.pointee.deinit(core)
            self.core = nil
            return
        }

        let buffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: width * height * 4)
        buffer.initialize(repeating: 0)
        pixels = buffer
        buffer.withMemoryRebound(to: color_t.self) { colors in
            core.pointee.setVideoBuffer(core, colors.baseAddress, width)
        }

        let saveURL = romURL.deletingPathExtension().appendingPathExtension("sav")
        let loaded = saveURL.path.withCString { path in
            core.pointee.opts.savegamePath = strdup(path)
            guard mCoreLoadFile(core, romURL.path) else { return false }
            _ = mCoreLoadSaveFile(core, path, false)
            return true
        }
        guard loaded else {
            errorMessage = "No se pudo abrir la ROM .gba."
            stop()
            return
        }
        core.pointee.reset(core)
        paused = false
        frameTask = Task { [weak self] in
            var frameNumber = 0
            while !Task.isCancelled {
                guard let self, let activeCore = self.core else { break }
                if !self.paused {
                    activeCore.pointee.runFrame(activeCore)
                    frameNumber += 1
                    if frameNumber.isMultiple(of: 2) { self.publishFrame() }
                }
                try? await Task.sleep(nanoseconds: 16_666_667)
            }
        }
    }

    func stop() {
        frameTask?.cancel()
        frameTask = nil
        if let core {
            mCoreConfigDeinit(&core.pointee.config)
            core.pointee.deinit(core)
        }
        core = nil
        pixels?.deallocate()
        pixels = nil
        frameImage = nil
        pressedKeys = 0
    }

    func setPaused(_ value: Bool) { paused = value }

    func setButton(_ name: String, pressed: Bool) {
        let key: Int32
        switch name {
        case "A": key = GBA_KEY_A.rawValue
        case "B": key = GBA_KEY_B.rawValue
        case "L": key = GBA_KEY_L.rawValue
        case "R": key = GBA_KEY_R.rawValue
        case "Start": key = GBA_KEY_START.rawValue
        case "Select": key = GBA_KEY_SELECT.rawValue
        case "up": key = GBA_KEY_UP.rawValue
        case "down": key = GBA_KEY_DOWN.rawValue
        case "left": key = GBA_KEY_LEFT.rawValue
        case "right": key = GBA_KEY_RIGHT.rawValue
        default: return
        }
        let mask = UInt32(1) << UInt32(key)
        if pressed { pressedKeys |= mask } else { pressedKeys &= ~mask }
        if let core { core.pointee.setKeys(core, pressedKeys) }
    }

    private func publishFrame() {
        guard let pixels,
              let provider = CGDataProvider(data: Data(bytes: pixels.baseAddress!, count: pixels.count) as CFData) else { return }
        frameImage = CGImage(
            width: width, height: height,
            bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
                .union(.byteOrder32Big),
            provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent
        )
    }
}
