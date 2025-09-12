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
            .tint(Theme.Palette.primaryRed)
            .preferredColorScheme(.dark)
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