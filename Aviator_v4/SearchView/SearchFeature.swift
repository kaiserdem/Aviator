import ComposableArchitecture
import Foundation

struct SearchFeature: Reducer {
    struct State: Equatable {
        var isLoading = false
        var flights: [Flight] = []
        var origin = ""
        var destination = ""
        var departureDate = Date()
        var passengers = 1
        var errorMessage: String?
        var hasSearched = false // Чи був пошук виконаний
        
        init() {}
    }
    
    enum Action: Equatable {
        case onAppear
        case originChanged(String)
        case destinationChanged(String)
        case departureDateChanged(Date)
        case passengersChanged(Int)
        case searchFlights
        case flightsResponse([Flight])
        case searchError(String)
    }
    
    @Dependency(\.flightsClient) var flightsClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { [origin = state.origin, destination = state.destination, departureDate = state.departureDate, passengers = state.passengers] send in
                    let flights = await flightsClient.searchFlights(origin, destination, departureDate, passengers)
                    await send(.flightsResponse(flights))
                }
                
            case let .originChanged(origin):
                state.origin = origin
                return .none
                
            case let .destinationChanged(destination):
                state.destination = destination
                return .none
                
            case let .departureDateChanged(date):
                state.departureDate = date
                return .none
                
            case let .passengersChanged(count):
                state.passengers = count
                return .none
                
            case .searchFlights:
                // Перевіряємо чи заповнені обов'язкові поля
                guard !state.origin.isEmpty && !state.destination.isEmpty else {
                    state.errorMessage = "Please enter both origin and destination"
                    return .none
                }
                
                guard state.origin != state.destination else {
                    state.errorMessage = "Origin and destination cannot be the same"
                    return .none
                }
                
                state.isLoading = true
                state.errorMessage = nil
                state.hasSearched = true
                return .run { [origin = state.origin, destination = state.destination, departureDate = state.departureDate, passengers = state.passengers] send in
                    let flights = await flightsClient.searchFlights(origin, destination, departureDate, passengers)
                    await send(.flightsResponse(flights))
                }
                
            case let .flightsResponse(flights):
                state.isLoading = false
                state.flights = flights
                return .none
                
            case let .searchError(error):
                state.isLoading = false
                state.errorMessage = error
                return .none
            }
        }
    }
}
