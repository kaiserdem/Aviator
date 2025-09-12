import SwiftUI

struct Theme {
    struct Palette {
        // Основні кольори з скріншота
        static let primaryRed = Color(hex: "FF2D55")        // Насичений червоний
        static let deepRed = Color(hex: "8B0000")          // Глибокий червоний/бордовий
        static let darkRed = Color(hex: "4A0000")          // Темно-червоний
        static let black = Color(hex: "000000")            // Чорний
        
        // Пурпурові градієнти
        static let deepPurple = Color(hex: "4A148C")       // Темно-пурпуровий
        static let purple = Color(hex: "7B1FA2")          // Пурпуровий
        static let lightPurple = Color(hex: "E1BEE7")     // Світло-пурпуровий
        static let pinkPurple = Color(hex: "C2185B")      // Пурпурово-рожевий
        
        // Акцентні кольори
        static let gold = Color(hex: "FFD700")            // Золотий/жовтий
        static let green = Color(hex: "4CAF50")          // Зелений
        static let blue = Color(hex: "2196F3")           // Синій
        
        // Текстові кольори
        static let textPrimary = Color.white
        static let textSecondary = Color(hex: "B0B0B0")   // Світло-сірий
        static let textTertiary = Color(hex: "808080")   // Середньо-сірий
        
        // Фонові кольори
        static let surface = Color(hex: "1A1A1A")        // Темно-сірий
        static let surfaceLight = Color(hex: "2A2A2A")   // Світліший сірий
    }
    
    struct Gradient {
        // Основні градієнти з скріншота
        static let background = LinearGradient(
            colors: [Palette.deepRed, Palette.black],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let backgroundPurple = LinearGradient(
            colors: [Palette.deepPurple, Palette.black],
            startPoint: .bottomLeading,
            endPoint: .topTrailing
        )
        
        static let backgroundPink = LinearGradient(
            colors: [Palette.deepPurple, Palette.pinkPurple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        // Навігаційні градієнти
        static let navigationBar = LinearGradient(
            colors: [Palette.primaryRed, Palette.deepRed, Palette.darkRed, Palette.primaryRed],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let tabBar = LinearGradient(
            colors: [Palette.black, Palette.deepRed, Palette.primaryRed, Palette.black],
            startPoint: .leading,
            endPoint: .trailing
        )
        
        // Кнопки та елементи
        static let button = LinearGradient(
            colors: [Palette.primaryRed, Palette.deepRed],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let surface = LinearGradient(
            colors: [Palette.surface, Palette.surfaceLight],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        // Акцентні градієнти
        static let gold = LinearGradient(
            colors: [Palette.gold, Color(hex: "FFA000")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let purple = LinearGradient(
            colors: [Palette.purple, Palette.lightPurple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    struct Shadow {
        static let red = Color(hex: "FF2D55").opacity(0.3)
        static let purple = Color(hex: "7B1FA2").opacity(0.3)
        static let gold = Color(hex: "FFD700").opacity(0.3)
    }
}
