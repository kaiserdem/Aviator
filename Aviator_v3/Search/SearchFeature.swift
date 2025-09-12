import ComposableArchitecture
import Foundation

struct SearchFeature: Reducer {
    struct State: Equatable {
        var isLoading = false
        var origin: String = ""
        var destination: String = ""
        var departureDate: Date = Date()
        var returnDate: Date = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        var adults: Int = 1
        var children: Int = 0
        var infants: Int = 0
        var travelClass: String = "ECONOMY"
        var flightOffers: [FlightOffer] = []
        var selectedOffer: FlightOffer?
    }

    enum Action: Equatable {
        case onAppear
        case originChanged(String)
        case destinationChanged(String)
        case departureDateChanged(Date)
        case returnDateChanged(Date)
        case adultsChanged(Int)
        case childrenChanged(Int)
        case infantsChanged(Int)
        case travelClassChanged(String)
        case searchFlights
        case _flightOffersResponse([FlightOffer])
        case selectOffer(FlightOffer?)
    }

    @Dependency(\.amadeusClient) var amadeusClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
                
            case let .originChanged(origin):
                state.origin = origin
                return .none
                
            case let .destinationChanged(destination):
                state.destination = destination
                return .none
                
            case let .departureDateChanged(date):
                state.departureDate = date
                return .none
                
            case let .returnDateChanged(date):
                state.returnDate = date
                return .none
                
            case let .adultsChanged(count):
                state.adults = count
                print("🔄 Adults changed to: \(count)")
                return .none
                
            case let .childrenChanged(count):
                state.children = count
                print("🔄 Children changed to: \(count)")
                return .none
                
            case let .infantsChanged(count):
                state.infants = count
                print("🔄 Infants changed to: \(count)")
                return .none
                
            case let .travelClassChanged(travelClass):
                state.travelClass = travelClass
                print("🔄 Travel class changed to: \(travelClass)")
                return .none
                
            case .searchFlights:
                state.isLoading = true
                print("🔍 Searching flights with:")
                print("   Origin: \(state.origin)")
                print("   Destination: \(state.destination)")
                print("   Adults: \(state.adults)")
                print("   Children: \(state.children)")
                print("   Infants: \(state.infants)")
                print("   Travel Class: \(state.travelClass)")
                return .run { [state] send in
                    let offers = await amadeusClient.searchFlights(
                        state.origin,
                        state.destination,
                        state.departureDate,
                        state.returnDate,
                        state.adults,
                        state.children,
                        state.infants,
                        state.travelClass
                    )
                    await send(._flightOffersResponse(offers))
                }
                
            case let ._flightOffersResponse(offers):
                state.isLoading = false
                state.flightOffers = offers
                return .none
                
            case let .selectOffer(offer):
                state.selectedOffer = offer
                return .none
            }
        }
    }
}

// MARK: - Models

struct FlightOffer: Identifiable, Equatable {
    let id: UUID = UUID()
    let price: String
    let currency: String
    let origin: String
    let destination: String
    let departureDate: String
    let returnDate: String
    let airline: String
    let flightNumber: String
    let duration: String
    let stops: Int
    
    static func == (lhs: FlightOffer, rhs: FlightOffer) -> Bool {
        lhs.id == rhs.id &&
        lhs.price == rhs.price &&
        lhs.currency == rhs.currency &&
        lhs.origin == rhs.origin &&
        lhs.destination == rhs.destination &&
        lhs.departureDate == rhs.departureDate &&
        lhs.returnDate == rhs.returnDate &&
        lhs.airline == rhs.airline &&
        lhs.flightNumber == rhs.flightNumber &&
        lhs.duration == rhs.duration &&
        lhs.stops == rhs.stops
    }
}
