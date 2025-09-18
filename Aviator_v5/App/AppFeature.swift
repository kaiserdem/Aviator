import ComposableArchitecture
import SwiftUI

@Reducer
struct AppFeature {
    @ObservableState
    struct State: Equatable {
        var selectedTab: Tab = .aviation
        var aviation = AviationFeature.State()
        var news = NewsFeature.State()
        var pilots = PilotsFeature.State()
        var tab3 = Tab3Feature.State()
    }
    
    enum Action {
        case selectTab(Tab)
        case aviation(AviationFeature.Action)
        case news(NewsFeature.Action)
        case pilots(PilotsFeature.Action)
        case tab3(Tab3Feature.Action)
    }
    
    enum Tab: String, CaseIterable {
        case aviation = "Aviation"
        case pilots = "Pilots"
        case news = "News"
        case tab3 = "Tab 4"
        
        var icon: String {
            switch self {
            case .aviation: return "airplane"
            case .pilots: return "person.2"
            case .news: return "newspaper"
            case .tab3: return "gear"
            }
        }
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.aviation, action: \.aviation) {
            AviationFeature()
        }
        Scope(state: \.news, action: \.news) {
            NewsFeature()
        }
        Scope(state: \.pilots, action: \.pilots) {
            PilotsFeature()
        }
        Scope(state: \.tab3, action: \.tab3) {
            Tab3Feature()
        }
        
        Reduce { state, action in
            switch action {
            case let .selectTab(tab):
                state.selectedTab = tab
                return .none
            case .aviation, .news, .pilots, .tab3:
                return .none
            }
        }
    }
}
