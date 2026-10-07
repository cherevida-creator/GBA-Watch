import Foundation
import Combine
import WatchConnectivity

@MainActor
final class GameLibrary: NSObject, ObservableObject, WCSessionDelegate {
    @Published private(set) var gameURL: URL?
    @Published private(set) var games: [URL] = []
    @Published var importError: String?
    @Published private(set) var transferMessage = "Abre GBA Watch en el iPhone para enviar una ROM."

    private let folderName = "Games"

    override init() {
        super.init()
        loadSavedROMs()
        guard WCSession.isSupported() else {
            transferMessage = "WatchConnectivity no está disponible."
            return
        }
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            if let error {
                self.transferMessage = "Error de conexión: \(error.localizedDescription)"
            } else {
                self.transferMessage = "Elige un archivo .gba en la app del iPhone."
            }
        }
    }

    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        let sourceURL = file.fileURL
        let fileName = (file.metadata?["filename"] as? String) ?? sourceURL.lastPathComponent
        guard fileName.lowercased().hasSuffix(".gba") else {
            DispatchQueue.main.async { self.importError = "El archivo recibido no es una ROM .gba." }
            return
        }
        do {
            let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let folder = documents.appendingPathComponent(folderName, isDirectory: true)
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            let safeName = URL(fileURLWithPath: fileName).lastPathComponent
            let destination = folder.appendingPathComponent(safeName)
            if FileManager.default.fileExists(atPath: destination.path) {
                try FileManager.default.removeItem(at: destination)
            }
            try FileManager.default.copyItem(at: sourceURL, to: destination)
            DispatchQueue.main.async {
                self.loadSavedROMs(preferred: destination)
                self.importError = nil
                self.transferMessage = "ROM lista: \(safeName)"
            }
        } catch {
            DispatchQueue.main.async {
                self.importError = "No se pudo guardar la ROM: \(error.localizedDescription)"
            }
        }
    }

    func selectGame(_ game: URL) {
        guard games.contains(game) else { return }
        gameURL = game
    }

    private func loadSavedROMs(preferred: URL? = nil) {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let folder = documents.appendingPathComponent(folderName, isDirectory: true)
        guard let files = try? FileManager.default.contentsOfDirectory(
            at: folder, includingPropertiesForKeys: [.contentModificationDateKey]
        ) else {
            games = []
            gameURL = nil
            return
        }
        games = files
            .filter { $0.pathExtension.lowercased() == "gba" }
            .sorted {
                let lhs = (try? $0.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
                let rhs = (try? $1.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
                return lhs > rhs
            }
        gameURL = preferred.flatMap { games.contains($0) ? $0 : nil } ?? games.first
    }
}
