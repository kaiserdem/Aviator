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
        var searchParameters: AppFeature.SearchParameters?
        var searchResultsCount: Int? = nil
        
        init() {
            self.isLoading = false
            self.origin = ""
            self.destination = ""
            self.departureDate = Date()
            self.returnDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
            self.adults = 1
            self.children = 0
            self.infants = 0
            self.travelClass = "ECONOMY"
            self.flightOffers = []
            self.selectedOffer = nil
            self.searchParameters = nil
            self.searchResultsCount = nil
        }
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
        case searchCompleted(Int) // Кількість знайдених рейсів
        case clearResults // Очистити результати пошуку
        case clearSearchFields // Очистити поля пошуку
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
                print("🔍 SearchFeature: Starting search with:")
                print("   Origin: \(state.origin)")
                print("   Destination: \(state.destination)")
                print("   Adults: \(state.adults)")
                print("   Children: \(state.children)")
                print("   Infants: \(state.infants)")
                print("   Travel Class: \(state.travelClass)")
                
                // Створюємо параметри пошуку та зберігаємо в state
                let parameters = AppFeature.SearchParameters(
                    origin: state.origin,
                    destination: state.destination,
                    departureDate: state.departureDate,
                    returnDate: state.returnDate,
                    adults: state.adults,
                    children: state.children,
                    infants: state.infants,
                    travelClass: state.travelClass
                )
                
                // Зберігаємо параметри пошуку в state
                state.searchParameters = parameters
                print("✅ SearchFeature: Parameters saved to state")
                return .none
                
            case let .searchCompleted(count):
                state.isLoading = false
                state.searchResultsCount = count
                print("✅ SearchFeature: Search completed with \(count) results")
                return .none
                
            case .clearResults:
                state.searchResultsCount = nil
                state.searchParameters = nil
                print("🧹 SearchFeature: Results cleared")
                return .none
                
            case .clearSearchFields:
                state.origin = ""
                state.destination = ""
                state.searchResultsCount = nil
                state.searchParameters = nil
                print("🧹 SearchFeature: Search fields cleared")
                return .none
                
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

