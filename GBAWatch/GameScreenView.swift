import SwiftUI

struct GameScreenView: View {
    let gameName: String?
    let isPaused: Bool

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(red: 0.54, green: 0.67, blue: 0.38)
                VStack(spacing: 3) {
                    HStack(spacing: 3) {
                        ForEach(0..<8, id: \.self) { index in
                            Rectangle().fill(palette[index % palette.count]).frame(height: max(2, geometry.size.height * 0.035))
                        }
                    }
                    Spacer(minLength: 0)
                    Image(systemName: gameName == nil ? "gamecontroller" : "cpu")
                        .font(.system(size: geometry.size.height * 0.22, weight: .black))
                    Text(gameName?.uppercased() ?? "INSERT GAME")
                        .font(.system(size: max(7, geometry.size.width * 0.055), weight: .black, design: .monospaced))
                        .lineLimit(1).minimumScaleFactor(0.65)
                    Text(gameName == nil ? "GBA · 240 × 160" : "EMULATOR CORE PENDING")
                        .font(.system(size: max(5, geometry.size.width * 0.035), weight: .medium, design: .monospaced))
                    Spacer(minLength: 0)
                    if isPaused {
                        Text("PAUSED").font(.system(size: 8, weight: .black, design: .monospaced))
                            .padding(.horizontal, 5).padding(.vertical, 2)
                            .background(.black.opacity(0.75)).foregroundStyle(.white)
                    }
                }
                .padding(geometry.size.width * 0.06)
                .foregroundStyle(Color(red: 0.12, green: 0.22, blue: 0.13))
            }
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(.black.opacity(0.8), lineWidth: 2))
        }
    }

    private let palette: [Color] = [
        Color(red: 0.28, green: 0.38, blue: 0.22),
        Color(red: 0.37, green: 0.49, blue: 0.29),
        Color(red: 0.72, green: 0.79, blue: 0.51),
        Color(red: 0.41, green: 0.53, blue: 0.31)
    ]
}
