import Foundation
import ComposableArchitecture

struct AircraftClient {
    var fetchAircraftPositions: () async -> [AircraftPosition]
}

extension AircraftClient: DependencyKey {
    static let liveValue = Self(
        fetchAircraftPositions: {
            await NetworkService.shared.fetchAircraftPositions()
        }
    )
    
    static let testValue = Self(
        fetchAircraftPositions: {
            [
                AircraftPosition(
                    icao24: "abc123",
                    callsign: "PS101",
                    originCountry: "Ukraine",
                    longitude: 30.45,
                    latitude: 50.45,
                    altitude: 2000,
                    velocity: 220.0,
                    heading: 140,
                    aircraftType: "Boeing 737",
                    aircraftImageURL: nil
                ),
                AircraftPosition(
                    icao24: "def456",
                    callsign: "BA238",
                    originCountry: "United Kingdom",
                    longitude: -0.45,
                    latitude: 51.47,
                    altitude: 1500,
                    velocity: 190.0,
                    heading: 280,
                    aircraftType: "Airbus A320",
                    aircraftImageURL: nil
                )
            ]
        }
    )
}

extension DependencyValues {
    var aircraftClient: AircraftClient {
        get { self[AircraftClient.self] }
        set { self[AircraftClient.self] = newValue }
    }
}

// MARK: - Network Service

final class NetworkService {
    static let shared = NetworkService()
    
    private init() {}
    
    func fetchAircraftPositions() async -> [AircraftPosition] {
        let urlString = "https://opensky-network.org/api/states/all"
        guard let url = URL(string: urlString) else { return [] }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                return []
            }
            
            struct OpenSkyEnvelope: Decodable {
                let time: Int?
                let states: [[AnyDecodable]]?
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let envelope = try decoder.decode(OpenSkyEnvelope.self, from: data)
            let rows = envelope.states ?? []
            
            let aircraft: [AircraftPosition] = rows.compactMap { row in
                let icao24 = row[safe: 0]?.string
                let callsign = row[safe: 1]?.string?.trimmingCharacters(in: .whitespaces)
                let origin = row[safe: 2]?.string
                let lon = row[safe: 5]?.double
                let lat = row[safe: 6]?.double
                let baro = row[safe: 7]?.double
                let vel = row[safe: 9]?.double
                let heading = row[safe: 10]?.double
                let aircraftType = Self.getAircraftType(from: icao24)
                
                return AircraftPosition(
                    icao24: icao24,
                    callsign: callsign,
                    originCountry: origin,
                    longitude: lon,
                    latitude: lat,
                    altitude: baro,
                    velocity: vel,
                    heading: heading,
                    aircraftType: aircraftType,
                    aircraftImageURL: nil
                )
            }
            
            return Array(aircraft.prefix(50))
        } catch {
            return []
        }
    }
    
    private static func getAircraftType(from icao24: String?) -> String? {
        guard let icao24 = icao24, icao24.count >= 3 else { return nil }
        
        let prefix = String(icao24.prefix(3))
        
        let aircraftTypes: [String: String] = [
            "4cc": "Boeing 737",
            "4bb": "Boeing 777",
            "4ac": "Airbus A320",
            "4bc": "Airbus A330",
            "39d": "Airbus A380",
            "801": "Boeing 787",
            "407": "Embraer E190",
            "511": "ATR 72",
            "471": "Cessna 172",
            "ae5": "Gulfstream G650"
        ]
        
        return aircraftTypes[prefix]
    }
}

struct AnyDecodable: Decodable {
    let value: Any
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let string = try? container.decode(String.self) {
            value = string
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else {
            throw DecodingError.typeMismatch(AnyDecodable.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unsupported type"))
        }
    }
    
    var string: String? { value as? String }
    var int: Int? { value as? Int }
    var double: Double? { value as? Double }
    var bool: Bool? { value as? Bool }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
