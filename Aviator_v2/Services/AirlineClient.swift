import Foundation
import ComposableArchitecture

struct AirlineClient {
    var fetchAirlines: () async -> [Airline]
}

extension AirlineClient: DependencyKey {
    static let liveValue = Self(
        fetchAirlines: {
            await AirlineService.shared.fetchAirlines()
        }
    )
    
}

extension DependencyValues {
    var airlineClient: AirlineClient {
        get { self[AirlineClient.self] }
        set { self[AirlineClient.self] = newValue }
    }
}

// MARK: - Airline Service

final class AirlineService {
    static let shared = AirlineService()
    
    private init() {}
    
    func fetchAirlines() async -> [Airline] {
        print("✈️ AirlineService: Starting to fetch airlines from OpenSky API...")
        
        // Use existing AircraftClient to avoid duplicate API calls
        let aircraftData = await AircraftClient.liveValue.fetchAircraftPositions()
        print("✈️ AirlineService: Received \(aircraftData.count) aircraft from AircraftClient")
        
        // Group aircraft by callsign and create airline data
        let airlines = createAirlinesFromAircraftData(aircraftData)
        print("✈️ AirlineService: Created \(airlines.count) airlines from aircraft data")
        
        // If no airlines were created from API data, return empty array
        if airlines.isEmpty {
            print("✈️ AirlineService: No airlines created from API data")
        }
        
        return airlines
    }
    
    
    private func createAirlinesFromAircraftData(_ aircraft: [AircraftPosition]) -> [Airline] {
        // Group aircraft by callsign
        let groupedAircraft = Dictionary(grouping: aircraft) { aircraft in
            aircraft.callsign ?? "UNKNOWN"
        }
        
        print("✈️ Total unique callsigns found: \(groupedAircraft.count)")
        print("✈️ Callsigns: \(Array(groupedAircraft.keys).sorted().prefix(10))")
        
        // Create airlines from grouped data
        let airlines = groupedAircraft.compactMap { (callsign, aircraftList) -> Airline? in
            guard !callsign.isEmpty && callsign != "UNKNOWN" else { 
                return nil 
            }
            
            // Show all callsigns - no filtering
            
            let activeFlights = aircraftList.count
            let airlineInfo = getAirlineInfo(for: callsign, aircraftList: aircraftList)
            
            print("✅ Created airline: \(airlineInfo.name) (\(callsign)) - \(activeFlights) flights - \(airlineInfo.region)")
            
            return Airline(
                name: airlineInfo.name,
                country: airlineInfo.country,
                region: airlineInfo.region,
                callsign: callsign,
                activeFlights: activeFlights,
                logoURL: airlineInfo.logoURL,
                website: airlineInfo.website,
                countryCode: airlineInfo.countryCode,
                countryFlag: airlineInfo.countryFlag,
                foundedYear: airlineInfo.foundedYear,
                fleetSize: airlineInfo.fleetSize,
                headquarters: airlineInfo.headquarters
            )
        }
        
        // Sort by active flights (descending)
        return airlines.sorted { $0.activeFlights > $1.activeFlights }
    }
    
    
    private func getAirlineInfo(for callsign: String, aircraftList: [AircraftPosition]) -> (name: String, country: String, region: Region, logoURL: URL?, website: URL?, countryCode: String, countryFlag: String, foundedYear: Int?, fleetSize: Int?, headquarters: String?) {
        // Known airline callsigns mapping with extended data
        let airlineMappings: [String: (name: String, country: String, region: Region, logoURL: String?, website: String?, countryCode: String, countryFlag: String, foundedYear: Int?, fleetSize: Int?, headquarters: String?)] = [
            "DLH": ("Lufthansa", "Germany", .europe, "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8e/Lufthansa_logo_2018.svg/200px-Lufthansa_logo_2018.svg.png", "https://www.lufthansa.com", "DE", "🇩🇪", 1953, 280, "Frankfurt"),
            "BAW": ("British Airways", "United Kingdom", .europe, "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/British_Airways_logo.svg/200px-British_Airways_logo.svg.png", "https://www.britishairways.com", "GB", "🇬🇧", 1974, 280, "London"),
            "AFR": ("Air France", "France", .europe, "https://upload.wikimedia.org/wikipedia/commons/thumb/4/44/Air_France_logo.svg/200px-Air_France_logo.svg.png", "https://www.airfrance.com", "FR", "🇫🇷", 1933, 220, "Paris"),
            "JAL": ("Japan Airlines", "Japan", .asia, "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1d/Japan_Airlines_logo.svg/200px-Japan_Airlines_logo.svg.png", "https://www.jal.com", "JP", "🇯🇵", 1951, 150, "Tokyo"),
            "UAL": ("United Airlines", "United States", .america, "https://upload.wikimedia.org/wikipedia/commons/thumb/6/63/United_Airlines_logo_2010.svg/200px-United_Airlines_logo_2010.svg.png", "https://www.united.com", "US", "🇺🇸", 1926, 800, "Chicago"),
            "UAE": ("Emirates", "United Arab Emirates", .asia, "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d0/Emirates_logo.svg/200px-Emirates_logo.svg.png", "https://www.emirates.com", "AE", "🇦🇪", 1985, 260, "Dubai"),
            "SIA": ("Singapore Airlines", "Singapore", .asia, "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4b/Singapore_Airlines_logo.svg/200px-Singapore_Airlines_logo.svg.png", "https://www.singaporeair.com", "SG", "🇸🇬", 1972, 150, "Singapore"),
            "QFA": ("Qantas", "Australia", .oceania, "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4b/Qantas_logo_2016.svg/200px-Qantas_logo_2016.svg.png", "https://www.qantas.com", "AU", "🇦🇺", 1920, 130, "Sydney"),
            "SAA": ("South African Airways", "South Africa", .africa, "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8e/South_African_Airways_logo.svg/200px-South_African_Airways_logo.svg.png", "https://www.flysaa.com", "ZA", "🇿🇦", 1934, 50, "Johannesburg"),
            "ACA": ("Air Canada", "Canada", .america, "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1d/Air_Canada_logo.svg/200px-Air_Canada_logo.svg.png", "https://www.aircanada.com", "CA", "🇨🇦", 1937, 180, "Montreal"),
            "PS": ("Ukraine International Airlines", "Ukraine", .europe, nil, "https://www.flyuia.com", "UA", "🇺🇦", 1992, 25, "Kyiv"),
            "WZZ": ("Wizz Air", "Hungary", .europe, nil, "https://wizzair.com", "HU", "🇭🇺", 2003, 180, "Budapest"),
            "RYR": ("Ryanair", "Ireland", .europe, nil, "https://www.ryanair.com", "IE", "🇮🇪", 1984, 470, "Dublin"),
            "EZY": ("easyJet", "United Kingdom", .europe, nil, "https://www.easyjet.com", "GB", "🇬🇧", 1995, 330, "London"),
            "SWR": ("Swiss International Air Lines", "Switzerland", .europe, nil, "https://www.swiss.com", "CH", "🇨🇭", 2002, 90, "Zurich"),
            "KLM": ("KLM Royal Dutch Airlines", "Netherlands", .europe, nil, "https://www.klm.com", "NL", "🇳🇱", 1919, 110, "Amsterdam"),
            "IBE": ("Iberia", "Spain", .europe, nil, "https://www.iberia.com", "ES", "🇪🇸", 1927, 80, "Madrid"),
            "AZA": ("Alitalia", "Italy", .europe, nil, "https://www.alitalia.com", "IT", "🇮🇹", 1946, 50, "Rome"),
            "AFL": ("Aeroflot", "Russia", .europe, nil, "https://www.aeroflot.com", "RU", "🇷🇺", 1923, 180, "Moscow"),
            "THY": ("Turkish Airlines", "Turkey", .europe, nil, "https://www.turkishairlines.com", "TR", "🇹🇷", 1933, 350, "Istanbul")
        ]
        
        if let mapping = airlineMappings[callsign] {
            return (
                name: mapping.name,
                country: mapping.country,
                region: mapping.region,
                logoURL: mapping.logoURL.flatMap(URL.init),
                website: mapping.website.flatMap(URL.init),
                countryCode: mapping.countryCode,
                countryFlag: mapping.countryFlag,
                foundedYear: mapping.foundedYear,
                fleetSize: mapping.fleetSize,
                headquarters: mapping.headquarters
            )
        } else {
            // For unknown callsigns, determine region from aircraft coordinates
            let region = determineRegionFromAircraft(aircraftList)
            let (countryCode, countryFlag) = getCountryInfoFromRegion(region)
            return (
                name: "\(callsign) Airlines",
                country: "Unknown",
                region: region,
                logoURL: nil,
                website: nil,
                countryCode: countryCode,
                countryFlag: countryFlag,
                foundedYear: nil,
                fleetSize: nil,
                headquarters: nil
            )
        }
    }
    
    private func determineRegionFromAircraft(_ aircraft: [AircraftPosition]) -> Region {
        // Get average coordinates from aircraft
        let validCoordinates = aircraft.compactMap { aircraft -> (lat: Double, lon: Double)? in
            guard let lat = aircraft.latitude, let lon = aircraft.longitude else { return nil }
            return (lat: lat, lon: lon)
        }
        
        guard !validCoordinates.isEmpty else { return .all }
        
        let avgLat = validCoordinates.map { $0.lat }.reduce(0, +) / Double(validCoordinates.count)
        let avgLon = validCoordinates.map { $0.lon }.reduce(0, +) / Double(validCoordinates.count)
        
        print("🌍 Determining region for callsign: avg coordinates \(avgLat), \(avgLon)")
        
        // Determine region based on coordinates
        if avgLat >= 35 && avgLat <= 70 && avgLon >= -25 && avgLon <= 40 {
            return .europe
        } else if avgLat >= 10 && avgLat <= 60 && avgLon >= 70 && avgLon <= 180 {
            return .asia
        } else if avgLat >= 10 && avgLat <= 70 && avgLon >= -180 && avgLon <= -50 {
            return .america
        } else if avgLat >= -35 && avgLat <= 35 && avgLon >= -20 && avgLon <= 55 {
            return .africa
        } else if avgLat >= -50 && avgLat <= -10 && avgLon >= 110 && avgLon <= 180 {
            return .oceania
        } else {
            return .all
        }
    }
    
    private func getCountryInfoFromRegion(_ region: Region) -> (countryCode: String, countryFlag: String) {
        switch region {
        case .europe:
            return ("EU", "🇪🇺")
        case .asia:
            return ("AS", "🌏")
        case .america:
            return ("AM", "🌎")
        case .africa:
            return ("AF", "🌍")
        case .oceania:
            return ("OC", "🌏")
        case .all:
            return ("XX", "🌍")
        }
    }
    
}
