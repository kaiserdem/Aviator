import SwiftUI

struct Theme {
    struct Palette {
        static let primaryPurple = Color(hex: "#320064")
        static let secondaryDarkBlue = Color(hex: "#0A001E")
        
        static let vibrantPink = Color(hex: "#E91E63")
        static let deepMagenta = Color(hex: "#9C27B0")
        
        static let darkPurpleRed = Color(hex: "#B41446")
        static let brightOrangeRed = Color(hex: "#E62814")
        
        static let midPurple = Color(hex: "#C0399B")
        static let lightPink = Color(hex: "#D82C7C")
        static let white = Color.white
        static let black = Color.black
        static let darkGray = Color(hex: "#1A1A1A")
        static let lightGray = Color(hex: "#F5F5F5")
        
        static let darkRed = Color(hex: "#B22222")
    }
    
    struct Gradients {
        static let primary = LinearGradient(
            colors: [Palette.primaryPurple, Palette.secondaryDarkBlue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let vibrant = LinearGradient(
            colors: [Palette.vibrantPink, Palette.deepMagenta],
            startPoint: .leading,
            endPoint: .trailing
        )
        
        static let card = LinearGradient(
            colors: [Palette.darkPurpleRed, Palette.brightOrangeRed],
            startPoint: .leading,
            endPoint: .trailing
        )
        
        static let soft = LinearGradient(
            colors: [Palette.midPurple.opacity(0.8), Palette.lightPink.opacity(0.6)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let button = LinearGradient(
            colors: [Palette.vibrantPink, Palette.deepMagenta],
            startPoint: .top,
            endPoint: .bottom
        )
        
        static let tabBar = LinearGradient(
            colors: [Palette.primaryPurple, Palette.midPurple, Palette.deepMagenta],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    struct Shadows {
        static let light = Color.black.opacity(0.1)
        static let medium = Color.black.opacity(0.2)
        static let heavy = Color.black.opacity(0.3)
    }
    
    struct Opacity {
        static let cardBackground = 0.15
        static let textSecondary = 0.8
        static let textTertiary = 0.6
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
