import ComposableArchitecture

struct AirportsFeature: Reducer {
    struct State: Equatable {
        var isLoading: Bool = false
        var query: String = ""
        var airports: [Airport] = []
    }
    enum Action: Equatable {
        case onAppear
        case setQuery(String)
        case _response([Airport])
    }

    @Dependency(\.airportsClient) var airportsClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                if !state.airports.isEmpty { return .none }
                state.isLoading = true
                return .run { send in
                    let list = await airportsClient.fetchAirports()
                    await send(._response(list))
                }
            case let .setQuery(text):
                state.query = text
                return .none
            case let ._response(list):
                state.isLoading = false
                state.airports = list
                return .none
            }
        }
    }
}


