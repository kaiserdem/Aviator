import ComposableArchitecture
import Foundation

struct HotelsFeature: Reducer {
    struct State: Equatable {
        var isLoading = false
        var hotels: [Hotel] = []
        var searchText = ""
        var selectedCity = "PAR"
        var errorMessage: String?
        
        init() {}
    }
    
    enum Action: Equatable {
        case onAppear
        case searchTextChanged(String)
        case cityChanged(String)
        case searchHotels
        case hotelsResponse([Hotel])
        case searchError(String)
    }
    
    @Dependency(\.hotelsClient) var hotelsClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    let hotels = await hotelsClient.searchHotels("PAR")
                    await send(.hotelsResponse(hotels))
                }
                
            case let .searchTextChanged(text):
                state.searchText = text
                return .none
                
            case let .cityChanged(city):
                state.selectedCity = city
                return .none
                
            case .searchHotels:
                state.isLoading = true
                state.errorMessage = nil
                return .run { [city = state.selectedCity] send in
                    let hotels = await hotelsClient.searchHotels(city)
                    await send(.hotelsResponse(hotels))
                }
                
            case let .hotelsResponse(hotels):
                state.isLoading = false
                state.hotels = hotels
                return .none
                
            case let .searchError(error):
                state.isLoading = false
                state.errorMessage = error
                return .none
            }
        }
    }
}

// MARK: - Models

struct Hotel: Equatable, Identifiable {
    let id = UUID()
    let name: String
    let address: String
    let rating: Double
    let price: Double
    let currency: String
    let amenities: [String]
    let imageURL: String?
    let latitude: Double?
    let longitude: Double?
    
    init(name: String, address: String, rating: Double, price: Double, currency: String = "USD", amenities: [String] = [], imageURL: String? = nil, latitude: Double? = nil, longitude: Double? = nil) {
        self.name = name
        self.address = address
        self.rating = rating
        self.price = price
        self.currency = currency
        self.amenities = amenities
        self.imageURL = imageURL
        self.latitude = latitude
        self.longitude = longitude
    }
    
    static func == (lhs: Hotel, rhs: Hotel) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.address == rhs.address &&
               lhs.rating == rhs.rating &&
               lhs.price == rhs.price &&
               lhs.currency == rhs.currency &&
               lhs.amenities == rhs.amenities &&
               lhs.imageURL == rhs.imageURL &&
               lhs.latitude == rhs.latitude &&
               lhs.longitude == rhs.longitude
    }
}
