import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject private var library: GameLibrary
    @State private var showingImporter = false
    @State private var showingMenu = false
    @State private var isPaused = false
    @State private var pressedButtons: Set<String> = []

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                header
                GameScreenView(gameName: library.gameURL?.deletingPathExtension().lastPathComponent,
                               isPaused: isPaused)
                    .aspectRatio(3 / 2, contentMode: .fit)

                if let error = library.importError {
                    Text(error).font(.system(size: 10)).foregroundStyle(.red).multilineTextAlignment(.center)
                }

                if library.gameURL == nil {
                    Button { showingImporter = true } label: {
                        Label("Cargar juego", systemImage: "square.and.arrow.down")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    controls
                    Button { showingMenu = true } label: {
                        Label(isPaused ? "Reanudar" : "Pausa y opciones", systemImage: "pause.fill")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
        }
        .fileImporter(isPresented: $showingImporter,
                      allowedContentTypes: [UTType(filenameExtension: "gba") ?? .data],
                      allowsMultipleSelection: false) { result in
            if case .success(let urls) = result, let url = urls.first {
                library.importGame(from: url)
            } else if case .failure(let error) = result {
                library.importError = error.localizedDescription
            }
        }
        .confirmationDialog("Opciones", isPresented: $showingMenu, titleVisibility: .visible) {
            Button(isPaused ? "Reanudar" : "Pausar") { isPaused.toggle() }
            Button("Elegir otro juego") { showingImporter = true }
            Button("Cancelar", role: .cancel) { }
        }
    }

    private var header: some View {
        HStack {
            Text("GBA WATCH").font(.system(size: 11, weight: .black, design: .rounded)).tracking(1)
            Spacer(minLength: 0)
            Circle().fill(library.gameURL == nil ? .gray : .green).frame(width: 6, height: 6)
        }
    }

    private var controls: some View {
        HStack(spacing: 9) {
            VStack(spacing: 3) {
                padButton("▲", name: "up")
                HStack(spacing: 3) { padButton("◀", name: "left"); padButton("●", name: "center", enabled: false); padButton("▶", name: "right") }
                padButton("▼", name: "down")
            }
            Spacer(minLength: 0)
            HStack(spacing: 6) {
                actionButton("B", name: "B")
                actionButton("A", name: "A")
            }
        }
        .padding(.horizontal, 2)
    }

    private func padButton(_ title: String, name: String, enabled: Bool = true) -> some View {
        Button { } label: {
            Text(title).font(.system(size: 12, weight: .bold))
                .frame(width: 24, height: 21)
                .background(pressedButtons.contains(name) ? Color.green.opacity(0.65) : Color.gray.opacity(0.25))
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
        .simultaneousGesture(DragGesture(minimumDistance: 0).onChanged { _ in press(name) }.onEnded { _ in release(name) })
        .disabled(!enabled)
    }

    private func actionButton(_ title: String, name: String) -> some View {
        Button { } label: {
            Text(title).font(.system(size: 13, weight: .black, design: .rounded))
                .frame(width: 31, height: 31)
                .foregroundStyle(.white)
                .background(pressedButtons.contains(name) ? Color.pink : Color.pink.opacity(0.72))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .simultaneousGesture(DragGesture(minimumDistance: 0).onChanged { _ in press(name) }.onEnded { _ in release(name) })
    }

    private func press(_ name: String) {
        pressedButtons.insert(name)
    }

    private func release(_ name: String) {
        pressedButtons.remove(name)
    }
}
