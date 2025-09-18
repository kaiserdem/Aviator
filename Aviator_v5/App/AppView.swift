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
                
                Tab2View(
                    store: self.store.scope(
                        state: \.tab2,
                        action: \.tab2
                    )
                )
                .tabItem {
                    Image(systemName: AppFeature.Tab.tab2.icon)
                    Text(AppFeature.Tab.tab2.rawValue)
                }
                .tag(AppFeature.Tab.tab2)
                
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
            .accentColor(.blue)
        }
    }
}
