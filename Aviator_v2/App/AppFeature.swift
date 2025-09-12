import ComposableArchitecture

struct AppFeature: Reducer {
    struct State: Equatable {
        enum Tab: Hashable { case map, airlines, routes, stats }
        var selectedTab: Tab = .map
        var map = MapFeature.State()
        var airlines = AirlinesFeature.State()
        var routes = RoutesFeature.State()
        var stats = StatsFeature.State()
    }

    enum Action: Equatable {
        case selectTab(State.Tab)
        case map(MapFeature.Action)
        case airlines(AirlinesFeature.Action)
        case routes(RoutesFeature.Action)
        case stats(StatsFeature.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.map, action: /Action.map) { MapFeature() }
        Scope(state: \.airlines, action: /Action.airlines) { AirlinesFeature() }
        Scope(state: \.routes, action: /Action.routes) { RoutesFeature() }
        Scope(state: \.stats, action: /Action.stats) { StatsFeature() }

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
