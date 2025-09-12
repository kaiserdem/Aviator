import ComposableArchitecture

struct AppFeature: Reducer {
    struct State: Equatable {
        enum Tab: Hashable { case map, airlines, tab3, tab4 }
        var selectedTab: Tab = .map
        var map = MapFeature.State()
        var airlines = AirlinesFeature.State()
        // TODO: Add tab3 and tab4 features
    }

    enum Action: Equatable {
        case selectTab(State.Tab)
        case map(MapFeature.Action)
        case airlines(AirlinesFeature.Action)
        // TODO: Add tab3 and tab4 actions
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.map, action: /Action.map) { MapFeature() }
        Scope(state: \.airlines, action: /Action.airlines) { AirlinesFeature() }
        // TODO: Add tab3 and tab4 scopes

        Reduce { state, action in
            switch action {
            case let .selectTab(tab):
                state.selectedTab = tab
                return .none
            default:
                return .none
            }
        }
    }
}
