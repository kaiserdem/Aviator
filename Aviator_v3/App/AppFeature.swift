import ComposableArchitecture

struct AppFeature: Reducer {
    struct State: Equatable {
        enum Tab: Hashable { case search, results, saved, profile }
        var selectedTab: Tab = .search
        var search = SearchFeature.State()
        var results = ResultsFeature.State()
        var saved = SavedFeature.State()
        var profile = ProfileFeature.State()
    }

    enum Action: Equatable {
        case selectTab(State.Tab)
        case search(SearchFeature.Action)
        case results(ResultsFeature.Action)
        case saved(SavedFeature.Action)
        case profile(ProfileFeature.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.search, action: /Action.search) { SearchFeature() }
        Scope(state: \.results, action: /Action.results) { ResultsFeature() }
        Scope(state: \.saved, action: /Action.saved) { SavedFeature() }
        Scope(state: \.profile, action: /Action.profile) { ProfileFeature() }

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
