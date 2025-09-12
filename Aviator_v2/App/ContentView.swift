import SwiftUI
import ComposableArchitecture
import CoreLocation

struct ContentView: View {
    let store: StoreOf<AppFeature>
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            TabView(selection: viewStore.binding(get: \.selectedTab, send: { .selectTab($0) })) {
                MapView(store: self.store.scope(state: \.map, action: { .map($0) }))
                    .tabItem {
                        Image(systemName: "map")
                        Text("Map")
                    }
                    .tag(AppFeature.State.Tab.map)
                
                AirlinesView(store: self.store.scope(state: \.airlines, action: { .airlines($0) }))
                    .tabItem {
                        Image(systemName: "airplane")
                        Text("Airlines")
                    }
                    .tag(AppFeature.State.Tab.airlines)
                
                RoutesView(store: self.store.scope(state: \.routes, action: { .routes($0) }))
                    .tabItem {
                        Image(systemName: "airplane.departure")
                        Text("Routes")
                    }
                    .tag(AppFeature.State.Tab.routes)
                
                Text("Tab 4")
                    .tabItem {
                        Image(systemName: "questionmark.circle")
                        Text("Tab 4")
                    }
                    .tag(AppFeature.State.Tab.tab4)
            }
            .environmentObject(locationManager)
            .tint(Theme.Palette.primaryRed)
            .preferredColorScheme(.dark)
            .background(Theme.Gradient.background)
            .toolbarBackground(Theme.Gradient.tabBar, for: .tabBar)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .tabBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
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
