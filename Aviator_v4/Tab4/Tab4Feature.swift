import ComposableArchitecture
import Foundation

struct Tab4Feature: Reducer {
    struct State: Equatable {
        var isLoading = false
        var flightStatus: FlightStatus?
        var searchText = ""
        var errorMessage: String?
        var trackedFlights: [FlightStatus] = []
        
        init() {}
    }
    
    enum Action: Equatable {
        case onAppear
        case searchTextChanged(String)
        case trackFlight
        case flightStatusResponse(FlightStatus?)
        case searchError(String)
        case addToTracked(FlightStatus)
        case removeFromTracked(String)
    }
    
    @Dependency(\.trackerClient) var trackerClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
                
            case let .searchTextChanged(text):
                state.searchText = text
                return .none
                
            case .trackFlight:
                guard !state.searchText.isEmpty else { return .none }
                state.isLoading = true
                state.errorMessage = nil
                return .run { [searchText = state.searchText] send in
                    let flightStatus = await trackerClient.trackFlight(searchText)
                    await send(.flightStatusResponse(flightStatus))
                }
                
            case let .flightStatusResponse(flightStatus):
                state.isLoading = false
                state.flightStatus = flightStatus
                if let status = flightStatus {
                    return .send(.addToTracked(status))
                }
                return .none
                
            case let .searchError(error):
                state.isLoading = false
                state.errorMessage = error
                return .none
                
            case let .addToTracked(flightStatus):
                if !state.trackedFlights.contains(where: { $0.flightNumber == flightStatus.flightNumber }) {
                    state.trackedFlights.append(flightStatus)
                }
                return .none
                
            case let .removeFromTracked(flightNumber):
                state.trackedFlights.removeAll { $0.flightNumber == flightNumber }
                return .none
            }
        }
    }
}
