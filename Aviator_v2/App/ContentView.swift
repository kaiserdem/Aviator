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
                
                Text("Tab 3")
                    .tabItem {
                        Image(systemName: "questionmark.circle")
                        Text("Tab 3")
                    }
                    .tag(AppFeature.State.Tab.tab3)
                
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
            .toolbarBackground(Theme.Gradient.navigationBar, for: .navigationBar)
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
