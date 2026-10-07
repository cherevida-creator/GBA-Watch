import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var library: GameLibrary
    @State private var showingMenu = false
    @State private var isPaused = false
    @State private var pressed: Set<String> = []

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                HStack {
                    Text("GBA WATCH").font(.system(size: 11, weight: .black, design: .rounded)).tracking(1)
                    Spacer()
                    Circle().fill(library.gameURL == nil ? .gray : .green).frame(width: 6, height: 6)
                }
                GameScreenView(gameName: library.gameURL?.deletingPathExtension().lastPathComponent, isPaused: isPaused)
                    .aspectRatio(3 / 2, contentMode: .fit)
                if let error = library.importError {
                    Text(error).font(.system(size: 10)).foregroundStyle(.red).multilineTextAlignment(.center)
                }
                if library.gameURL == nil {
                    VStack(spacing: 3) {
                        Label("ROM desde iPhone", systemImage: "iphone").font(.system(size: 10, weight: .semibold))
                        Text(library.transferMessage).font(.system(size: 8)).foregroundStyle(.secondary).multilineTextAlignment(.center)
                    }
                } else {
                    Menu {
                        ForEach(library.games, id: \.path) { game in
                            Button {
                                library.selectGame(game)
                            } label: {
                                Label(
                                    game.deletingPathExtension().lastPathComponent,
                                    systemImage: game == library.gameURL ? "checkmark.circle.fill" : "gamecontroller"
                                )
                            }
                        }
                    } label: {
                        Label("Juegos (\(library.games.count))", systemImage: "square.stack.3d.up")
                            .font(.system(size: 10, weight: .medium))
                    }
                    .buttonStyle(.bordered)
                    HStack {
                        VStack(spacing: 3) {
                            button("▲", "up")
                            HStack(spacing: 3) { button("◀", "left"); button("▶", "right") }
                            button("▼", "down")
                        }
                        Spacer()
                        HStack(spacing: 6) { button("B", "B"); button("A", "A") }
                    }
                    Button { showingMenu = true } label: {
                        Label(isPaused ? "Reanudar" : "Pausa y opciones", systemImage: "pause.fill")
                            .font(.system(size: 11, weight: .medium))
                    }.buttonStyle(.bordered)
                }
            }
            .padding(.horizontal, 6).padding(.vertical, 4)
        }
        .confirmationDialog("Opciones", isPresented: $showingMenu, titleVisibility: .visible) {
            Button(isPaused ? "Reanudar" : "Pausar") { isPaused.toggle() }
            Button("Cancelar", role: .cancel) { }
        }
    }

    private func button(_ title: String, _ key: String) -> some View {
        Text(title).font(.system(size: 12, weight: .bold))
            .frame(width: 28, height: 22)
            .background(pressed.contains(key) ? Color.green.opacity(0.65) : Color.gray.opacity(0.25))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .gesture(DragGesture(minimumDistance: 0).onChanged { _ in pressed.insert(key) }.onEnded { _ in pressed.remove(key) })
    }
}
