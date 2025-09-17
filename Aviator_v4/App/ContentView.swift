import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    let store: StoreOf<AppFeature>
    @State private var tabViewId = UUID()
    
    var body: some View {
        ZStack {
            AviationGradientBackground()
            
            WithViewStore(self.store, observe: { $0 }) { viewStore in
                TabView(selection: viewStore.binding(get: \.selectedTab, send: { .selectTab($0) })) {
                    
                    AviationSportsView(
                        store: self.store.scope(state: \.aviationSports, action: { .aviationSports($0) }),
                        appStore: self.store
                    )
                        .tabItem {
                            Image(systemName: "airplane.circle")
                            Text("Aviation Sports")
                        }
                        .tag(AppFeature.State.Tab.aviationSports)
                    
                    
                    SearchView(
                        store: self.store.scope(state: \.tab3, action: { .tab3($0) }),
                        appStore: self.store
                    )
                        .tabItem {
                            Image(systemName: "magnifyingglass")
                            Text("Search")
                        }
                        .tag(AppFeature.State.Tab.tab3)
                    
                    
                    FavoritesView(
                        store: self.store.scope(state: \.favorites, action: { .favorites($0) }),
                        appStore: self.store
                    )
                        .tabItem {
                            Image(systemName: "heart.fill")
                            Text("Favorites")
                        }
                        .tag(AppFeature.State.Tab.favorites)
                    
                    
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
                
                DispatchQueue.main.async {
                    let appearance = UITabBarAppearance()
                    appearance.configureWithTransparentBackground()
                    appearance.backgroundColor = UIColor.clear
                    
                    
                    appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white
                    appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                        .foregroundColor: UIColor.white
                    ]
                    
                    
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
