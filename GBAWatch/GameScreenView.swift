import SwiftUI

struct GameScreenView: View {
    let gameName: String?
    let isPaused: Bool
    let frameImage: CGImage?

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topTrailing) {
                Color(red: 0.54, green: 0.67, blue: 0.38)
                if let frameImage {
                    Image(decorative: frameImage, scale: 1, orientation: .up)
                        .resizable()
                        .interpolation(.none)
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.black)
                } else {
                    VStack(spacing: 3) {
                        Image(systemName: gameName == nil ? "gamecontroller" : "cpu")
                            .font(.system(size: geometry.size.height * 0.22, weight: .black))
                        Text(gameName?.uppercased() ?? "INSERT GAME")
                            .font(.system(size: max(7, geometry.size.width * 0.055), weight: .black, design: .monospaced))
                            .lineLimit(1).minimumScaleFactor(0.65)
                        Text(gameName == nil ? "GBA · 240 × 160" : "STARTING mGBA…")
                            .font(.system(size: max(5, geometry.size.width * 0.035), weight: .medium, design: .monospaced))
                    }
                    .foregroundStyle(Color(red: 0.12, green: 0.22, blue: 0.13))
                }
                if isPaused {
                    Text("PAUSED")
                        .font(.system(size: 8, weight: .black, design: .monospaced))
                        .padding(.horizontal, 5).padding(.vertical, 2)
                        .background(.black.opacity(0.75)).foregroundStyle(.white)
                        .padding(4)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(.black.opacity(0.8), lineWidth: 2))
        }
    }
}
