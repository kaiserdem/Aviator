import ComposableArchitecture
import Foundation

struct ResultsFeature: Reducer {
    struct State: Equatable {
        var isLoading = false
        var flightOffers: [FlightOffer] = []
        var selectedOffer: FlightOffer?
        var sortOption: SortOption = .price
        var filterOption: FilterOption = .all
        
        init() {
            self.isLoading = false
            self.flightOffers = []
            self.selectedOffer = nil
            self.sortOption = .price
            self.filterOption = .all
        }
    }

    enum Action: Equatable {
        case onAppear
        case sortChanged(SortOption)
        case filterChanged(FilterOption)
        case resetFilters
        case selectOffer(FlightOffer?)
        case searchWithParameters(AppFeature.SearchParameters)
        case _flightOffersResponse([FlightOffer])
    }

    enum SortOption: String, CaseIterable, Equatable {
        case price = "Price"
        case duration = "Duration"
        case departure = "Departure"
        
        var displayName: String {
            return self.rawValue
        }
    }

    enum FilterOption: String, CaseIterable, Equatable {
        case all = "All"
        case direct = "Direct Only"
        case oneStop = "1 Stop"
        case twoStops = "2+ Stops"
        
        var displayName: String {
            return self.rawValue
        }
    }

    @Dependency(\.amadeusClient) var amadeusClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                // Не робимо автоматичний пошук при появі
                return .none
                
            case let .searchWithParameters(parameters):
                state.isLoading = true
                print("🔍 ResultsFeature: Starting search with parameters")
                print("   Origin: \(parameters.origin)")
                print("   Destination: \(parameters.destination)")
                print("   Adults: \(parameters.adults)")
                print("   Children: \(parameters.children)")
                print("   Infants: \(parameters.infants)")
                print("   Travel Class: \(parameters.travelClass)")
                
                return .run { send in
                    let offers = await amadeusClient.searchFlights(
                        parameters.origin,
                        parameters.destination,
                        parameters.departureDate,
                        parameters.returnDate,
                        parameters.adults,
                        parameters.children,
                        parameters.infants,
                        parameters.travelClass
                    )
                    await send(._flightOffersResponse(offers))
                }
                
            case let .sortChanged(option):
                state.sortOption = option
                return .none
                
            case let .filterChanged(option):
                state.filterOption = option
                return .none
                
            case .resetFilters:
                state.sortOption = .price
                state.filterOption = .all
                print("🔄 ResultsFeature: Filters reset")
                return .none
                
            case let .selectOffer(offer):
                state.selectedOffer = offer
                return .none
                
            case let ._flightOffersResponse(offers):
                state.isLoading = false
                state.flightOffers = offers
                return .none
            }
        }
    }
}