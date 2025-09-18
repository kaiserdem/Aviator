import SwiftUI
import ComposableArchitecture

struct AppView: View {
    let store: StoreOf<AppFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            TabView(selection: viewStore.binding(
                get: \.selectedTab,
                send: { .selectTab($0) }
            )) {
                AviationView(
                    store: self.store.scope(
                        state: \.aviation,
                        action: \.aviation
                    )
                )
                .tabItem {
                    Image(systemName: AppFeature.Tab.aviation.icon)
                    Text(AppFeature.Tab.aviation.rawValue)
                }
                .tag(AppFeature.Tab.aviation)
                
                PilotsView(
                    store: self.store.scope(
                        state: \.pilots,
                        action: \.pilots
                    )
                )
                .tabItem {
                    Image(systemName: AppFeature.Tab.pilots.icon)
                    Text(AppFeature.Tab.pilots.rawValue)
                }
                .tag(AppFeature.Tab.pilots)
                
                NewsView(
                    store: self.store.scope(
                        state: \.news,
                        action: \.news
                    )
                )
                .tabItem {
                    Image(systemName: AppFeature.Tab.news.icon)
                    Text(AppFeature.Tab.news.rawValue)
                }
                .tag(AppFeature.Tab.news)
                
                Tab3View(
                    store: self.store.scope(
                        state: \.tab3,
                        action: \.tab3
                    )
                )
                .tabItem {
                    Image(systemName: AppFeature.Tab.tab3.icon)
                    Text(AppFeature.Tab.tab3.rawValue)
                }
                .tag(AppFeature.Tab.tab3)
            }
            .accentColor(Theme.Palette.vibrantPink)
            .onAppear {
                let appearance = UITabBarAppearance()
                appearance.configureWithOpaqueBackground()
                
                // Створюємо градієнт для таббару
                let gradientLayer = CAGradientLayer()
                gradientLayer.colors = [
                    Theme.Palette.primaryPurple.cgColor,
                    Theme.Palette.midPurple.cgColor,
                    Theme.Palette.deepMagenta.cgColor
                ]
                gradientLayer.startPoint = CGPoint(x: 0, y: 0)
                gradientLayer.endPoint = CGPoint(x: 1, y: 1)
                gradientLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100)
                
                // Конвертуємо градієнт в UIImage
                UIGraphicsBeginImageContext(gradientLayer.frame.size)
                gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
                let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                appearance.backgroundImage = gradientImage
                appearance.backgroundColor = UIColor.clear
                
                appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.7)
                appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                    .foregroundColor: UIColor.white.withAlphaComponent(0.7)
                ]
                
                appearance.stackedLayoutAppearance.selected.iconColor = UIColor.white
                appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                    .foregroundColor: UIColor.white
                ]
                
                UITabBar.appearance().standardAppearance = appearance
                UITabBar.appearance().scrollEdgeAppearance = appearance
                
                // Додаємо тінь для таббару
                UITabBar.appearance().layer.shadowColor = UIColor.black.cgColor
                UITabBar.appearance().layer.shadowOffset = CGSize(width: 0, height: -2)
                UITabBar.appearance().layer.shadowOpacity = 0.3
                UITabBar.appearance().layer.shadowRadius = 8
                UITabBar.appearance().clipsToBounds = false
            }
        }
    }
}
