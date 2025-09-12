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
        // print("🌐 NetworkService: Fetching from URL: \(urlString)")
        guard let url = URL(string: urlString) else { 
            print("❌ NetworkService: Invalid URL")
            return [] 
        }
        
        do {
            // print("🌐 NetworkService: Making API request...")
            let (data, response) = try await URLSession.shared.data(from: url)
            // print("🌐 NetworkService: Response status: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
            // print("🌐 NetworkService: Data size: \(data.count) bytes")
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                print("❌ NetworkService: Bad response status")
                return []
            }
            
            struct OpenSkyEnvelope: Decodable {
                let time: Int
                let states: [[State]]?
            }
            
            enum State: Codable {
                case bool(Bool)
                case double(Double)
                case string(String)
                case null

                init(from decoder: Decoder) throws {
                    let container = try decoder.singleValueContainer()
                    if let x = try? container.decode(Bool.self) {
                        self = .bool(x)
                        return
                    }
                    if let x = try? container.decode(Double.self) {
                        self = .double(x)
                        return
                    }
                    if let x = try? container.decode(String.self) {
                        self = .string(x)
                        return
                    }
                    if container.decodeNil() {
                        self = .null
                        return
                    }
                    throw DecodingError.typeMismatch(State.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for State"))
                }

                func encode(to encoder: Encoder) throws {
                    var container = encoder.singleValueContainer()
                    switch self {
                    case .bool(let x):
                        try container.encode(x)
                    case .double(let x):
                        try container.encode(x)
                    case .string(let x):
                        try container.encode(x)
                    case .null:
                        try container.encodeNil()
                    }
                }
                
                var stringValue: String? {
                    switch self {
                    case .string(let value): return value
                    default: return nil
                    }
                }
                
                var doubleValue: Double? {
                    switch self {
                    case .double(let value): return value
                    default: return nil
                    }
                }
                
                var boolValue: Bool? {
                    switch self {
                    case .bool(let value): return value
                    default: return nil
                    }
                }
                
                var intValue: Int? {
                    switch self {
                    case .double(let value): return Int(value)
                    default: return nil
                    }
                }
                
                var arrayValue: [State]? {
                    // This won't be used in our case, but keeping for completeness
                    return nil
                }
            }
            
            // Log raw JSON response
            if let jsonString = String(data: data, encoding: .utf8) {
                // print("🌐 NetworkService: Raw JSON response (first 500 chars):")
                // print(String(jsonString.prefix(500)))
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                let envelope = try decoder.decode(OpenSkyEnvelope.self, from: data)
                // print("🌐 NetworkService: Successfully decoded JSON envelope")
            } catch {
                print("❌ NetworkService: JSON decoding error: \(error)")
                print("❌ NetworkService: Error details: \(error.localizedDescription)")
                throw error
            }
            
            let envelope = try decoder.decode(OpenSkyEnvelope.self, from: data)
            let rows = envelope.states ?? []
            // print("🌐 NetworkService: Received \(rows.count) aircraft states from API")
            
            let aircraft: [AircraftPosition] = rows.compactMap { row in
                let icao24 = row[safe: 0]?.stringValue
                let callsign = row[safe: 1]?.stringValue?.trimmingCharacters(in: .whitespaces)
                let origin = row[safe: 2]?.stringValue
                let lon = row[safe: 5]?.doubleValue
                let lat = row[safe: 6]?.doubleValue
                let baro = row[safe: 7]?.doubleValue
                let vel = row[safe: 9]?.doubleValue
                let heading = row[safe: 10]?.doubleValue
                let aircraftType = Self.getAircraftType(from: icao24)
                
                // Log parsed aircraft data
                if let icao = icao24, let call = callsign, let lon = lon, let lat = lat {
                    // print("🛩️ Parsed aircraft: \(icao) - \(call) at \(lat), \(lon)")
                }
                
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
            
            let result = Array(aircraft.prefix(50))
            // print("🌐 NetworkService: Returning \(result.count) aircraft")
            return result
        } catch {
            print("❌ NetworkService: Error fetching aircraft: \(error.localizedDescription)")
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
