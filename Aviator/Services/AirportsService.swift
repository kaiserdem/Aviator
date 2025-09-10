import Foundation
import ComposableArchitecture

struct Airport: Identifiable, Equatable, Hashable {
    let id: String // use ident combining icao/iata or internal id
    let name: String
    let city: String
    let country: String
    let iata: String?
    let icao: String?
    let latitude: Double?
    let longitude: Double?
    // Enriched fields from OurAirports
    let type: String?
    let elevationFt: Int?
    let continent: String?
    let region: String? // iso_region
    let localCode: String?
    let scheduledService: String?
    let homeLink: URL?
    let wikipediaLink: URL?
    let keywords: String?
}

struct AirportsClient {
    var fetchAirports: @Sendable () async -> [Airport]
}

extension DependencyValues {
    var airportsClient: AirportsClient {
        get { self[AirportsClientKey.self] }
        set { self[AirportsClientKey.self] = newValue }
    }
}

enum AirportsClientKey: DependencyKey {
    static let liveValue: AirportsClient = .init(fetchAirports: {
        if let cached = try? AirportsCache.loadFromDisk(), cached.isEmpty == false { return cached }
        guard let url = URL(string: "https://ourairports.com/data/airports.csv") else { return [] }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { return [] }
            let text = String(decoding: data, as: UTF8.self)
            let rows = CSVParser.parse(csvString: text)
            // Header reference: id,ident,type,name,latitude_deg,longitude_deg,elevation_ft,continent,iso_country,iso_region,municipality,scheduled_service,gps_code,iata_code,local_code,home_link,wikipedia_link,keywords
            let airports: [Airport] = rows.compactMap { row in
                guard row.count >= 15 else { return nil }
                let ident = row[safe: 1]
                let name = row[safe: 3] ?? "Unknown"
                let lat = Double(row[safe: 4] ?? "")
                let lon = Double(row[safe: 5] ?? "")
                let country = row[safe: 8] ?? ""
                let city = row[safe: 10] ?? ""
                let type = row[safe: 2]
                let elevationFt = Int(row[safe: 6] ?? "")
                let continent = row[safe: 7]
                let region = row[safe: 9]
                let gps = row[safe: 12]
                let iata = row[safe: 13]
                let icao = gps?.isEmpty == false ? gps : nil
                let localCode = row[safe: 14]
                let homeLinkStr = row[safe: 15]
                let wikipediaLinkStr = row[safe: 16]
                let keywords = row[safe: 17]
                let scheduledService = row[safe: 11]
                let homeLink = (homeLinkStr?.isEmpty == false) ? URL(string: homeLinkStr!) : nil
                let wikipediaLink = (wikipediaLinkStr?.isEmpty == false) ? URL(string: wikipediaLinkStr!) : nil
                let id = (icao?.isEmpty == false ? icao! : (iata ?? ident ?? UUID().uuidString))
                // Keep only airports/large/medium/small types
                let allowed = ["small_airport","medium_airport","large_airport","heliport"]
                guard let typeNonEmpty = type, allowed.contains(typeNonEmpty) else { return nil }
                return Airport(
                    id: id,
                    name: name,
                    city: city,
                    country: country,
                    iata: iata?.isEmpty == true ? nil : iata,
                    icao: icao,
                    latitude: lat,
                    longitude: lon,
                    type: type,
                    elevationFt: elevationFt,
                    continent: continent,
                    region: region,
                    localCode: localCode,
                    scheduledService: scheduledService,
                    homeLink: homeLink,
                    wikipediaLink: wikipediaLink,
                    keywords: keywords
                )
            }
            try? AirportsCache.saveToDisk(airports)
            return airports
        } catch { return [] }
    })

    static let testValue: AirportsClient = .init(fetchAirports: { [] })
}

private enum AirportsCache {
    static func cacheURL() throws -> URL {
        let fm = FileManager.default
        let dir = try fm.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return dir.appendingPathComponent("airports_cache.json")
    }
    static func saveToDisk(_ airports: [Airport]) throws {
        let dto = airports.map { CachedAirport(from: $0) }
        let data = try JSONEncoder().encode(dto)
        try data.write(to: try cacheURL(), options: .atomic)
    }
    static func loadFromDisk() throws -> [Airport] {
        let data = try Data(contentsOf: try cacheURL())
        let dto = try JSONDecoder().decode([CachedAirport].self, from: data)
        return dto.map { $0.toModel() }
    }
    private struct CachedAirport: Codable {
        let id: String
        let name: String
        let city: String
        let country: String
        let iata: String?
        let icao: String?
        let latitude: Double?
        let longitude: Double?
        let type: String?
        let elevationFt: Int?
        let continent: String?
        let region: String?
        let localCode: String?
        let scheduledService: String?
        let homeLink: URL?
        let wikipediaLink: URL?
        let keywords: String?

        init(from a: Airport) {
            id = a.id; name = a.name; city = a.city; country = a.country
            iata = a.iata; icao = a.icao; latitude = a.latitude; longitude = a.longitude
            type = a.type; elevationFt = a.elevationFt; continent = a.continent; region = a.region
            localCode = a.localCode; scheduledService = a.scheduledService
            homeLink = a.homeLink; wikipediaLink = a.wikipediaLink; keywords = a.keywords
        }
        func toModel() -> Airport {
            Airport(
                id: id,
                name: name,
                city: city,
                country: country,
                iata: iata,
                icao: icao,
                latitude: latitude,
                longitude: longitude,
                type: type,
                elevationFt: elevationFt,
                continent: continent,
                region: region,
                localCode: localCode,
                scheduledService: scheduledService,
                homeLink: homeLink,
                wikipediaLink: wikipediaLink,
                keywords: keywords
            )
        }
    }
}

private enum CSVParser {
    static func parse(csvString: String) -> [[String]] {
        var rows: [[String]] = []
        var current: [String] = []
        var value = ""
        var insideQuotes = false
        var isHeader = true
        for char in csvString {
            if char == "\n" || char == "\r" { // end of line
                if insideQuotes { value.append(char); continue }
                current.append(value)
                value.removeAll(keepingCapacity: true)
                if isHeader { isHeader = false; current.removeAll(); continue }
                rows.append(current)
                current.removeAll(keepingCapacity: true)
            } else if char == "\"" {
                insideQuotes.toggle()
            } else if char == "," && !insideQuotes {
                current.append(value)
                value.removeAll(keepingCapacity: true)
            } else {
                value.append(char)
            }
        }
        if !value.isEmpty || !current.isEmpty { current.append(value); if !current.isEmpty { rows.append(current) } }
        return rows
    }
}

private extension Array where Element == String {
    subscript(safe index: Int) -> String? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}


