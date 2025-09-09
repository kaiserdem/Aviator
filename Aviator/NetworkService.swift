import Foundation

struct FlightState: Identifiable, Decodable {
    let id: UUID = UUID()
    let callsign: String?
    let originCountry: String?
    let longitude: Double?
    let latitude: Double?
    let velocity: Double?

    enum CodingKeys: String, CodingKey {
        case callsign, originCountry = "origin_country", longitude, latitude, velocity
    }
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
            // OpenSky повертає масив у полі "states" як вкладені масиви
            // [time, [ [icao24, callsign, origin_country, time_position, last_contact, longitude, latitude, baro_altitude, on_ground, velocity, heading, vertical_rate, ... ] ]]
            struct OpenSkyEnvelope: Decodable {
                let time: Int?
                let states: [[AnyDecodable]]?
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let envelope = try decoder.decode(OpenSkyEnvelope.self, from: data)
            let rows = envelope.states ?? []
            let mapped: [FlightState] = rows.compactMap { row in
                // Індекси за специфікацією OpenSky
                // 1: callsign, 2: origin_country, 5: longitude, 6: latitude, 9: velocity
                let callsign = row[safe: 1]?.string
                let origin = row[safe: 2]?.string
                let lon = row[safe: 5]?.double
                let lat = row[safe: 6]?.double
                let vel = row[safe: 9]?.double
                return FlightState(callsign: callsign?.trimmingCharacters(in: .whitespaces), originCountry: origin, longitude: lon, latitude: lat, velocity: vel)
            }
            if mapped.isEmpty { return Self.mockFlights }
            return Array(mapped.prefix(50))
        } catch {
            return Self.mockFlights
        }
    }

    private static let mockFlights: [FlightState] = [
        FlightState(callsign: "PS101", originCountry: "Ukraine", longitude: 30.45, latitude: 50.45, velocity: 220.0),
        FlightState(callsign: "BA238", originCountry: "United Kingdom", longitude: -0.45, latitude: 51.47, velocity: 190.0),
        FlightState(callsign: "DLH4AB", originCountry: "Germany", longitude: 8.56, latitude: 50.04, velocity: 210.0)
    ]
}

// Допоміжні типи для розпарсування динамічного масиву OpenSky
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
}

extension Array where Element == AnyDecodable {
    subscript(safe index: Int) -> AnyDecodable? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}


