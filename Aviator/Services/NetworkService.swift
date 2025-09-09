import Foundation

struct FlightState: Identifiable, Decodable, Equatable, Hashable {
    let id: UUID = UUID()
    let icao24: String?
    let callsign: String?
    let originCountry: String?
    let timePosition: Int?
    let lastContact: Int?
    let longitude: Double?
    let latitude: Double?
    let baroAltitude: Double?
    let onGround: Bool?
    let velocity: Double?
    let heading: Double?
    let verticalRate: Double?
}

enum NetworkError: Error {
    case invalidURL
    case decoding
    case request
}

final class NetworkService {
    static let shared = NetworkService()

    private init() {}

    func fetchOpenSkyStates() async -> [FlightState] {
        let urlString = "https://opensky-network.org/api/states/all"
        guard let url = URL(string: urlString) else { return Self.mockFlights }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                return Self.mockFlights
            }
            struct OpenSkyEnvelope: Decodable {
                let time: Int?
                let states: [[AnyDecodable]]?
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let envelope = try decoder.decode(OpenSkyEnvelope.self, from: data)
            let rows = envelope.states ?? []
            let mapped: [FlightState] = rows.compactMap { row in
                let icao24 = row[safe: 0]?.string
                let callsign = row[safe: 1]?.string?.trimmingCharacters(in: .whitespaces)
                let origin = row[safe: 2]?.string
                let timePos = row[safe: 3]?.int
                let last = row[safe: 4]?.int
                let lon = row[safe: 5]?.double
                let lat = row[safe: 6]?.double
                let baro = row[safe: 7]?.double
                let onGround = row[safe: 8]?.bool
                let vel = row[safe: 9]?.double
                let heading = row[safe: 10]?.double
                let vRate = row[safe: 11]?.double
                return FlightState(
                    icao24: icao24,
                    callsign: callsign,
                    originCountry: origin,
                    timePosition: timePos,
                    lastContact: last,
                    longitude: lon,
                    latitude: lat,
                    baroAltitude: baro,
                    onGround: onGround,
                    velocity: vel,
                    heading: heading,
                    verticalRate: vRate
                )
            }
            if mapped.isEmpty { return Self.mockFlights }
            return Array(mapped.prefix(50))
        } catch {
            return Self.mockFlights
        }
    }

    private static let mockFlights: [FlightState] = [
        FlightState(icao24: "abc123", callsign: "PS101", originCountry: "Ukraine", timePosition: nil, lastContact: nil, longitude: 30.45, latitude: 50.45, baroAltitude: 2000, onGround: false, velocity: 220.0, heading: 140, verticalRate: -1.2),
        FlightState(icao24: "def456", callsign: "BA238", originCountry: "United Kingdom", timePosition: nil, lastContact: nil, longitude: -0.45, latitude: 51.47, baroAltitude: 1500, onGround: false, velocity: 190.0, heading: 280, verticalRate: 0.4),
        FlightState(icao24: "ghi789", callsign: "DLH4AB", originCountry: "Germany", timePosition: nil, lastContact: nil, longitude: 8.56, latitude: 50.04, baroAltitude: 2300, onGround: false, velocity: 210.0, heading: 90, verticalRate: 0.0)
    ]
}

struct AnyDecodable: Decodable {
    let value: Any
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let str = try? container.decode(String.self) {
            value = str
        } else if let dbl = try? container.decode(Double.self) {
            value = dbl
        } else if let int = try? container.decode(Int.self) {
            value = Double(int)
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if container.decodeNil() {
            value = NSNull()
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported type")
        }
    }

    var string: String? { value as? String }
    var double: Double? {
        if let d = value as? Double { return d }
        if let s = value as? String { return Double(s) }
        return nil
    }
    var bool: Bool? { value as? Bool }
    var int: Int? {
        if let d = value as? Double { return Int(d) }
        if let s = value as? String, let d = Double(s) { return Int(d) }
        return nil
    }
}

extension Array where Element == AnyDecodable {
    subscript(safe index: Int) -> AnyDecodable? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}


