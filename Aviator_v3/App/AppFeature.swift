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
                
            case .search(.searchFlights):
                // Коли SearchFeature запускає пошук, перевіряємо чи є параметри
                print("🔍 AppFeature: Received searchFlights action")
                if let parameters = state.search.searchParameters {
                    print("✅ AppFeature: Found search parameters, switching to Results tab")
                    state.selectedTab = .results
                    return .send(.results(.searchWithParameters(parameters)))
                } else {
                    print("❌ AppFeature: No search parameters found")
                }
                return .none
                
            case let .results(._flightOffersResponse(offers)):
                // Коли ResultsFeature отримує результати, повідомляємо SearchFeature
                let count = offers.count
                print("📊 AppFeature: Received \(count) flight offers, notifying SearchFeature")
                return .send(.search(.searchCompleted(count)))
                
            default:
                return .none
            }
        }
    }
}
