import Foundation
import ComposableArchitecture

struct AircraftDetail: Identifiable, Equatable, Hashable {
    let id = UUID()
    let title: String
    let extract: String
    let imageURL: URL?
    let technicalSpecs: TechnicalSpecs?
    let history: History?
    let gallery: [URL]
    let links: Links?
}

struct TechnicalSpecs: Equatable, Hashable {
    let cruiseSpeed: String?
    let range: String?
    let passengerCapacity: String?
    let wingspan: String?
    let length: String?
}

struct History: Equatable, Hashable {
    let firstFlight: String?
    let manufacturer: String?
    let unitsBuilt: String?
}

struct Links: Equatable, Hashable {
    let wikipedia: URL?
    let manufacturer: URL?
}

struct AircraftClient {
    var listTitles: @Sendable () async -> [String]
    var fetchDetail: @Sendable (_ title: String) async -> AircraftDetail
}

extension DependencyValues {
    var aircraftClient: AircraftClient {
        get { self[AircraftClientKey.self] }
        set { self[AircraftClientKey.self] = newValue }
    }
}

enum AircraftClientKey: DependencyKey {
    static let liveValue: AircraftClient = .init(
        listTitles: {
            Self.hardcodedTitles
        },
        fetchDetail: { title in
            let encoded = title.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? title
            let url = URL(string: "https://en.wikipedia.org/api/rest_v1/page/summary/\(encoded)")!
            struct Summary: Decodable {
                struct Thumb: Decodable { let source: String? }
                let title: String
                let extract: String?
                let thumbnail: Thumb?
                let content_urls: ContentUrls?
            }
            struct ContentUrls: Decodable {
                struct Desktop: Decodable { let page: String? }
                let desktop: Desktop?
            }
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                    return AircraftDetail(
                        title: title, 
                        extract: "No summary available.", 
                        imageURL: nil,
                        technicalSpecs: nil,
                        history: nil,
                        gallery: [],
                        links: nil
                    )
                }
                let s = try JSONDecoder().decode(Summary.self, from: data)
                
                // Parse technical specs from extract (basic parsing)
                let specs = Self.parseTechnicalSpecs(from: s.extract ?? "")
                let history = Self.parseHistory(from: s.extract ?? "")
                let wikiURL = URL(string: s.content_urls?.desktop?.page ?? "")
                
                return AircraftDetail(
                    title: s.title,
                    extract: s.extract ?? "No summary available.",
                    imageURL: URL(string: s.thumbnail?.source ?? ""),
                    technicalSpecs: specs,
                    history: history,
                    gallery: [URL(string: s.thumbnail?.source ?? "")].compactMap { $0 },
                    links: Links(wikipedia: wikiURL, manufacturer: nil)
                )
            } catch {
                return AircraftDetail(
                    title: title, 
                    extract: "No summary available.", 
                    imageURL: nil,
                    technicalSpecs: nil,
                    history: nil,
                    gallery: [],
                    links: nil
                )
            }
        }
    )

    static let testValue: AircraftClient = .init(
        listTitles: { Self.hardcodedTitles },
        fetchDetail: { AircraftDetail(title: $0, extract: "Test aircraft.", imageURL: nil, technicalSpecs: nil, history: nil, gallery: [], links: nil) }
    )
    
    private static func parseTechnicalSpecs(from text: String) -> TechnicalSpecs? {
        // Basic regex parsing for common specs
        let cruiseSpeed = extractValue(from: text, pattern: #"cruise speed[:\s]*([0-9,]+)\s*km/h"#)
        let range = extractValue(from: text, pattern: #"range[:\s]*([0-9,]+)\s*km"#)
        let capacity = extractValue(from: text, pattern: #"capacity[:\s]*([0-9,]+)\s*passengers?"#)
        let wingspan = extractValue(from: text, pattern: #"wingspan[:\s]*([0-9.]+)\s*m"#)
        let length = extractValue(from: text, pattern: #"length[:\s]*([0-9.]+)\s*m"#)
        
        return TechnicalSpecs(
            cruiseSpeed: cruiseSpeed,
            range: range,
            passengerCapacity: capacity,
            wingspan: wingspan,
            length: length
        )
    }
    
    private static func parseHistory(from text: String) -> History? {
        let firstFlight = extractValue(from: text, pattern: #"first flight[:\s]*([0-9]{4})"#)
        let manufacturer = extractValue(from: text, pattern: #"manufactured by[:\s]*([A-Za-z\s]+)"#)
        let unitsBuilt = extractValue(from: text, pattern: #"([0-9,]+)\s*built"#)
        
        return History(
            firstFlight: firstFlight,
            manufacturer: manufacturer,
            unitsBuilt: unitsBuilt
        )
    }
    
    private static func extractValue(from text: String, pattern: String) -> String? {
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(location: 0, length: text.utf16.count)
        if let match = regex?.firstMatch(in: text, options: [], range: range),
           let range = Range(match.range(at: 1), in: text) {
            return String(text[range]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return nil
    }

    private static let hardcodedTitles: [String] = [
        "Airbus A320",
        "Airbus A321",
        "Airbus A330",
        "Airbus A350",
        "Airbus A380",
        "Boeing 737",
        "Boeing 747",
        "Boeing 757",
        "Boeing 767",
        "Boeing 777",
        "Boeing 787",
        "Embraer E190",
        "Embraer E175",
        "ATR 72",
        "Bombardier CRJ700",
        "Airbus A220",
        "Airbus A319",
        "Airbus A340",
        "Boeing 717",
        "Boeing 727",
        "Boeing 737 MAX",
        "Boeing 747-8",
        "Boeing 757-300",
        "Boeing 767-400",
        "Boeing 777X",
        "Boeing 787 Dreamliner",
        "Embraer E170",
        "Embraer E195",
        "ATR 42",
        "Bombardier CRJ200",
        "Bombardier CRJ900",
        "Bombardier CRJ1000",
        "Cessna Citation",
        "Gulfstream G650",
        "Dassault Falcon",
        "Pilatus PC-12",
        "Beechcraft King Air",
        "Piaggio P180",
        "Antonov An-124",
        "Antonov An-225",
        "Ilyushin Il-76",
        "Tupolev Tu-154",
        "Tupolev Tu-204",
        "Sukhoi Superjet 100",
        "Irkut MC-21",
        "Comac C919",
        "Mitsubishi SpaceJet"
    ]
}


