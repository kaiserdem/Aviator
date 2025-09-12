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

// MARK: - In-Memory Database Implementation

class InMemoryDatabaseService: DatabaseService {
    private var savedFlights: [SavedFlight] = []
    
    func saveFlight(_ flight: FlightOffer, notes: String?) async throws {
        let savedFlight = SavedFlight(flightOffer: flight, notes: notes)
        savedFlights.append(savedFlight)
        print("💾 Flight saved: \(flight.flightNumber)")
    }
    
    func getSavedFlights() async throws -> [SavedFlight] {
        return savedFlights.sorted { $0.savedAt > $1.savedAt }
    }
    
    func deleteSavedFlight(_ flight: SavedFlight) async throws {
        savedFlights.removeAll { $0.id == flight.id }
        print("🗑️ Flight deleted: \(flight.flightOffer.flightNumber)")
    }
    
    func isFlightSaved(_ flight: FlightOffer) async throws -> Bool {
        return savedFlights.contains { $0.flightOffer.id == flight.id }
    }
}
