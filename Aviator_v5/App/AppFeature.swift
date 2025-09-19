import ComposableArchitecture
import SwiftUI

@Reducer
struct AppFeature {
    @ObservableState
    struct State: Equatable {
        var selectedTab: Tab = .aviation
        var aviation = AviationEventsFeature.State()
        var news = NewsFeature.State()
        var pilots = PilotsFeature.State()
        var records = AviationRecordsFeature.State()
    }
    
    enum Action {
        case selectTab(Tab)
        case aviation(AviationEventsFeature.Action)
        case news(NewsFeature.Action)
        case pilots(PilotsFeature.Action)
        case records(AviationRecordsFeature.Action)
    }
    
    enum Tab: String, CaseIterable {
        case aviation = "Event"
        case pilots = "Pilots"
        case news = "News"
        case tab3 = "Records"
        
        var icon: String {
            switch self {
            case .aviation: return "airplane"
            case .pilots: return "person.2"
            case .news: return "newspaper"
            case .tab3: return "trophy"
            }
        }
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.aviation, action: \.aviation) {
            AviationEventsFeature()
        }
        Scope(state: \.news, action: \.news) {
            NewsFeature()
        }
        Scope(state: \.pilots, action: \.pilots) {
            PilotsFeature()
        }
        Scope(state: \.records, action: \.records) {
            AviationRecordsFeature()
        }
        
        Reduce { state, action in
            switch action {
            case let .selectTab(tab):
                state.selectedTab = tab
                return .none
            case .aviation, .news, .pilots, .records:
                return .none
            }
        }
    }
}
