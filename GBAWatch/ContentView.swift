import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var library: GameLibrary
    @StateObject private var emulator = GBAEmulator()
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
                GameScreenView(gameName: library.gameURL?.deletingPathExtension().lastPathComponent,
                               isPaused: isPaused, frameImage: emulator.frameImage)
                    .aspectRatio(3 / 2, contentMode: .fit)
                if let error = library.importError ?? emulator.errorMessage {
                    Text(error).font(.system(size: 10)).foregroundStyle(.red).multilineTextAlignment(.center)
                }
                if library.gameURL == nil {
                    VStack(spacing: 3) {
                        Label("ROM desde iPhone", systemImage: "iphone").font(.system(size: 10, weight: .semibold))
                        Text(library.transferMessage).font(.system(size: 8)).foregroundStyle(.secondary).multilineTextAlignment(.center)
                    }
                } else {
                    HStack {
                        VStack(spacing: 3) {
                            button("▲", "up")
                            HStack(spacing: 3) { button("◀", "left"); button("▶", "right") }
                            button("▼", "down")
                        }
                        Spacer()
                        HStack(spacing: 5) {
                            button("L", "L"); button("B", "B"); button("A", "A"); button("R", "R")
                        }
                    }
                    HStack(spacing: 8) {
                        button("SELECT", "Select")
                        button("START", "Start")
                    }
                    Button { showingMenu = true } label: {
                        Label("Juegos y pausa (\(library.games.count))", systemImage: "square.stack.3d.up")
                            .font(.system(size: 11, weight: .medium))
                    }.buttonStyle(.bordered)
                }
            }
            .padding(.horizontal, 6).padding(.vertical, 4)
        }
        .onChange(of: library.gameURL) { _, newURL in
            if let newURL {
                isPaused = false
                emulator.start(romURL: newURL)
            } else {
                emulator.stop()
            }
        }
        .onChange(of: isPaused) { _, paused in emulator.setPaused(paused) }
        .onAppear {
            if let url = library.gameURL { emulator.start(romURL: url) }
        }
        .confirmationDialog("Juegos y opciones", isPresented: $showingMenu, titleVisibility: .visible) {
            ForEach(library.games, id: \.path) { game in
                let name = game.deletingPathExtension().lastPathComponent
                Button((game == library.gameURL ? "✓ " : "") + name) { library.selectGame(game) }
            }
            Button(isPaused ? "Reanudar" : "Pausar") { isPaused.toggle() }
            Button("Cancelar", role: .cancel) { }
        }
    }

    private func button(_ title: String, _ key: String) -> some View {
        Text(title).font(.system(size: title.count > 1 ? 7 : 12, weight: .bold))
            .frame(minWidth: title.count > 1 ? 38 : 25, minHeight: 22)
            .padding(.horizontal, title.count > 1 ? 3 : 0)
            .background(pressed.contains(key) ? Color.green.opacity(0.65) : Color.gray.opacity(0.25))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    guard pressed.insert(key).inserted else { return }
                    emulator.setButton(key, pressed: true)
                }
                .onEnded { _ in
                    pressed.remove(key)
                    emulator.setButton(key, pressed: false)
                })
    }
}
