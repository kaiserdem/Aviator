import Foundation

// MARK: - Flight Offer Model

struct FlightOffer: Identifiable, Equatable, Codable {
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

// MARK: - Saved Flight Model

struct SavedFlight: Identifiable, Equatable, Codable {
    let id: UUID = UUID()
    let flightOffer: FlightOffer
    let savedAt: Date
    let notes: String?
    
    init(flightOffer: FlightOffer, notes: String? = nil) {
        self.flightOffer = flightOffer
        self.savedAt = Date()
        self.notes = notes
    }
    
    static func == (lhs: SavedFlight, rhs: SavedFlight) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Database Service Protocol

protocol DatabaseService {
    func saveFlight(_ flight: FlightOffer, notes: String?) async throws
    func getSavedFlights() async throws -> [SavedFlight]
    func deleteSavedFlight(_ flight: SavedFlight) async throws
    func isFlightSaved(_ flight: FlightOffer) async throws -> Bool
}

// MARK: - Persistent Database Implementation

class InMemoryDatabaseService: DatabaseService {
    static let shared = InMemoryDatabaseService()
    private let userDefaults = UserDefaults.standard
    private let savedFlightsKey = "saved_flights"
    
    private init() {}
    
    func saveFlight(_ flight: FlightOffer, notes: String?) async throws {
        var savedFlights = try await getSavedFlights()
        let savedFlight = SavedFlight(flightOffer: flight, notes: notes)
        savedFlights.append(savedFlight)
        try saveToUserDefaults(savedFlights)
        print("💾 Flight saved: \(flight.flightNumber)")
    }
    
    func getSavedFlights() async throws -> [SavedFlight] {
        guard let data = userDefaults.data(forKey: savedFlightsKey) else {
            return []
        }
        
        let decoder = JSONDecoder()
        let savedFlights = try decoder.decode([SavedFlight].self, from: data)
        return savedFlights.sorted { $0.savedAt > $1.savedAt }
    }
    
    func deleteSavedFlight(_ flight: SavedFlight) async throws {
        var savedFlights = try await getSavedFlights()
        savedFlights.removeAll { savedFlight in
            savedFlight.flightOffer.origin == flight.flightOffer.origin &&
            savedFlight.flightOffer.destination == flight.flightOffer.destination &&
            savedFlight.flightOffer.departureDate == flight.flightOffer.departureDate &&
            savedFlight.flightOffer.returnDate == flight.flightOffer.returnDate &&
            savedFlight.flightOffer.airline == flight.flightOffer.airline &&
            savedFlight.flightOffer.flightNumber == flight.flightOffer.flightNumber &&
            savedFlight.flightOffer.price == flight.flightOffer.price
        }
        try saveToUserDefaults(savedFlights)
        print("🗑️ Flight deleted: \(flight.flightOffer.flightNumber)")
    }
    
    func isFlightSaved(_ flight: FlightOffer) async throws -> Bool {
        let savedFlights = try await getSavedFlights()
        return savedFlights.contains { savedFlight in
            savedFlight.flightOffer.origin == flight.origin &&
            savedFlight.flightOffer.destination == flight.destination &&
            savedFlight.flightOffer.departureDate == flight.departureDate &&
            savedFlight.flightOffer.returnDate == flight.returnDate &&
            savedFlight.flightOffer.airline == flight.airline &&
            savedFlight.flightOffer.flightNumber == flight.flightNumber &&
            savedFlight.flightOffer.price == flight.price
        }
    }
    
    private func saveToUserDefaults(_ savedFlights: [SavedFlight]) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(savedFlights)
        userDefaults.set(data, forKey: savedFlightsKey)
    }
}
