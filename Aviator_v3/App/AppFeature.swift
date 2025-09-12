import ComposableArchitecture
import Foundation

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
        case searchCompleted(SearchParameters)
    }
    
    struct SearchParameters: Equatable {
        let origin: String
        let destination: String
        let departureDate: Date
        let returnDate: Date
        let adults: Int
        let children: Int
        let infants: Int
        let travelClass: String
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
                
            case let .searchCompleted(parameters):
                // Передаємо параметри пошуку до ResultsFeature та переключаємося на вкладку Results
                state.selectedTab = .results
                return .send(.results(.searchWithParameters(parameters)))
                
            default:
                return .none
            }
        }
    }
}
