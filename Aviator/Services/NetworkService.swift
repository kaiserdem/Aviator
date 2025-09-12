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
    let aircraftType: String?
    let aircraftImageURL: URL?
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
            // First, create basic flight states without images
            let basicFlights: [FlightState] = rows.compactMap { row in
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
                let aircraftType = Self.getAircraftType(from: icao24)
                
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
                    verticalRate: vRate,
                    aircraftType: aircraftType,
                    aircraftImageURL: nil // Will be loaded separately
                )
            }
            
            // Then, load images for flights that have aircraft types
            let mapped: [FlightState] = await withTaskGroup(of: FlightState.self, returning: [FlightState].self) { group in
                for flight in basicFlights {
                    group.addTask {
                        let imageURL = await Self.getAircraftImageURL(for: flight.aircraftType)
                        return FlightState(
                            icao24: flight.icao24,
                            callsign: flight.callsign,
                            originCountry: flight.originCountry,
                            timePosition: flight.timePosition,
                            lastContact: flight.lastContact,
                            longitude: flight.longitude,
                            latitude: flight.latitude,
                            baroAltitude: flight.baroAltitude,
                            onGround: flight.onGround,
                            velocity: flight.velocity,
                            heading: flight.heading,
                            verticalRate: flight.verticalRate,
                            aircraftType: flight.aircraftType,
                            aircraftImageURL: imageURL
                        )
                    }
                }
                
                var results: [FlightState] = []
                for await result in group {
                    results.append(result)
                }
                return results
            }
            if mapped.isEmpty { return Self.mockFlights }
            return Array(mapped.prefix(50))
        } catch {
            return Self.mockFlights
        }
    }

    private static let mockFlights: [FlightState] = [
        FlightState(icao24: "abc123", callsign: "PS101", originCountry: "Ukraine", timePosition: nil, lastContact: nil, longitude: 30.45, latitude: 50.45, baroAltitude: 2000, onGround: false, velocity: 220.0, heading: 140, verticalRate: -1.2, aircraftType: "Boeing 737", aircraftImageURL: nil),
        FlightState(icao24: "def456", callsign: "BA238", originCountry: "United Kingdom", timePosition: nil, lastContact: nil, longitude: -0.45, latitude: 51.47, baroAltitude: 1500, onGround: false, velocity: 190.0, heading: 280, verticalRate: 0.4, aircraftType: "Airbus A320", aircraftImageURL: nil),
        FlightState(icao24: "ghi789", callsign: "DLH4AB", originCountry: "Germany", timePosition: nil, lastContact: nil, longitude: 8.56, latitude: 50.04, baroAltitude: 2300, onGround: false, velocity: 210.0, heading: 90, verticalRate: 0.0, aircraftType: "Boeing 777", aircraftImageURL: nil)
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

// MARK: - Aircraft Type Detection
extension NetworkService {
    private static func getAircraftType(from icao24: String?) -> String? {
        guard let icao24 = icao24 else { return nil }
        
        //print("🔍 Checking ICAO24: \(icao24)")
        
        // Basic mapping based on common ICAO24 patterns
        // In real app, you'd use a more comprehensive database
        let aircraftTypes: [String: String] = [
            "4ca": "Boeing 737",
            "4cb": "Boeing 737",
            "4cc": "Boeing 737",
            "4cd": "Boeing 737",
            "4ce": "Boeing 737",
            "4cf": "Boeing 737",
            "4cg": "Boeing 737",
            "4ch": "Boeing 737",
            "4ci": "Boeing 737",
            "4cj": "Boeing 737",
            "4ck": "Boeing 737",
            "4cl": "Boeing 737",
            "4cm": "Boeing 737",
            "4cn": "Boeing 737",
            "4co": "Boeing 737",
            "4cp": "Boeing 737",
            "4cq": "Boeing 737",
            "4cr": "Boeing 737",
            "4cs": "Boeing 737",
            "4ct": "Boeing 737",
            "4cu": "Boeing 737",
            "4cv": "Boeing 737",
            "4cw": "Boeing 737",
            "4cx": "Boeing 737",
            "4cy": "Boeing 737",
            "4cz": "Boeing 737",
            "4d0": "Airbus A320",
            "4d1": "Airbus A320",
            "4d2": "Airbus A320",
            "4d3": "Airbus A320",
            "4d4": "Airbus A320",
            "4d5": "Airbus A320",
            "4d6": "Airbus A320",
            "4d7": "Airbus A320",
            "4d8": "Airbus A320",
            "4d9": "Airbus A320",
            "4da": "Airbus A320",
            "4db": "Airbus A320",
            "4dc": "Airbus A320",
            "4dd": "Airbus A320",
            "4de": "Airbus A320",
            "4df": "Airbus A320",
            "4dg": "Airbus A320",
            "4dh": "Airbus A320",
            "4di": "Airbus A320",
            "4dj": "Airbus A320",
            "4dk": "Airbus A320",
            "4dl": "Airbus A320",
            "4dm": "Airbus A320",
            "4dn": "Airbus A320",
            "4do": "Airbus A320",
            "4dp": "Airbus A320",
            "4dq": "Airbus A320",
            "4dr": "Airbus A320",
            "4ds": "Airbus A320",
            "4dt": "Airbus A320",
            "4du": "Airbus A320",
            "4dv": "Airbus A320",
            "4dw": "Airbus A320",
            "4dx": "Airbus A320",
            "4dy": "Airbus A320",
            "4dz": "Airbus A320",
            
            // Boeing 777 family
            "4e0": "Boeing 777", "4e1": "Boeing 777", "4e2": "Boeing 777", "4e3": "Boeing 777",
            "4e4": "Boeing 777", "4e5": "Boeing 777", "4e6": "Boeing 777", "4e7": "Boeing 777",
            "4e8": "Boeing 777", "4e9": "Boeing 777", "4ea": "Boeing 777", "4eb": "Boeing 777",
            "4ec": "Boeing 777", "4ed": "Boeing 777", "4ee": "Boeing 777", "4ef": "Boeing 777",
            "4eg": "Boeing 777", "4eh": "Boeing 777", "4ei": "Boeing 777", "4ej": "Boeing 777",
            "4ek": "Boeing 777", "4el": "Boeing 777", "4em": "Boeing 777", "4en": "Boeing 777",
            "4eo": "Boeing 777", "4ep": "Boeing 777", "4eq": "Boeing 777", "4er": "Boeing 777",
            "4es": "Boeing 777", "4et": "Boeing 777", "4eu": "Boeing 777", "4ev": "Boeing 777",
            "4ew": "Boeing 777", "4ex": "Boeing 777", "4ey": "Boeing 777", "4ez": "Boeing 777",
            
            // Airbus A330 family
            "4f0": "Airbus A330", "4f1": "Airbus A330", "4f2": "Airbus A330", "4f3": "Airbus A330",
            "4f4": "Airbus A330", "4f5": "Airbus A330", "4f6": "Airbus A330", "4f7": "Airbus A330",
            "4f8": "Airbus A330", "4f9": "Airbus A330", "4fa": "Airbus A330", "4fb": "Airbus A330",
            "4fc": "Airbus A330", "4fd": "Airbus A330", "4fe": "Airbus A330", "4ff": "Airbus A330",
            "4fg": "Airbus A330", "4fh": "Airbus A330", "4fi": "Airbus A330", "4fj": "Airbus A330",
            "4fk": "Airbus A330", "4fl": "Airbus A330", "4fm": "Airbus A330", "4fn": "Airbus A330",
            "4fo": "Airbus A330", "4fp": "Airbus A330", "4fq": "Airbus A330", "4fr": "Airbus A330",
            "4fs": "Airbus A330", "4ft": "Airbus A330", "4fu": "Airbus A330", "4fv": "Airbus A330",
            "4fw": "Airbus A330", "4fx": "Airbus A330", "4fy": "Airbus A330", "4fz": "Airbus A330",
            
            // Boeing 787 family
            "500": "Boeing 787", "501": "Boeing 787", "502": "Boeing 787", "503": "Boeing 787",
            "504": "Boeing 787", "505": "Boeing 787", "506": "Boeing 787", "507": "Boeing 787",
            "508": "Boeing 787", "509": "Boeing 787", "50a": "Boeing 787", "50b": "Boeing 787",
            "50c": "Boeing 787", "50d": "Boeing 787", "50e": "Boeing 787", "50f": "Boeing 787",
            "50g": "Boeing 787", "50h": "Boeing 787", "50i": "Boeing 787", "50j": "Boeing 787",
            "50k": "Boeing 787", "50l": "Boeing 787", "50m": "Boeing 787", "50n": "Boeing 787",
            "50o": "Boeing 787", "50p": "Boeing 787", "50q": "Boeing 787", "50r": "Boeing 787",
            "50s": "Boeing 787", "50t": "Boeing 787", "50u": "Boeing 787", "50v": "Boeing 787",
            "50w": "Boeing 787", "50x": "Boeing 787", "50y": "Boeing 787", "50z": "Boeing 787",
            
            // Airbus A350 family
            "510": "Airbus A350", "511": "Airbus A350", "512": "Airbus A350", "513": "Airbus A350",
            "514": "Airbus A350", "515": "Airbus A350", "516": "Airbus A350", "517": "Airbus A350",
            "518": "Airbus A350", "519": "Airbus A350", "51a": "Airbus A350", "51b": "Airbus A350",
            "51c": "Airbus A350", "51d": "Airbus A350", "51e": "Airbus A350", "51f": "Airbus A350",
            "51g": "Airbus A350", "51h": "Airbus A350", "51i": "Airbus A350", "51j": "Airbus A350",
            "51k": "Airbus A350", "51l": "Airbus A350", "51m": "Airbus A350", "51n": "Airbus A350",
            "51o": "Airbus A350", "51p": "Airbus A350", "51q": "Airbus A350", "51r": "Airbus A350",
            "51s": "Airbus A350", "51t": "Airbus A350", "51u": "Airbus A350", "51v": "Airbus A350",
            "51w": "Airbus A350", "51x": "Airbus A350", "51y": "Airbus A350", "51z": "Airbus A350",
            
            // Boeing 747 family
            "520": "Boeing 747", "521": "Boeing 747", "522": "Boeing 747", "523": "Boeing 747",
            "524": "Boeing 747", "525": "Boeing 747", "526": "Boeing 747", "527": "Boeing 747",
            "528": "Boeing 747", "529": "Boeing 747", "52a": "Boeing 747", "52b": "Boeing 747",
            "52c": "Boeing 747", "52d": "Boeing 747", "52e": "Boeing 747", "52f": "Boeing 747",
            "52g": "Boeing 747", "52h": "Boeing 747", "52i": "Boeing 747", "52j": "Boeing 747",
            "52k": "Boeing 747", "52l": "Boeing 747", "52m": "Boeing 747", "52n": "Boeing 747",
            "52o": "Boeing 747", "52p": "Boeing 747", "52q": "Boeing 747", "52r": "Boeing 747",
            "52s": "Boeing 747", "52t": "Boeing 747", "52u": "Boeing 747", "52v": "Boeing 747",
            "52w": "Boeing 747", "52x": "Boeing 747", "52y": "Boeing 747", "52z": "Boeing 747",
            
            // Airbus A380 family
            "530": "Airbus A380", "531": "Airbus A380", "532": "Airbus A380", "533": "Airbus A380",
            "534": "Airbus A380", "535": "Airbus A380", "536": "Airbus A380", "537": "Airbus A380",
            "538": "Airbus A380", "539": "Airbus A380", "53a": "Airbus A380", "53b": "Airbus A380",
            "53c": "Airbus A380", "53d": "Airbus A380", "53e": "Airbus A380", "53f": "Airbus A380",
            "53g": "Airbus A380", "53h": "Airbus A380", "53i": "Airbus A380", "53j": "Airbus A380",
            "53k": "Airbus A380", "53l": "Airbus A380", "53m": "Airbus A380", "53n": "Airbus A380",
            "53o": "Airbus A380", "53p": "Airbus A380", "53q": "Airbus A380", "53r": "Airbus A380",
            "53s": "Airbus A380", "53t": "Airbus A380", "53u": "Airbus A380", "53v": "Airbus A380",
            "53w": "Airbus A380", "53x": "Airbus A380", "53y": "Airbus A380", "53z": "Airbus A380",
            
            // Regional jets and turboprops
            "540": "Embraer E-Jet", "541": "Embraer E-Jet", "542": "Embraer E-Jet", "543": "Embraer E-Jet",
            "544": "Embraer E-Jet", "545": "Embraer E-Jet", "546": "Embraer E-Jet", "547": "Embraer E-Jet",
            "548": "Embraer E-Jet", "549": "Embraer E-Jet", "54a": "Embraer E-Jet", "54b": "Embraer E-Jet",
            "54c": "Embraer E-Jet", "54d": "Embraer E-Jet", "54e": "Embraer E-Jet", "54f": "Embraer E-Jet",
            "54g": "Embraer E-Jet", "54h": "Embraer E-Jet", "54i": "Embraer E-Jet", "54j": "Embraer E-Jet",
            "54k": "Embraer E-Jet", "54l": "Embraer E-Jet", "54m": "Embraer E-Jet", "54n": "Embraer E-Jet",
            "54o": "Embraer E-Jet", "54p": "Embraer E-Jet", "54q": "Embraer E-Jet", "54r": "Embraer E-Jet",
            "54s": "Embraer E-Jet", "54t": "Embraer E-Jet", "54u": "Embraer E-Jet", "54v": "Embraer E-Jet",
            "54w": "Embraer E-Jet", "54x": "Embraer E-Jet", "54y": "Embraer E-Jet", "54z": "Embraer E-Jet",
            
            // Bombardier CRJ family
            "550": "Bombardier CRJ", "551": "Bombardier CRJ", "552": "Bombardier CRJ", "553": "Bombardier CRJ",
            "554": "Bombardier CRJ", "555": "Bombardier CRJ", "556": "Bombardier CRJ", "557": "Bombardier CRJ",
            "558": "Bombardier CRJ", "559": "Bombardier CRJ", "55a": "Bombardier CRJ", "55b": "Bombardier CRJ",
            "55c": "Bombardier CRJ", "55d": "Bombardier CRJ", "55e": "Bombardier CRJ", "55f": "Bombardier CRJ",
            "55g": "Bombardier CRJ", "55h": "Bombardier CRJ", "55i": "Bombardier CRJ", "55j": "Bombardier CRJ",
            "55k": "Bombardier CRJ", "55l": "Bombardier CRJ", "55m": "Bombardier CRJ", "55n": "Bombardier CRJ",
            "55o": "Bombardier CRJ", "55p": "Bombardier CRJ", "55q": "Bombardier CRJ", "55r": "Bombardier CRJ",
            "55s": "Bombardier CRJ", "55t": "Bombardier CRJ", "55u": "Bombardier CRJ", "55v": "Bombardier CRJ",
            "55w": "Bombardier CRJ", "55x": "Bombardier CRJ", "55y": "Bombardier CRJ", "55z": "Bombardier CRJ",
            
            // ATR family
            "560": "ATR 72", "561": "ATR 72", "562": "ATR 72", "563": "ATR 72",
            "564": "ATR 72", "565": "ATR 72", "566": "ATR 72", "567": "ATR 72",
            "568": "ATR 72", "569": "ATR 72", "56a": "ATR 72", "56b": "ATR 72",
            "56c": "ATR 72", "56d": "ATR 72", "56e": "ATR 72", "56f": "ATR 72",
            "56g": "ATR 72", "56h": "ATR 72", "56i": "ATR 72", "56j": "ATR 72",
            "56k": "ATR 72", "56l": "ATR 72", "56m": "ATR 72", "56n": "ATR 72",
            "56o": "ATR 72", "56p": "ATR 72", "56q": "ATR 72", "56r": "ATR 72",
            "56s": "ATR 72", "56t": "ATR 72", "56u": "ATR 72", "56v": "ATR 72",
            "56w": "ATR 72", "56x": "ATR 72", "56y": "ATR 72", "56z": "ATR 72",
            
            // Dash 8 family
            "570": "Bombardier Dash 8", "571": "Bombardier Dash 8", "572": "Bombardier Dash 8", "573": "Bombardier Dash 8",
            "574": "Bombardier Dash 8", "575": "Bombardier Dash 8", "576": "Bombardier Dash 8", "577": "Bombardier Dash 8",
            "578": "Bombardier Dash 8", "579": "Bombardier Dash 8", "57a": "Bombardier Dash 8", "57b": "Bombardier Dash 8",
            "57c": "Bombardier Dash 8", "57d": "Bombardier Dash 8", "57e": "Bombardier Dash 8", "57f": "Bombardier Dash 8",
            "57g": "Bombardier Dash 8", "57h": "Bombardier Dash 8", "57i": "Bombardier Dash 8", "57j": "Bombardier Dash 8",
            "57k": "Bombardier Dash 8", "57l": "Bombardier Dash 8", "57m": "Bombardier Dash 8", "57n": "Bombardier Dash 8",
            "57o": "Bombardier Dash 8", "57p": "Bombardier Dash 8", "57q": "Bombardier Dash 8", "57r": "Bombardier Dash 8",
            "57s": "Bombardier Dash 8", "57t": "Bombardier Dash 8", "57u": "Bombardier Dash 8", "57v": "Bombardier Dash 8",
            "57w": "Bombardier Dash 8", "57x": "Bombardier Dash 8", "57y": "Bombardier Dash 8", "57z": "Bombardier Dash 8",
            
            // Cessna Citation family
            "580": "Cessna Citation", "581": "Cessna Citation", "582": "Cessna Citation", "583": "Cessna Citation",
            "584": "Cessna Citation", "585": "Cessna Citation", "586": "Cessna Citation", "587": "Cessna Citation",
            "588": "Cessna Citation", "589": "Cessna Citation", "58a": "Cessna Citation", "58b": "Cessna Citation",
            "58c": "Cessna Citation", "58d": "Cessna Citation", "58e": "Cessna Citation", "58f": "Cessna Citation",
            "58g": "Cessna Citation", "58h": "Cessna Citation", "58i": "Cessna Citation", "58j": "Cessna Citation",
            "58k": "Cessna Citation", "58l": "Cessna Citation", "58m": "Cessna Citation", "58n": "Cessna Citation",
            "58o": "Cessna Citation", "58p": "Cessna Citation", "58q": "Cessna Citation", "58r": "Cessna Citation",
            "58s": "Cessna Citation", "58t": "Cessna Citation", "58u": "Cessna Citation", "58v": "Cessna Citation",
            "58w": "Cessna Citation", "58x": "Cessna Citation", "58y": "Cessna Citation", "58z": "Cessna Citation",
            
            // Gulfstream family
            "590": "Gulfstream G650", "591": "Gulfstream G650", "592": "Gulfstream G650", "593": "Gulfstream G650",
            "594": "Gulfstream G650", "595": "Gulfstream G650", "596": "Gulfstream G650", "597": "Gulfstream G650",
            "598": "Gulfstream G650", "599": "Gulfstream G650", "59a": "Gulfstream G650", "59b": "Gulfstream G650",
            "59c": "Gulfstream G650", "59d": "Gulfstream G650", "59e": "Gulfstream G650", "59f": "Gulfstream G650",
            "59g": "Gulfstream G650", "59h": "Gulfstream G650", "59i": "Gulfstream G650", "59j": "Gulfstream G650",
            "59k": "Gulfstream G650", "59l": "Gulfstream G650", "59m": "Gulfstream G650", "59n": "Gulfstream G650",
            "59o": "Gulfstream G650", "59p": "Gulfstream G650", "59q": "Gulfstream G650", "59r": "Gulfstream G650",
            "59s": "Gulfstream G650", "59t": "Gulfstream G650", "59u": "Gulfstream G650", "59v": "Gulfstream G650",
            "59w": "Gulfstream G650", "59x": "Gulfstream G650", "59y": "Gulfstream G650", "59z": "Gulfstream G650"
        ]
        
        let prefix = String(icao24.prefix(3))
        let result = aircraftTypes[prefix]
        print("📋 ICAO24: \(icao24) -> Prefix: \(prefix) -> Type: \(result ?? "nil")")
        return result
    }
    
    private static func getAircraftImageURL(for aircraftType: String?) async -> URL? {
        guard let aircraftType = aircraftType else { 
            print("❌ No aircraft type provided")
            return nil 
        }
        
        print("🛩️ Fetching image for: \(aircraftType)")
        let encoded = aircraftType.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? aircraftType
        let url = URL(string: "https://en.wikipedia.org/api/rest_v1/page/summary/\(encoded)")!
        print("🌐 URL: \(url)")
        
        struct Summary: Decodable {
            struct Thumb: Decodable { let source: String? }
            let thumbnail: Thumb?
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { 
                print("❌ HTTP Error: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                return nil 
            }
            
            let summary = try JSONDecoder().decode(Summary.self, from: data)
            let imageURL = URL(string: summary.thumbnail?.source ?? "")
            print("✅ Image URL: \(imageURL?.absoluteString ?? "nil")")
            return imageURL
        } catch {
            print("❌ Error fetching image: \(error)")
            return nil
        }
    }
}


