import Foundation

// MARK: - Flight Offer Model

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
