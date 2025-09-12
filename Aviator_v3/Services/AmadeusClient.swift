import Foundation
import ComposableArchitecture

// MARK: - Models

// MARK: - Amadeus API Response Models

struct TokenResponse: Codable {
    let access_token: String
    let token_type: String
    let expires_in: Int
}

struct AmadeusFlightResponse: Codable {
    let data: [FlightOfferData]
    let meta: Meta
}

struct FlightOfferData: Codable {
    let type: String
    let id: String
    let source: String
    let instantTicketingRequired: Bool
    let nonHomogeneous: Bool
    let oneWay: Bool
    let lastTicketingDate: String
    let numberOfBookableSeats: Int
    let itineraries: [Itinerary]
    let price: Price
    let pricingOptions: PricingOptions?
    let validatingAirlineCodes: [String]
    let travelerPricings: [TravelerPricing]
}

struct Itinerary: Codable {
    let duration: String
    let segments: [Segment]
}

struct Segment: Codable {
    let departure: Departure
    let arrival: Arrival
    let carrierCode: String
    let number: String
    let aircraft: Aircraft
    let operating: Operating
    let duration: String
    let id: String
    let numberOfStops: Int
    let blacklistedInEU: Bool
}

struct Departure: Codable {
    let iataCode: String
    let at: String
    let terminal: String?
}

struct Arrival: Codable {
    let iataCode: String
    let at: String
    let terminal: String?
}

struct Aircraft: Codable {
    let code: String
}

struct Operating: Codable {
    let carrierCode: String
}

struct Price: Codable {
    let currency: String
    let total: String
    let base: String
    let fees: [Fee]?
    let grandTotal: String?
    let additionalServices: [AdditionalService]?
}

struct AdditionalService: Codable {
    let amount: String?
    let type: String?
}

struct Fee: Codable {
    let amount: String
    let type: String
}

struct PricingOptions: Codable {
    let fareType: [String]
    let includedCheckedBagsOnly: Bool
}

struct TravelerPricing: Codable {
    let travelerId: String
    let fareOption: String
    let travelerType: String
    let price: Price
    let fareDetailsBySegment: [FareDetailsBySegment]
}

struct FareDetailsBySegment: Codable {
    let segmentId: String
    let cabin: String
    let fareBasis: String
    let `class`: String
    let includedCheckedBags: IncludedCheckedBags?
    let includedCabinBags: IncludedCabinBags?
    let amenities: [Amenity]?
}

struct IncludedCabinBags: Codable {
    let quantity: Int?
}

struct Amenity: Codable {
    let description: String?
    let isChargeable: Bool?
    let amenityType: String?
    let amenityProvider: AmenityProvider?
}

struct AmenityProvider: Codable {
    let name: String?
}

struct IncludedCheckedBags: Codable {
    let quantity: Int?
    let weight: Int?
    let weightUnit: String?
}

struct Meta: Codable {
    let count: Int
    let links: Links
}

struct Links: Codable {
    let `self`: String
}

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
    
    // MARK: - Airport Code Normalization
    
    private func normalizeAirportCode(_ input: String) -> String {
        let code = input.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Common airport code mappings
        let mappings: [String: String] = [
            "WARSHAWA": "WAW",    // Warsaw
            "WARSAW": "WAW",
            "SIFIA": "SOF",       // Sofia
            "SOFIA": "SOF",
            "PARIS": "PAR",
            "LONDON": "LON",
            "NEW YORK": "NYC",
            "LOS ANGELES": "LAX",
            "MADRID": "MAD",
            "ROME": "FCO",
            "BERLIN": "BER",
            "MUNICH": "MUC",
            "FRANKFURT": "FRA",
            "AMSTERDAM": "AMS",
            "VIENNA": "VIE",
            "PRAGUE": "PRG",
            "BUDAPEST": "BUD",
            "STOCKHOLM": "ARN",
            "COPENHAGEN": "CPH",
            "OSLO": "OSL",
            "HELSINKI": "HEL",
            "MOSCOW": "SVO",
            "ISTANBUL": "IST",
            "DUBAI": "DXB",
            "TOKYO": "NRT",
            "SEOUL": "ICN",
            "BEIJING": "PEK",
            "SHANGHAI": "PVG",
            "SYDNEY": "SYD",
            "MELBOURNE": "MEL",
            "TORONTO": "YYZ",
            "VANCOUVER": "YVR",
            "MEXICO CITY": "MEX",
            "SAO PAULO": "GRU",
            "BUENOS AIRES": "EZE",
            "JOHANNESBURG": "JNB",
            "CAIRO": "CAI",
            "MUMBAI": "BOM",
            "DELHI": "DEL",
            "BANGKOK": "BKK",
            "SINGAPORE": "SIN",
            "HONG KONG": "HKG",
            "TAIPEI": "TPE"
        ]
        
        // If it's already a 3-letter code, return as is
        if code.count == 3 && code.allSatisfy({ $0.isLetter }) {
            return code
        }
        
        // Try to find mapping
        if let mapped = mappings[code] {
            return mapped
        }
        
        // If no mapping found, try to extract 3-letter code from input
        let letters = code.filter { $0.isLetter }
        if letters.count >= 3 {
            return String(letters.prefix(3))
        }
        
        // Fallback to original input (will likely cause API error, but better than crashing)
        print("⚠️ Could not normalize airport code: \(input)")
        return code
    }
    
    // MARK: - Real API Implementation
    
    private func performFlightSearch(origin: String, destination: String, departureDate: Date, returnDate: Date, adults: Int, children: Int, infants: Int, travelClass: String) async -> [FlightOffer] {
        do {
            // Validate and normalize airport codes
            let normalizedOrigin = normalizeAirportCode(origin)
            let normalizedDestination = normalizeAirportCode(destination)
            
            print("🌐 Normalized codes: \(normalizedOrigin) -> \(normalizedDestination)")
            
            // Get access token first
            let accessToken = try await getAccessToken()
            
            // Format dates
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let departureDateString = formatter.string(from: departureDate)
            let returnDateString = formatter.string(from: returnDate)
            
            // Build URL
            var components = URLComponents(string: "\(baseURL)/v2/shopping/flight-offers")!
            components.queryItems = [
                URLQueryItem(name: "originLocationCode", value: normalizedOrigin),
                URLQueryItem(name: "destinationLocationCode", value: normalizedDestination),
                URLQueryItem(name: "departureDate", value: departureDateString),
                URLQueryItem(name: "returnDate", value: returnDateString),
                URLQueryItem(name: "adults", value: String(adults)),
                URLQueryItem(name: "children", value: String(children)),
                URLQueryItem(name: "infants", value: String(infants)),
                URLQueryItem(name: "travelClass", value: travelClass),
                URLQueryItem(name: "max", value: "10")
            ]
            
            guard let url = components.url else {
                print("❌ Invalid URL")
                return getMockFlightOffers() // Fallback to mock data
            }
            
            // Create request
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            // Perform request
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response")
                return getMockFlightOffers() // Fallback to mock data
            }
            
            print("🌐 Amadeus API Response Status: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 200 {
                do {
                    let flightResponse = try JSONDecoder().decode(AmadeusFlightResponse.self, from: data)
                    return parseFlightOffers(from: flightResponse)
                } catch {
                    print("❌ JSON parsing error: \(error)")
                    print("❌ Raw response: \(String(data: data, encoding: .utf8) ?? "Unable to decode")")
                    return getMockFlightOffers() // Fallback to mock data
                }
            } else {
                print("❌ API Error: \(httpResponse.statusCode)")
                if let errorData = String(data: data, encoding: .utf8) {
                    print("❌ Error details: \(errorData)")
                }
                return getMockFlightOffers() // Fallback to mock data
            }
            
        } catch {
            print("❌ Network error: \(error)")
            return getMockFlightOffers() // Fallback to mock data
        }
    }
    
    private func getAccessToken() async throws -> String {
        let url = URL(string: "\(baseURL)/v1/security/oauth2/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let body = "grant_type=client_credentials&client_id=\(apiKey)&client_secret=\(apiSecret)"
        request.httpBody = body.data(using: .utf8)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NSError(domain: "TokenError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Failed to get access token"])
        }
        
        let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
        return tokenResponse.access_token
    }
    
    private func parseFlightOffers(from response: AmadeusFlightResponse) -> [FlightOffer] {
        var offers: [FlightOffer] = []
        
        print("📊 Parsing \(response.data.count) flight offers...")
        
        for (index, data) in response.data.enumerated() {
            do {
                let price = data.price.total
                let currency = data.price.currency
                
                // Parse first itinerary
                if let itinerary = data.itineraries.first {
                    let segments = itinerary.segments
                    
                    // Get airline info from first segment
                    guard let firstSegment = segments.first else {
                        print("⚠️ No segments found in itinerary \(index)")
                        continue
                    }
                    
                    let airline = firstSegment.carrierCode
                    let flightNumber = "\(airline)\(firstSegment.number)"
                    
                    // Calculate duration
                    let duration = itinerary.duration
                    
                    // Count stops
                    let stops = max(0, segments.count - 1)
                    
                    // Format dates
                    let departureDate = firstSegment.departure.at
                    let returnDate = segments.last?.arrival.at ?? departureDate
                    
                    let offer = FlightOffer(
                        price: price,
                        currency: currency,
                        origin: firstSegment.departure.iataCode,
                        destination: segments.last?.arrival.iataCode ?? firstSegment.departure.iataCode,
                        departureDate: departureDate,
                        returnDate: returnDate,
                        airline: airline,
                        flightNumber: flightNumber,
                        duration: duration,
                        stops: stops
                    )
                    
                    offers.append(offer)
                    print("✅ Parsed offer \(index + 1): \(airline) \(flightNumber) - \(price) \(currency)")
                } else {
                    print("⚠️ No itineraries found in offer \(index)")
                }
            } catch {
                print("❌ Error parsing offer \(index): \(error)")
            }
        }
        
        print("📊 Successfully parsed \(offers.count) offers")
        return offers
    }
    
    func searchFlights(origin: String, destination: String, departureDate: Date, returnDate: Date, adults: Int, children: Int, infants: Int, travelClass: String) async -> [FlightOffer] {
        // Real Amadeus API call
        return await performFlightSearch(origin: origin, destination: destination, departureDate: departureDate, returnDate: returnDate, adults: adults, children: children, infants: infants, travelClass: travelClass)
        
        // Mock data (commented out)
        // return getMockFlightOffers()
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
    
    // MARK: - Mock Data (Commented out for flight search)
    
    /*
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
    */
    
    // Fallback mock data for when API fails
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
