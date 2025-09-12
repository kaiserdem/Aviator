import SwiftUI

struct Theme {
    struct Palette {
        // Основні кольори з більшим контрастом (як у Aviator_v2)
        static let primaryRed = Color(hex: "#FF1744")       // Яскраво-червоний акцент
        static let darkRed = Color(hex: "#B71C1C")          // Темно-червоний
        static let deepRed = Color(hex: "#8D0000")           // Глибокий червоний
        static let black = Color(hex: "#000000")             // Чорний
        static let darkGray = Color(hex: "#212121")          // Темно-сірий
        
        // Пурпурові градієнти
        static let deepPurple = Color(hex: "4A148C")       // Темно-пурпуровий
        static let purple = Color(hex: "7B1FA2")          // Пурпуровий
        static let lightPurple = Color(hex: "E1BEE7")     // Світло-пурпуровий
        static let pinkPurple = Color(hex: "C2185B")      // Пурпурово-рожевий
        
        // Акцентні кольори
        static let gold = Color(hex: "FFD700")            // Золотий/жовтий
        static let green = Color(hex: "4CAF50")          // Зелений
        static let blue = Color(hex: "2196F3")           // Синій
        
        // Фонові кольори
        static let background = Color(hex: "#1A1A1A")        // Темний фон
        static let surface = Color(hex: "#2A2A2A")           // Темна поверхня
        static let cardBackground = Color(hex: "#1E1E1E")    // Фон карток
        
        // Текстові кольори
        static let textPrimary = Color.white                 // Білий текст
        static let textSecondary = Color(hex: "#CCCCCC")    // Світло-сірий текст
        static let textTertiary = Color(hex: "#999999")     // Сірий текст
        
        // Акцентні кольори
        static let accent = Color(hex: "#FF6B6B")           // Світло-червоний акцент
        static let success = Color(hex: "#4CAF50")           // Зелений для успіху
        static let warning = Color(hex: "#FF9800")           // Помаранчевий для попереджень
    }
    
    struct Gradient {
        // Основний градієнт фону з більшим контрастом (як у Aviator_v2)
        static let background = LinearGradient(
            colors: [
                Palette.primaryRed,
                Palette.deepRed,
                Palette.darkRed,
                Palette.black
            ],
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
        
        // Градієнт для таббару (як у Aviator_v2)
        static let tabBar = LinearGradient(
            colors: [
                Palette.black,
                Palette.deepRed,
                Palette.deepRed,
                Palette.primaryRed
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        // Кнопки та елементи
        static let button = LinearGradient(
            colors: [Palette.primaryRed, Palette.deepRed],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let surface = LinearGradient(
            colors: [Palette.surface, Palette.deepRed],
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
