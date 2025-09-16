import SwiftUI

struct GradientBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.4, green: 0.6, blue: 0.9),      // Світло-синій зверху
                Color(red: 0.3, green: 0.5, blue: 0.8),      // Синій
                Color(red: 0.2, green: 0.4, blue: 0.7),      // Темно-синій
                Color(red: 0.15, green: 0.3, blue: 0.6),     // Глибокий синій
                Color(red: 0.1, green: 0.2, blue: 0.5),      // Дуже темний синій
                Color(red: 0.05, green: 0.1, blue: 0.3)      // Майже чорний синій
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

struct AviationGradientBackground: View {
    var body: some View {
        ZStack {
            // Комбінований градієнт на основі всіх 4 зображень
            LinearGradient(
                gradient: Gradient(colors: [
                    // З першого зображення - світлі теплі тони
                    //Color(red: 1.0, green: 0.95, blue: 0.7),     // Блідо-жовтий/кремовий
                    //Color(red: 1.0, green: 0.85, blue: 0.5),     // Світло-помаранчевий
                    
                    // З другого зображення - яскраві помаранчеві тони
                    //Color(red: 1.0, green: 0.7, blue: 0.3),      // Яскраво-помаранчевий
                    Color(red: 1.0, green: 0.55, blue: 0.2),     // Насичений помаранчевий
                    Color(red: 0.95, green: 0.4, blue: 0.15),   // Темно-помаранчевий
                    
                    // Перехід до червоних тонів
                    Color(red: 0.8, green: 0.25, blue: 0.1),     // Червоно-помаранчевий
                    Color(red: 0.6, green: 0.15, blue: 0.08),    // Темно-червоний
                    
                    // З третього зображення - фіолетово-бордові тони
                    Color(red: 0.4, green: 0.1, blue: 0.2),      // Темно-фіолетово-бордовий
                    Color(red: 0.3, green: 0.05, blue: 0.15),   // Глибокий фіолетово-бордовий
                    
                    // З четвертого зображення - суцільний темно-фіолетовий
                    Color(red: 0.25, green: 0.1, blue: 0.4),     // Темно-фіолетовий
                    Color(red: 0.15, green: 0.05, blue: 0.25),  // Дуже темний фіолетовий
                    Color(red: 0.1, green: 0.02, blue: 0.15)    // Майже чорний фіолетовий
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Додатковий радіальний градієнт для глибини
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.clear,
                    Color.black.opacity(0.1)
                ]),
                center: .topLeading,
                startRadius: 0,
                endRadius: 500
            )
            
            // Тонкі атмосферні ефекти (менш помітні хмари)
            VStack {
                HStack {
                    Spacer()
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 120, height: 120)
                        .offset(x: 40, y: -40)
                        .blur(radius: 30)
                }
                Spacer()
                HStack {
                    Circle()
                        .fill(Color.white.opacity(0.06))
                        .frame(width: 160, height: 160)
                        .offset(x: -50, y: 40)
                        .blur(radius: 40)
                    Spacer()
                    Circle()
                        .fill(Color.white.opacity(0.04))
                        .frame(width: 100, height: 100)
                        .offset(x: 60, y: -30)
                        .blur(radius: 25)
                }
                Spacer()
                HStack {
                    Spacer()
                    Circle()
                        .fill(Color.white.opacity(0.03))
                        .frame(width: 140, height: 140)
                        .offset(x: 40, y: 50)
                        .blur(radius: 35)
                }
            }
        }
        .ignoresSafeArea()
    }
}

struct SunsetGradientBackground: View {
    var body: some View {
        ZStack {
            // Основний градієнт заходу сонця
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 1.0, green: 0.45, blue: 0.15),    // Яскраво-помаранчевий
                    Color(red: 0.95, green: 0.35, blue: 0.2),   // Помаранчевий
                    Color(red: 0.85, green: 0.25, blue: 0.3),   // Темно-помаранчевий
                    Color(red: 0.7, green: 0.2, blue: 0.4),     // Перехід до фіолетового
                    Color(red: 0.5, green: 0.15, blue: 0.5),     // Фіолетово-синій
                    Color(red: 0.3, green: 0.08, blue: 0.4),     // Темний фіолетовий
                    Color(red: 0.15, green: 0.03, blue: 0.25)   // Майже чорний
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Додаткові ефекти
            VStack {
                Spacer()
                
                // Імітація горизонту
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.clear,
                                Color.black.opacity(0.3)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 100)
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Кольорові константи для використання в інших компонентах

extension Color {
    // З першого зображення - світлі тони
    static let aviationCream = Color(red: 1.0, green: 0.95, blue: 0.7)
    static let aviationLightOrange = Color(red: 1.0, green: 0.85, blue: 0.5)
    
    // З другого зображення - яскраві помаранчеві
    static let aviationBrightOrange = Color(red: 1.0, green: 0.7, blue: 0.3)
    static let aviationDeepOrange = Color(red: 1.0, green: 0.55, blue: 0.2)
    
    // Перехідні червоні тони
    static let aviationRedOrange = Color(red: 0.8, green: 0.25, blue: 0.1)
    static let aviationDarkRed = Color(red: 0.6, green: 0.15, blue: 0.08)
    
    // З третього зображення - фіолетово-бордові
    static let aviationPurpleBurgundy = Color(red: 0.4, green: 0.1, blue: 0.2)
    static let aviationDeepPurple = Color(red: 0.3, green: 0.05, blue: 0.15)
    
    // З четвертого зображення - темно-фіолетові
    static let aviationDarkPurple = Color(red: 0.25, green: 0.1, blue: 0.4)
    static let aviationAlmostBlack = Color(red: 0.1, green: 0.02, blue: 0.15)
    
    // Градієнтні кольори (ключові точки)
    static let gradientTop = Color.aviationCream
    static let gradientMiddle = Color.aviationDeepOrange
    static let gradientBottom = Color.aviationAlmostBlack
}

// MARK: - Модифікатори для застосування градієнтів

struct GradientBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            AviationGradientBackground()
            content
        }
    }
}

extension View {
    func aviationGradientBackground() -> some View {
        modifier(GradientBackgroundModifier())
    }
}

#Preview {
    VStack {
        Text("Aviation Gradient Background")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.white)
        
        Spacer()
        
        Text("Комбінований градієнт з 4 зображень")
            .font(.title2)
            .foregroundColor(.white.opacity(0.9))
        
        Spacer()
    }
    .aviationGradientBackground()
}
