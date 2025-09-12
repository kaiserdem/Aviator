import ComposableArchitecture
import Foundation

struct SavedFeature: Reducer {
    struct State: Equatable {
        var savedFlights: [SavedFlight] = []
        var selectedFlight: SavedFlight?
        var isLoading = false
    }

    enum Action: Equatable {
        case onAppear
        case refresh
        case deleteFlight(SavedFlight)
        case selectFlight(SavedFlight?)
        case _savedFlightsResponse([SavedFlight])
    }

    @Dependency(\.databaseClient) var databaseClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear, .refresh:
                state.isLoading = true
                return .run { send in
                    let flights = try await databaseClient.getSavedFlights()
                    await send(._savedFlightsResponse(flights))
                }
                
            case let .deleteFlight(flight):
                return .run { send in
                    try await databaseClient.deleteSavedFlight(flight)
                    await send(.refresh)
                }
                
            case let .selectFlight(flight):
                state.selectedFlight = flight
                return .none
                
            case let ._savedFlightsResponse(flights):
                state.isLoading = false
                state.savedFlights = flights
                return .none
            }
        }
    }
}

