import ComposableArchitecture

struct AircraftFeature: Reducer {
    struct State: Equatable {
        var isLoading: Bool = false
        var query: String = ""
        var titles: [String] = []
        var selected: AircraftDetail?
    }
    enum Action: Equatable {
        case onAppear
        case setQuery(String)
        case _titles([String])
        case selectTitle(String)
        case _detail(AircraftDetail)
    }

    @Dependency(\.aircraftClient) var aircraftClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                if !state.titles.isEmpty { return .none }
                state.isLoading = true
                return .run { send in
                    let list = await aircraftClient.listTitles()
                    await send(._titles(list))
                }
            case let .setQuery(q):
                state.query = q
                return .none
            case let ._titles(list):
                state.isLoading = false
                state.titles = list
                return .none
            case let .selectTitle(title):
                return .run { send in
                    let d = await aircraftClient.fetchDetail(title)
                    await send(._detail(d))
                }
            case let ._detail(detail):
                state.selected = detail
                return .none
            }
        }
    }
}


