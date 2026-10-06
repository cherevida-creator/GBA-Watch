import Foundation
import Combine

@MainActor
final class GameLibrary: ObservableObject {
    @Published private(set) var gameURL: URL?
    @Published var importError: String?

    private let folderName = "Games"

    func importGame(from sourceURL: URL) {
        guard sourceURL.pathExtension.lowercased() == "gba" else {
            importError = "Selecciona un archivo con extensión .gba."
            return
        }

        let hasAccess = sourceURL.startAccessingSecurityScopedResource()
        defer { if hasAccess { sourceURL.stopAccessingSecurityScopedResource() } }

        do {
            let folder = try gamesFolder()
            let destination = folder.appendingPathComponent(sourceURL.lastPathComponent)
            if FileManager.default.fileExists(atPath: destination.path) {
                try FileManager.default.removeItem(at: destination)
            }
            try FileManager.default.copyItem(at: sourceURL, to: destination)
            gameURL = destination
            importError = nil
        } catch {
            importError = "No se pudo importar el juego: \(error.localizedDescription)"
        }
    }

    private func gamesFolder() throws -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let folder = documents.appendingPathComponent(folderName, isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder
    }
}
