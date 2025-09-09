import ComposableArchitecture

struct AppFeature: Reducer {
    struct State: Equatable {
        enum Tab: Hashable { case flights, news, airports, aircraft }
        var selectedTab: Tab = .flights
        var flights = FlightsFeature.State()
        var news = NewsFeature.State()
        var airports = AirportsFeature.State()
        var aircraft = AircraftFeature.State()
    }

    enum Action: Equatable {
        case selectTab(State.Tab)
        case flights(FlightsFeature.Action)
        case news(NewsFeature.Action)
        case airports(AirportsFeature.Action)
        case aircraft(AircraftFeature.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.flights, action: /Action.flights) { FlightsFeature() }
        Scope(state: \.news, action: /Action.news) { NewsFeature() }
        Scope(state: \.airports, action: /Action.airports) { AirportsFeature() }
        Scope(state: \.aircraft, action: /Action.aircraft) { AircraftFeature() }

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


