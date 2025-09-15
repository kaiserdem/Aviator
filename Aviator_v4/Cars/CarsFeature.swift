import ComposableArchitecture
import Foundation

struct CarsFeature: Reducer {
    struct State: Equatable {
        var isLoading = false
        var cars: [Car] = []
        var pickupDate = Date()
        var dropoffDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        var selectedLocation = "LAX"
        var errorMessage: String?
        
        init() {}
    }
    
    enum Action: Equatable {
        case onAppear
        case pickupDateChanged(Date)
        case dropoffDateChanged(Date)
        case locationChanged(String)
        case searchCars
        case carsResponse([Car])
        case searchError(String)
    }
    
    @Dependency(\.carsClient) var carsClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { [pickupDate = state.pickupDate, dropoffDate = state.dropoffDate, location = state.selectedLocation] send in
                    let cars = await carsClient.searchCars(location, pickupDate, dropoffDate)
                    await send(.carsResponse(cars))
                }
                
            case let .pickupDateChanged(date):
                state.pickupDate = date
                return .none
                
            case let .dropoffDateChanged(date):
                state.dropoffDate = date
                return .none
                
            case let .locationChanged(location):
                state.selectedLocation = location
                return .none
                
            case .searchCars:
                state.isLoading = true
                state.errorMessage = nil
                return .run { [pickupDate = state.pickupDate, dropoffDate = state.dropoffDate, location = state.selectedLocation] send in
                    let cars = await carsClient.searchCars(location, pickupDate, dropoffDate)
                    await send(.carsResponse(cars))
                }
                
            case let .carsResponse(cars):
                state.isLoading = false
                state.cars = cars
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

struct Car: Equatable, Identifiable {
    let id = UUID()
    let make: String
    let model: String
    let category: String
    let pricePerDay: Double
    let currency: String
    let transmission: String
    let fuelType: String
    let seats: Int
    let imageURL: String?
    let company: String
    
    init(make: String, model: String, category: String, pricePerDay: Double, currency: String = "USD", transmission: String, fuelType: String, seats: Int, imageURL: String? = nil, company: String) {
        self.make = make
        self.model = model
        self.category = category
        self.pricePerDay = pricePerDay
        self.currency = currency
        self.transmission = transmission
        self.fuelType = fuelType
        self.seats = seats
        self.imageURL = imageURL
        self.company = company
    }
    
    static func == (lhs: Car, rhs: Car) -> Bool {
        return lhs.id == rhs.id &&
               lhs.make == rhs.make &&
               lhs.model == rhs.model &&
               lhs.category == rhs.category &&
               lhs.pricePerDay == rhs.pricePerDay &&
               lhs.currency == rhs.currency &&
               lhs.transmission == rhs.transmission &&
               lhs.fuelType == rhs.fuelType &&
               lhs.seats == rhs.seats &&
               lhs.imageURL == rhs.imageURL &&
               lhs.company == rhs.company
    }
}
