import SwiftUI
import UniformTypeIdentifiers
import WatchConnectivity
import Combine

@main struct GBACompanionApp: App {
    @StateObject private var transfer = ROMTransferManager()
    var body: some Scene {
        WindowGroup { TransferView().environmentObject(transfer) }
    }
}

final class ROMTransferManager: NSObject, ObservableObject, WCSessionDelegate {
    @Published private(set) var status = "Conectando con el Apple Watch…"
    @Published private(set) var queuedROMs: [String] = []
    private var session: WCSession?

    override init() {
        super.init()
        guard WCSession.isSupported() else { status = "WatchConnectivity no disponible."; return }
        let current = WCSession.default
        session = current
        current.delegate = self
        current.activate()
    }

    func send(_ url: URL) {
        guard url.pathExtension.lowercased() == "gba" else { status = "Elige un archivo .gba."; return }
        guard let session, session.activationState == .activated else { status = "Abre la app y espera la conexión."; return }
        guard session.isPaired && session.isWatchAppInstalled else { status = "Empareja el Watch e instala GBA Watch."; return }
        let access = url.startAccessingSecurityScopedResource()
        defer { if access { url.stopAccessingSecurityScopedResource() } }
        do {
            let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let dir = docs.appendingPathComponent("ROMs", isDirectory: true)
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            let name = url.lastPathComponent
            let copy = dir.appendingPathComponent(name)
            if FileManager.default.fileExists(atPath: copy.path) { try FileManager.default.removeItem(at: copy) }
            try FileManager.default.copyItem(at: url, to: copy)
            session.transferFile(copy, metadata: ["filename": name])
            queuedROMs.insert(name, at: 0)
            status = "Transferencia en cola: \(name)"
        } catch { status = "Error: \(error.localizedDescription)" }
    }

    func report(_ error: Error) { status = "No se pudo abrir: \(error.localizedDescription)" }
    func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.status = error.map { "Conexión: \(String(describing: $0))" } ?? (state == .activated ? "Conectado. Elige una ROM .gba." : "Activando WatchConnectivity…")
        }
    }
    func session(_ session: WCSession, didFinish transfer: WCSessionFileTransfer, error: Error?) {
        DispatchQueue.main.async { self.status = error.map { "Error de transferencia: \(String(describing: $0))" } ?? "ROM transferida al Apple Watch." }
    }
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) { session.activate() }
}

struct TransferView: View {
    @EnvironmentObject private var transfer: ROMTransferManager
    @State private var importing = false
    var body: some View {
        NavigationStack {
            List {
                Section("Biblioteca") {
                    Text("Importa una ROM y envíala al Apple Watch.")
                    Button { importing = true } label: { Label("Elegir archivo .gba", systemImage: "square.and.arrow.down") }
                        .buttonStyle(.borderedProminent)
                }
                Section("Apple Watch") {
                    Text(transfer.status).font(.footnote)
                    ForEach(Array(transfer.queuedROMs.enumerated()), id: \.offset) { _, name in Label(name, systemImage: "gamecontroller") }
                }
                Section { Text("Los archivos permanecen en el iPhone y el Watch; no se envían a servidores.").font(.footnote).foregroundStyle(.secondary) }
            }
            .navigationTitle("GBA Watch")
        }
        .fileImporter(isPresented: $importing, allowedContentTypes: [.data], allowsMultipleSelection: false) { result in
            switch result {
            case .success(let urls): if let url = urls.first { transfer.send(url) }
            case .failure(let error): transfer.report(error)
            }
        }
    }
}
