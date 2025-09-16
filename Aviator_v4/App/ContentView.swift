import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    let store: StoreOf<AppFeature>
    @State private var tabViewId = UUID()
    
    var body: some View {
        ZStack {
            // Градієнтний фон
            AviationGradientBackground()
            
            WithViewStore(self.store, observe: { $0 }) { viewStore in
                TabView(selection: viewStore.binding(get: \.selectedTab, send: { .selectTab($0) })) {
                    // 1. Aviation Sports (перша вкладка)
                    AviationSportsView(
                        store: self.store.scope(state: \.aviationSports, action: { .aviationSports($0) }),
                        appStore: self.store
                    )
                        .tabItem {
                            Image(systemName: "airplane.circle")
                            Text("Aviation Sports")
                        }
                        .tag(AppFeature.State.Tab.aviationSports)
                    
                    // 2. Search (друга вкладка)
                    Tab3View(store: self.store.scope(state: \.tab3, action: { .tab3($0) }))
                        .tabItem {
                            Image(systemName: "magnifyingglass")
                            Text("Search")
                        }
                        .tag(AppFeature.State.Tab.tab3)
                    
                    // 4. Favorites (четверта вкладка)
                    FavoritesView(
                        store: self.store.scope(state: \.favorites, action: { .favorites($0) }),
                        appStore: self.store
                    )
                        .tabItem {
                            Image(systemName: "heart.fill")
                            Text("Favorites")
                        }
                        .tag(AppFeature.State.Tab.favorites)
                    
                    // 5. Hotels (п'ята вкладка)
                    HotelsView(store: self.store.scope(state: \.hotels, action: { .hotels($0) }))
                        .tabItem {
                            Image(systemName: "bed.double")
                            Text("Hotels")
                        }
                        .tag(AppFeature.State.Tab.hotels)
                }
                .id(tabViewId)
            }
            .tint(.white)
            .preferredColorScheme(.dark)
            .onAppear {
                // Налаштування TabBar для стабільності
                DispatchQueue.main.async {
                    let appearance = UITabBarAppearance()
                    appearance.configureWithTransparentBackground()
                    appearance.backgroundColor = UIColor.clear
                    
                    // Налаштування для нормального стану
                    appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white
                    appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                        .foregroundColor: UIColor.white
                    ]
                    
                    // Налаштування для вибраного стану
                    appearance.stackedLayoutAppearance.selected.iconColor = UIColor.white
                    appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                        .foregroundColor: UIColor.white
                    ]
                    
                    UITabBar.appearance().standardAppearance = appearance
                    UITabBar.appearance().scrollEdgeAppearance = appearance
                    UITabBar.appearance().isTranslucent = true
                }
            }
        }
    }
}

#Preview {
    ContentView(
        store: Store(initialState: AppFeature.State()) {
            AppFeature()
        }
    )
}
