import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    let store: StoreOf<AppFeature>

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            TabView(selection: viewStore.binding(get: \.selectedTab, send: { .selectTab($0) })) {
                SearchView(store: self.store.scope(state: \.search, action: { .search($0) }))
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("Search")
                    }
                    .tag(AppFeature.State.Tab.search)

                ResultsView(store: self.store.scope(state: \.results, action: { .results($0) }))
                    .tabItem {
                        Image(systemName: "list.bullet")
                        Text("Results")
                    }
                    .tag(AppFeature.State.Tab.results)

                SavedView(store: self.store.scope(state: \.saved, action: { .saved($0) }))
                    .tabItem {
                        Image(systemName: "bookmark.fill")
                        Text("Saved")
                    }
                    .tag(AppFeature.State.Tab.saved)

                ProfileView(store: self.store.scope(state: \.profile, action: { .profile($0) }))
                    .tabItem {
                        Image(systemName: "person.circle")
                        Text("Profile")
                    }
                    .tag(AppFeature.State.Tab.profile)
            }
            .accentColor(Theme.Palette.primaryRed)
            .background(Theme.Gradient.background)
            .onAppear {
                setupTabBarAppearance()
            }
        }
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        
        // Фон таббару з градієнтом
        appearance.backgroundColor = UIColor.clear
        
        // Стиль для нормального стану
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.6)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.6)
        ]
        
        // Стиль для вибраного стану
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Theme.Palette.primaryRed)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Theme.Palette.primaryRed)
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    ContentView(
        store: Store(initialState: AppFeature.State()) {
            AppFeature()
        }
    )
}