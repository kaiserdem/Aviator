import ComposableArchitecture

struct AppFeature: Reducer {
    struct State: Equatable {
        enum Tab: Hashable { case hotels, aviationSports, tab3, tab4 }
        var selectedTab: Tab = .hotels
        var hotels = HotelsFeature.State()
        var aviationSports = AviationSportsFeature.State()
        var tab3 = Tab3Feature.State()
        var tab4 = Tab4Feature.State()
    }

    enum Action: Equatable {
        case selectTab(State.Tab)
        case hotels(HotelsFeature.Action)
        case aviationSports(AviationSportsFeature.Action)
        case tab3(Tab3Feature.Action)
        case tab4(Tab4Feature.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.hotels, action: /Action.hotels) { HotelsFeature() }
        Scope(state: \.aviationSports, action: /Action.aviationSports) { AviationSportsFeature() }
        Scope(state: \.tab3, action: /Action.tab3) { Tab3Feature() }
        Scope(state: \.tab4, action: /Action.tab4) { Tab4Feature() }

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
