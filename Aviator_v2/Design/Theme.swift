import SwiftUI

struct Theme {
    struct Palette {
        // Основні кольори з скріншота
        static let primaryRed = Color(hex: "#FF3B30")       // Яскраво-червоний акцент
        static let darkRed = Color(hex: "#8B0000")          // Темно-червоний
        static let deepRed = Color(hex: "#660000")           // Глибокий червоний
        static let black = Color(hex: "#000000")             // Чорний
        static let darkGray = Color(hex: "#1A1A1A")          // Темно-сірий
        
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
        // Основний градієнт фону (як на скріншоті)
        static let background = LinearGradient(
            colors: [
                Palette.deepRed,
                Palette.darkRed,
                Palette.black,
                Palette.darkGray
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        // Градієнт для карток та поверхонь
        static let surface = LinearGradient(
            colors: [
                Palette.surface,
                Palette.cardBackground
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        // Градієнт для кнопок
        static let button = LinearGradient(
            colors: [
                Palette.primaryRed,
                Palette.darkRed
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        // Градієнт для акцентних елементів
        static let accent = LinearGradient(
            colors: [
                Palette.accent,
                Palette.primaryRed
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
