import ComposableArchitecture
import Foundation

struct FlightsFeature: Reducer {
    struct State: Equatable {
        var isLoading: Bool = false
        var flights: [FlightState] = []
    }

    enum Action: Equatable {
        case onAppear
        case _setLoading(Bool)
        case _flightsResponse([FlightState])
    }

    @Dependency(\.flightClient) var flightClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    let result = await flightClient.fetchStates()
                    await send(._flightsResponse(result))
                }
            case let ._setLoading(flag):
                state.isLoading = flag
                return .none
            case let ._flightsResponse(f):
                state.flights = f
                state.isLoading = false
                return .none
            }
        }
    }
}

struct FlightClient {
    var fetchStates: @Sendable () async -> [FlightState]
}

extension DependencyValues {
    var flightClient: FlightClient {
        get { self[FlightClientKey.self] }
        set { self[FlightClientKey.self] = newValue }
    }
}

enum FlightClientKey: DependencyKey {
    static let liveValue: FlightClient = .init(fetchStates: {
        await NetworkService.shared.fetchOpenSkyStates()
    })
    static let testValue: FlightClient = .init(fetchStates: { [] })
}


