import Foundation
import ComposableArchitecture

// MARK: - Models

struct Airport: Identifiable, Equatable {
    let id: UUID = UUID()
    let code: String
    let name: String
    let city: String
    let country: String
    let latitude: Double
    let longitude: Double
    
    static func == (lhs: Airport, rhs: Airport) -> Bool {
        lhs.id == rhs.id &&
        lhs.code == rhs.code &&
        lhs.name == rhs.name &&
        lhs.city == rhs.city &&
        lhs.country == rhs.country &&
        lhs.latitude == rhs.latitude &&
        lhs.longitude == rhs.longitude
    }
}

struct AirportWeather: Identifiable, Equatable {
    let id: UUID = UUID()
    let airportCode: String
    let temperature: Double
    let humidity: Double
    let windSpeed: Double
    let windDirection: Int
    let visibility: Double
    let pressure: Double
    let condition: String
    
    static func == (lhs: AirportWeather, rhs: AirportWeather) -> Bool {
        lhs.id == rhs.id &&
        lhs.airportCode == rhs.airportCode &&
        lhs.temperature == rhs.temperature &&
        lhs.humidity == rhs.humidity &&
        lhs.windSpeed == rhs.windSpeed &&
        lhs.windDirection == rhs.windDirection &&
        lhs.visibility == rhs.visibility &&
        lhs.pressure == rhs.pressure &&
        lhs.condition == rhs.condition
    }
}

struct AmadeusClient {
    var searchFlights: (String, String, Date, Date, Int, Int, Int, String) async -> [FlightOffer]
    var getAirports: () async -> [Airport]
    var getAirportWeather: () async -> [AirportWeather]
    var getSavedSearches: () async -> [SavedSearch]
    var getCurrentUser: () async -> User?
    var login: (String, String) async -> User?
}

extension AmadeusClient: DependencyKey {
    static let liveValue = Self(
        searchFlights: { origin, destination, departureDate, returnDate, adults, children, infants, travelClass in
            await AmadeusService.shared.searchFlights(
                origin: origin,
                destination: destination,
                departureDate: departureDate,
                returnDate: returnDate,
                adults: adults,
                children: children,
                infants: infants,
                travelClass: travelClass
            )
        },
        getAirports: {
            await AmadeusService.shared.getAirports()
        },
        getAirportWeather: {
            await AmadeusService.shared.getAirportWeather()
        },
        getSavedSearches: {
            await AmadeusService.shared.getSavedSearches()
        },
        getCurrentUser: {
            await AmadeusService.shared.getCurrentUser()
        },
        login: { email, password in
            await AmadeusService.shared.login(email: email, password: password)
        }
    )
}

extension DependencyValues {
    var amadeusClient: AmadeusClient {
        get { self[AmadeusClient.self] }
        set { self[AmadeusClient.self] = newValue }
    }
}

// MARK: - Amadeus Service

final class AmadeusService {
    static let shared = AmadeusService()
    
    private let apiKey = "eJgrtNELJeHuwATUSGsGZKbRcJnZ3C1y" // Замініть на ваш API ключ
    private let apiSecret = "jnjmOFAwYBzBfsUa" // Замініть на ваш API секрет
    private let baseURL = "https://test.api.amadeus.com"
    
    private init() {}
    
    func searchFlights(origin: String, destination: String, departureDate: Date, returnDate: Date, adults: Int, children: Int, infants: Int, travelClass: String) async -> [FlightOffer] {
        // TODO: Implement real Amadeus API call
        // For now, return mock data
        return getMockFlightOffers()
    }
    
    func getAirports() async -> [Airport] {
        // TODO: Implement real Amadeus API call
        // For now, return mock data
        return getMockAirports()
    }
    
    func getAirportWeather() async -> [AirportWeather] {
        // TODO: Implement real Amadeus API call
        // For now, return mock data
        return getMockWeatherData()
    }
    
    func getSavedSearches() async -> [SavedSearch] {
        // TODO: Implement real Amadeus API call
        // For now, return mock data
        return getMockSavedSearches()
    }
    
    func getCurrentUser() async -> User? {
        // TODO: Implement real Amadeus API call
        // For now, return mock data
        return getMockUser()
    }
    
    func login(email: String, password: String) async -> User? {
        // TODO: Implement real Amadeus API call
        // For now, return mock data
        return getMockUser()
    }
    
    // MARK: - Mock Data
    
    private func getMockFlightOffers() -> [FlightOffer] {
        return [
            FlightOffer(
                price: "299",
                currency: "USD",
                origin: "NYC",
                destination: "LAX",
                departureDate: "2025-01-15",
                returnDate: "2025-01-22",
                airline: "American Airlines",
                flightNumber: "AA123",
                duration: "5h 30m",
                stops: 0
            ),
            FlightOffer(
                price: "349",
                currency: "USD",
                origin: "NYC",
                destination: "LAX",
                departureDate: "2025-01-15",
                returnDate: "2025-01-22",
                airline: "Delta Air Lines",
                flightNumber: "DL456",
                duration: "6h 15m",
                stops: 1
            ),
            FlightOffer(
                price: "279",
                currency: "USD",
                origin: "NYC",
                destination: "LAX",
                departureDate: "2025-01-15",
                returnDate: "2025-01-22",
                airline: "United Airlines",
                flightNumber: "UA789",
                duration: "5h 45m",
                stops: 0
            )
        ]
    }
    
    private func getMockAirports() -> [Airport] {
        return [
            Airport(code: "JFK", name: "John F. Kennedy International Airport", city: "New York", country: "United States", latitude: 40.6413, longitude: -73.7781),
            Airport(code: "LAX", name: "Los Angeles International Airport", city: "Los Angeles", country: "United States", latitude: 33.9416, longitude: -118.4085),
            Airport(code: "LHR", name: "London Heathrow Airport", city: "London", country: "United Kingdom", latitude: 51.4700, longitude: -0.4543),
            Airport(code: "CDG", name: "Charles de Gaulle Airport", city: "Paris", country: "France", latitude: 49.0097, longitude: 2.5479),
            Airport(code: "NRT", name: "Narita International Airport", city: "Tokyo", country: "Japan", latitude: 35.7720, longitude: 140.3928)
        ]
    }
    
    private func getMockWeatherData() -> [AirportWeather] {
        return [
            AirportWeather(
                airportCode: "JFK",
                temperature: 15.0,
                humidity: 65,
                windSpeed: 12.5,
                windDirection: 270,
                visibility: 10.0,
                pressure: 1013.25,
                condition: "Partly Cloudy"
            ),
            AirportWeather(
                airportCode: "LAX",
                temperature: 22.0,
                humidity: 45,
                windSpeed: 8.2,
                windDirection: 180,
                visibility: 15.0,
                pressure: 1015.30,
                condition: "Clear"
            ),
            AirportWeather(
                airportCode: "LHR",
                temperature: 8.0,
                humidity: 80,
                windSpeed: 15.8,
                windDirection: 240,
                visibility: 8.0,
                pressure: 1008.75,
                condition: "Overcast"
            )
        ]
    }
    
    private func getMockSavedSearches() -> [SavedSearch] {
        return [
            SavedSearch(
                origin: "NYC",
                destination: "LAX",
                departureDate: Date(),
                returnDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
                adults: 2,
                children: 1,
                infants: 0,
                travelClass: "ECONOMY",
                createdAt: Date()
            ),
            SavedSearch(
                origin: "LHR",
                destination: "CDG",
                departureDate: Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date(),
                returnDate: Calendar.current.date(byAdding: .day, value: 37, to: Date()) ?? Date(),
                adults: 1,
                children: 0,
                infants: 0,
                travelClass: "BUSINESS",
                createdAt: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date()
            )
        ]
    }
    
    private func getMockUser() -> User? {
        return User(
            email: "user@example.com",
            firstName: "John",
            lastName: "Doe",
            phoneNumber: "+1 (555) 123-4567",
            preferences: UserPreferences(
                preferredAirline: "American Airlines",
                preferredSeat: "Window",
                preferredMeal: "Vegetarian",
                notificationsEnabled: true
            )
        )
    }
}
