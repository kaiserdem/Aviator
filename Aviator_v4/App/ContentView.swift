import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    let store: StoreOf<AppFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            TabView(selection: viewStore.binding(get: \.selectedTab, send: { .selectTab($0) })) {
                HotelsView(store: self.store.scope(state: \.hotels, action: { .hotels($0) }))
                    .tabItem {
                        Image(systemName: "bed.double")
                        Text("Hotels")
                    }
                    .tag(AppFeature.State.Tab.hotels)
                
                AviationSportsView(store: self.store.scope(state: \.aviationSports, action: { .aviationSports($0) }))
                    .tabItem {
                        Image(systemName: "airplane.circle")
                        Text("Aviation Sports")
                    }
                    .tag(AppFeature.State.Tab.aviationSports)
                
                Tab3View(store: self.store.scope(state: \.tab3, action: { .tab3($0) }))
                    .tabItem {
                        Image(systemName: "airplane")
                        Text("Flights")
                    }
                    .tag(AppFeature.State.Tab.tab3)
                
                Tab4View(store: self.store.scope(state: \.tab4, action: { .tab4($0) }))
                    .tabItem {
                        Image(systemName: "airplane.departure")
                        Text("Tracker")
                    }
                    .tag(AppFeature.State.Tab.tab4)
            }
            .tint(.red)
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
