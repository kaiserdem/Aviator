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
    let carrierCode: String?
    let carrierName: String?
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
    var getCurrentUser: () async -> AppUser?
    var login: (String, String) async -> AppUser?
    var register: (String, String, String, String) async -> AppUser?
    var logout: () async -> Void
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
        getCurrentUser: {
            await AmadeusService.shared.getCurrentUser()
        },
        login: { email, password in
            await AmadeusService.shared.login(email: email, password: password)
        },
        register: { email, password, firstName, lastName in
            await AmadeusService.shared.register(email: email, password: password, firstName: firstName, lastName: lastName)
        },
        logout: {
            await AmadeusService.shared.logout()
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
                return [] // Return empty array instead of mock data
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
                return [] // Return empty array instead of mock data
            }
            
            print("🌐 Amadeus API Response Status: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 200 {
                do {
                    let flightResponse = try JSONDecoder().decode(AmadeusFlightResponse.self, from: data)
                    return parseFlightOffers(from: flightResponse)
                } catch {
                    print("❌ JSON parsing error: \(error)")
                    print("❌ Raw response: \(String(data: data, encoding: .utf8) ?? "Unable to decode")")
                    return [] // Return empty array instead of mock data
                }
            } else {
                print("❌ API Error: \(httpResponse.statusCode)")
                if let errorData = String(data: data, encoding: .utf8) {
                    print("❌ Error details: \(errorData)")
                }
                return [] // Return empty array instead of mock data
            }
            
        } catch {
            print("❌ Network error: \(error)")
            return [] // Return empty array instead of mock data
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
        do {
            // Get access token first
            let accessToken = try await getAccessToken()
            
            // Build URL for airports
            let url = URL(string: "\(baseURL)/v1/reference-data/locations")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            // Add query parameters
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            components.queryItems = [
                URLQueryItem(name: "subType", value: "AIRPORT"),
                URLQueryItem(name: "page[limit]", value: "100")
            ]
            request.url = components.url
            
            print("🌐 Making airports request to: \(request.url?.absoluteString ?? "unknown")")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response type")
                return []
            }
            
            print("📊 Airports response status: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 200 {
                let airportsResponse = try JSONDecoder().decode(AirportsResponse.self, from: data)
                print("✅ Successfully decoded \(airportsResponse.data.count) airports")
                return airportsResponse.data.map { airportData in
                    Airport(
                        code: airportData.iataCode,
                        name: airportData.name,
                        city: airportData.address?.cityName ?? "Unknown",
                        country: airportData.address?.countryName ?? "Unknown",
                        latitude: airportData.geoCode?.latitude ?? 0.0,
                        longitude: airportData.geoCode?.longitude ?? 0.0
                    )
                }
            } else {
                print("❌ Airports API error: \(httpResponse.statusCode)")
                let errorData = String(data: data, encoding: .utf8) ?? "Unknown error"
                print("❌ Error details: \(errorData)")
                return []
            }
            
        } catch {
            print("❌ Airports error: \(error)")
            return []
        }
    }
    
    func getAirportWeather() async -> [AirportWeather] {
        // Airport Weather API is not available in Amadeus
        return []
    }
    
    func getCurrentUser() async -> AppUser? {
        return LocalUserStorage.shared.getCurrentUser()
    }
    
    func login(email: String, password: String) async -> AppUser? {
        print("🔐 Local login attempt for: \(email)")
        
        // Try to login locally first
        if let existingUser = LocalUserStorage.shared.loginUser(email: email, password: password) {
            print("✅ User logged in successfully: \(email)")
            // Send notification to update ProfileView
            NotificationCenter.default.post(name: .userDidLogin, object: nil)
            return existingUser
        }
        
        // For demo purposes, create test user if credentials match
        if email == "test@example.com" && password == "password" {
            print("✅ Creating demo user for testing")
            let demoUser = LocalUserStorage.shared.registerUser(
                email: email,
                password: password,
                firstName: "Demo",
                lastName: "User"
            )
            // Set as current user
            if let user = demoUser {
                LocalUserStorage.shared.setCurrentUser(user)
                print("✅ Demo user created and logged in: \(email)")
                // Send notification to update ProfileView
                NotificationCenter.default.post(name: .userDidLogin, object: nil)
                return user
            }
        }
        
        print("❌ Login failed for: \(email)")
        return nil
    }
    
    func register(email: String, password: String, firstName: String, lastName: String) async -> AppUser? {
        print("📝 Local registration attempt for: \(email)")
        
        // Register locally
        let newUser = LocalUserStorage.shared.registerUser(
            email: email,
            password: password,
            firstName: firstName.isEmpty ? "User" : firstName,
            lastName: lastName.isEmpty ? "User" : lastName
        )
        
        if let user = newUser {
            // Set as current user
            LocalUserStorage.shared.setCurrentUser(user)
            print("✅ User registered and logged in: \(email)")
            // Send notification to update ProfileView
            NotificationCenter.default.post(name: .userDidLogin, object: nil)
            return user
        } else {
            print("❌ Registration failed for: \(email)")
            return nil
        }
    }
    
    func logout() async {
        LocalUserStorage.shared.logoutUser()
        print("✅ User logged out successfully")
    }
    
}

// MARK: - Airport API Models

struct AirportsResponse: Codable {
    let data: [AirportData]
}

struct AirportData: Codable {
    let type: String
    let subType: String
    let name: String
    let iataCode: String
    let address: AirportAddress?
    let geoCode: AirportGeoCode?
}

struct AirportAddress: Codable {
    let cityName: String?
    let countryName: String?
}

struct AirportGeoCode: Codable {
    let latitude: Double
    let longitude: Double
}


// MARK: - Local User Models

struct AppUser: Identifiable, Codable, Equatable {
    let id: UUID = UUID()
    let email: String
    let firstName: String
    let lastName: String
    let phoneNumber: String?
    let preferences: UserPreferences?
    
    static func == (lhs: AppUser, rhs: AppUser) -> Bool {
        lhs.id == rhs.id &&
        lhs.email == rhs.email &&
        lhs.firstName == lhs.firstName &&
        lhs.lastName == rhs.lastName
    }
}

struct UserPreferences: Codable, Equatable {
    let preferredAirline: String?
    let preferredSeat: String?
    let preferredMeal: String?
    let notificationsEnabled: Bool
}

// MARK: - Local User Storage

class LocalUserStorage {
    static let shared = LocalUserStorage()
    private let userDefaults = UserDefaults.standard
    private let usersKey = "stored_users"
    private let currentUserKey = "current_user"
    
    private init() {}
    
    // MARK: - User Management
    
    func registerUser(email: String, password: String, firstName: String, lastName: String) -> AppUser? {
        // Check if user already exists
        if getUserByEmail(email) != nil {
            print("❌ User with email \(email) already exists")
            return nil
        }
        
        // Create new user
        let user = AppUser(
            email: email,
            firstName: firstName,
            lastName: lastName,
            phoneNumber: nil,
            preferences: UserPreferences(
                preferredAirline: nil,
                preferredSeat: nil,
                preferredMeal: nil,
                notificationsEnabled: true
            )
        )
        
        // Store user
        var users = getAllUsers()
        users.append(user)
        saveUsers(users)
        
        print("✅ User registered successfully: \(email)")
        return user
    }
    
    func loginUser(email: String, password: String) -> AppUser? {
        guard let user = getUserByEmail(email) else {
            print("❌ User not found: \(email)")
            return nil
        }
        
        // Set as current user
        setCurrentUser(user)
        print("✅ User logged in successfully: \(email)")
        return user
    }
    
    func logoutUser() {
        userDefaults.removeObject(forKey: currentUserKey)
        print("✅ User logged out")
    }
    
    func getCurrentUser() -> AppUser? {
        guard let data = userDefaults.data(forKey: currentUserKey),
              let user = try? JSONDecoder().decode(AppUser.self, from: data) else {
            return nil
        }
        return user
    }
    
    func setCurrentUser(_ user: AppUser) {
        if let data = try? JSONEncoder().encode(user) {
            userDefaults.set(data, forKey: currentUserKey)
        }
    }
    
    // MARK: - Private Methods
    
    private func getAllUsers() -> [AppUser] {
        guard let data = userDefaults.data(forKey: usersKey),
              let users = try? JSONDecoder().decode([AppUser].self, from: data) else {
            return []
        }
        return users
    }
    
    private func saveUsers(_ users: [AppUser]) {
        if let data = try? JSONEncoder().encode(users) {
            userDefaults.set(data, forKey: usersKey)
        }
    }
    
    private func getUserByEmail(_ email: String) -> AppUser? {
        return getAllUsers().first { $0.email == email }
    }
    
}


