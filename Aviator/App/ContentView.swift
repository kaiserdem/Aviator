import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    let store: StoreOf<AppFeature>

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            TabView(selection: viewStore.binding(get: \.selectedTab, send: { .selectTab($0) })) {
                FlightsView(
                    store: store.scope(state: \.flights, action: AppFeature.Action.flights)
                )
                .tabItem { Label("Flights", systemImage: "airplane") }
                .tag(AppFeature.State.Tab.flights)

                NewsView(
                    store: store.scope(state: \.news, action: AppFeature.Action.news)
                )
                .tabItem { Label("News", systemImage: "newspaper") }
                .tag(AppFeature.State.Tab.news)

                AirportsView(
                    store: store.scope(state: \.airports, action: AppFeature.Action.airports)
                )
                .tabItem { Label("Airports", systemImage: "building.2") }
                .tag(AppFeature.State.Tab.airports)

                AircraftView(
                    store: store.scope(state: \.aircraft, action: AppFeature.Action.aircraft)
                )
                .tabItem { Label("Aircraft", systemImage: "airplane.circle") }
                .tag(AppFeature.State.Tab.aircraft)
            }
        }
    }
}

#Preview {
    ContentView(
        store: Store(initialState: AppFeature.State()) { AppFeature() }
    )
}


