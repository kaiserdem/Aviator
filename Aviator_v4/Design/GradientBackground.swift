import SwiftUI

struct GradientBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.4, green: 0.6, blue: 0.9),      
                Color(red: 0.3, green: 0.5, blue: 0.8),      
                Color(red: 0.2, green: 0.4, blue: 0.7),      
                Color(red: 0.15, green: 0.3, blue: 0.6),     
                Color(red: 0.1, green: 0.2, blue: 0.5),      
                Color(red: 0.05, green: 0.1, blue: 0.3)      
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
            
            LinearGradient(
                gradient: Gradient(colors: [
                    
                    
                    
                    
                    
                    
                    Color(red: 1.0, green: 0.55, blue: 0.2),     
                    Color(red: 0.95, green: 0.4, blue: 0.15),   
                    
                    
                    Color(red: 0.8, green: 0.25, blue: 0.1),     
                    Color(red: 0.6, green: 0.15, blue: 0.08),    
                    
                    
                    Color(red: 0.4, green: 0.1, blue: 0.2),      
                    Color(red: 0.3, green: 0.05, blue: 0.15),   
                    
                    
                    Color(red: 0.25, green: 0.1, blue: 0.4),     
                    Color(red: 0.15, green: 0.05, blue: 0.25),  
                    Color(red: 0.1, green: 0.02, blue: 0.15)    
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.clear,
                    Color(red: 0.25, green: 0.1, blue: 0.4).opacity(0.1)
                ]),
                center: .topLeading,
                startRadius: 0,
                endRadius: 500
            )
            
            
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
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 1.0, green: 0.45, blue: 0.15),    
                    Color(red: 0.95, green: 0.35, blue: 0.2),   
                    Color(red: 0.85, green: 0.25, blue: 0.3),   
                    Color(red: 0.7, green: 0.2, blue: 0.4),     
                    Color(red: 0.5, green: 0.15, blue: 0.5),     
                    Color(red: 0.3, green: 0.08, blue: 0.4),     
                    Color(red: 0.15, green: 0.03, blue: 0.25)   
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            
            VStack {
                Spacer()
                
                
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.clear,
                                Color(red: 0.25, green: 0.1, blue: 0.4).opacity(0.3)
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


extension Color {
    
    static let aviationCream = Color(red: 1.0, green: 0.95, blue: 0.7)
    static let aviationLightOrange = Color(red: 1.0, green: 0.85, blue: 0.5)
    
    
    static let aviationBrightOrange = Color(red: 1.0, green: 0.7, blue: 0.3)
    static let aviationDeepOrange = Color(red: 1.0, green: 0.55, blue: 0.2)
    
    
    static let aviationRedOrange = Color(red: 0.8, green: 0.25, blue: 0.1)
    static let aviationDarkRed = Color(red: 0.6, green: 0.15, blue: 0.08)
    
    
    static let aviationPurpleBurgundy = Color(red: 0.4, green: 0.1, blue: 0.2)
    static let aviationDeepPurple = Color(red: 0.3, green: 0.05, blue: 0.15)
    
    
    static let aviationDarkPurple = Color(red: 0.25, green: 0.1, blue: 0.4)
    static let aviationAlmostBlack = Color(red: 0.1, green: 0.02, blue: 0.15)
    
    
    static let buttonTextColor = Color(red: 0.25, green: 0.1, blue: 0.4)
    
    
    static let gradientTop = Color.aviationCream
    static let gradientMiddle = Color.aviationDeepOrange
    static let gradientBottom = Color.aviationAlmostBlack
}


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
