import SwiftUI

enum Theme {
    enum Palette {
        static let background = Color(hex: "1B1D21")
        static let surface = Color(hex: "24262B")
        static let primaryRed = Color(hex: "D72638")
        static let accentGreen = Color(hex: "2ECC71")
        static let emberOrange = Color(hex: "FF6B3D")
        static let textPrimary = Color.white
        static let textSecondary = Color.white.opacity(0.7)
    }

    enum Gradient {
        static let background: LinearGradient = .linearGradient(
            colors: [Palette.background, Color(hex: "2A1F20"), Palette.background],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}


