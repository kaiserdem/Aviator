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
        print("✈️ AirlineService: Starting to fetch airlines from Wikipedia...")
        
        // Fetch airlines from Wikipedia
        let wikipediaAirlines = await WikipediaClient.liveValue.searchAirlines()
        print("✈️ AirlineService: Received \(wikipediaAirlines.count) airlines from Wikipedia")
        
        // Get aircraft data for active flights count
        let aircraftData = await AircraftClient.liveValue.fetchAircraftPositions()
        print("✈️ AirlineService: Received \(aircraftData.count) aircraft from AircraftClient")
        
        // Create airlines from Wikipedia data and aircraft data
        let airlines = createAirlinesFromWikipediaData(wikipediaAirlines, aircraftData: aircraftData)
        print("✈️ AirlineService: Created \(airlines.count) airlines from Wikipedia data")
        
        return airlines
    }
    
    private func createAirlinesFromWikipediaData(_ wikipediaAirlines: [WikipediaAirline], aircraftData: [AircraftPosition]) -> [Airline] {
        // Group aircraft by airline for active flights count
        let groupedAircraft = Dictionary(grouping: aircraftData) { aircraft in
            getAirlineFromCallsign(aircraft.callsign ?? "UNKNOWN")
        }
        
        print("✈️ Grouped aircraft into \(groupedAircraft.count) airlines")
        
        // Create airlines from Wikipedia data
        let airlines = wikipediaAirlines.compactMap { wikipediaAirline -> Airline? in
            let airlineName = wikipediaAirline.title
            let aircraftList = groupedAircraft[airlineName] ?? []
            let activeFlights = aircraftList.count
            
            print("🔍 Processing Wikipedia airline: '\(airlineName)' with \(activeFlights) active flights")
            
            let airlineInfo = getAirlineInfoByName(airlineName, aircraftList: aircraftList)
            
            print("✅ Created airline from Wikipedia: \(airlineInfo.name) - \(activeFlights) flights - \(airlineInfo.region)")
            
            return Airline(
                name: airlineInfo.name,
                country: airlineInfo.country,
                region: airlineInfo.region,
                callsign: airlineInfo.callsign,
                activeFlights: activeFlights,
                logoURL: airlineInfo.logoURL ?? wikipediaAirline.thumbnail.flatMap(URL.init),
                website: airlineInfo.website ?? wikipediaAirline.url.flatMap(URL.init),
                countryCode: airlineInfo.countryCode,
                countryFlag: airlineInfo.countryFlag,
                foundedYear: airlineInfo.foundedYear,
                fleetSize: airlineInfo.fleetSize,
                headquarters: airlineInfo.headquarters
            )
        }
        
        // Sort by active flights (descending), then by name
        return airlines.sorted { first, second in
            if first.activeFlights != second.activeFlights {
                return first.activeFlights > second.activeFlights
            }
            return first.name < second.name
        }
    }
    
    private func createAirlinesFromAircraftData(_ aircraft: [AircraftPosition]) -> [Airline] {
        // Group aircraft by airline (not individual callsigns)
        let groupedAircraft = Dictionary(grouping: aircraft) { aircraft in
            getAirlineFromCallsign(aircraft.callsign ?? "UNKNOWN")
        }
        
        print("✈️ Total unique airlines found: \(groupedAircraft.count)")
        print("✈️ Airlines: \(Array(groupedAircraft.keys).sorted().prefix(10))")
        
        // Create airlines from grouped data
        let airlines = groupedAircraft.compactMap { (airlineName, aircraftList) -> Airline? in
            print("🔍 Processing airline: '\(airlineName)' with \(aircraftList.count) aircraft")
            guard airlineName != "UNKNOWN" else { 
                print("❌ Skipping UNKNOWN airline")
                return nil 
            }
            
            let activeFlights = aircraftList.count
            let airlineInfo = getAirlineInfoByName(airlineName, aircraftList: aircraftList)
            
            print("✅ Created airline: \(airlineInfo.name) - \(activeFlights) flights - \(airlineInfo.region)")
            
            return Airline(
                name: airlineInfo.name,
                country: airlineInfo.country,
                region: airlineInfo.region,
                callsign: airlineInfo.callsign,
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
    
    private func getAirlineFromCallsign(_ callsign: String) -> String {
        print("🔍 Processing callsign: '\(callsign)'")
        
        // Extract airline prefix from callsign
        let airlinePrefix = String(callsign.prefix(2))
        print("🔍 Extracted prefix: '\(airlinePrefix)'")
        
        // Map airline prefixes to airline names
        let airlinePrefixMap: [String: String] = [
            "PS": "Ukraine International Airlines",
            "BA": "British Airways", 
            "AF": "Air France",
            "LH": "Lufthansa",
            "KL": "KLM Royal Dutch Airlines",
            "IB": "Iberia",
            "AZ": "Alitalia",
            "TK": "Turkish Airlines",
            "OS": "Austrian Airlines",
            "SK": "SAS",
            "AY": "Finnair",
            "FI": "Icelandair",
            "DY": "Norwegian",
            "FR": "Ryanair",
            "U2": "easyJet",
            "EW": "Eurowings",
            "AB": "Air Berlin",
            "DE": "Condor",
            "HV": "Transavia",
            "LX": "Swiss International Air Lines",
            "SN": "Brussels Airlines",
            "TP": "TAP Air Portugal",
            "VY": "Vueling",
            "WF": "Widerøe",
            "W6": "Wizz Air",
            "W9": "Wizz Air",
            "DLH": "Lufthansa",
            "BAW": "British Airways",
            "AFR": "Air France",
            "JAL": "Japan Airlines",
            "UAL": "United Airlines",
            "UAE": "Emirates",
            "SIA": "Singapore Airlines",
            "QFA": "Qantas",
            "SAA": "South African Airways",
            "ACA": "Air Canada"
        ]
        
        // Check for exact match first (for 3-letter codes)
        if let airline = airlinePrefixMap[callsign] {
            print("✅ Found exact match: '\(callsign)' → '\(airline)'")
            return airline
        }
        
        // Check for prefix match (for 2-letter codes)
        if let airline = airlinePrefixMap[airlinePrefix] {
            print("✅ Found prefix match: '\(airlinePrefix)' → '\(airline)'")
            return airline
        }
        
        // Return unknown if no match
        print("❌ No match found for callsign: '\(callsign)' (prefix: '\(airlinePrefix)')")
        return "UNKNOWN"
    }
    
    private func getAirlineInfoByName(_ airlineName: String, aircraftList: [AircraftPosition]) -> (name: String, country: String, region: Region, callsign: String, logoURL: URL?, website: URL?, countryCode: String, countryFlag: String, foundedYear: Int?, fleetSize: Int?, headquarters: String?) {
        // Known airline names mapping with extended data
        let airlineMappings: [String: (name: String, country: String, region: Region, callsign: String, logoURL: String?, website: String?, countryCode: String, countryFlag: String, foundedYear: Int?, fleetSize: Int?, headquarters: String?)] = [
            "Lufthansa": ("Lufthansa", "Germany", .europe, "DLH", "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8e/Lufthansa_logo_2018.svg/200px-Lufthansa_logo_2018.svg.png", "https://www.lufthansa.com", "DE", "🇩🇪", 1953, 280, "Frankfurt"),
            "British Airways": ("British Airways", "United Kingdom", .europe, "BAW", "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/British_Airways_logo.svg/200px-British_Airways_logo.svg.png", "https://www.britishairways.com", "GB", "🇬🇧", 1974, 280, "London"),
            "Air France": ("Air France", "France", .europe, "AFR", "https://upload.wikimedia.org/wikipedia/commons/thumb/4/44/Air_France_logo.svg/200px-Air_France_logo.svg.png", "https://www.airfrance.com", "FR", "🇫🇷", 1933, 220, "Paris"),
            "Japan Airlines": ("Japan Airlines", "Japan", .asia, "JAL", "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1d/Japan_Airlines_logo.svg/200px-Japan_Airlines_logo.svg.png", "https://www.jal.com", "JP", "🇯🇵", 1951, 150, "Tokyo"),
            "United Airlines": ("United Airlines", "United States", .america, "UAL", "https://upload.wikimedia.org/wikipedia/commons/thumb/6/63/United_Airlines_logo_2010.svg/200px-United_Airlines_logo_2010.svg.png", "https://www.united.com", "US", "🇺🇸", 1926, 800, "Chicago"),
            "Emirates": ("Emirates", "United Arab Emirates", .asia, "UAE", "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d0/Emirates_logo.svg/200px-Emirates_logo.svg.png", "https://www.emirates.com", "AE", "🇦🇪", 1985, 260, "Dubai"),
            "Singapore Airlines": ("Singapore Airlines", "Singapore", .asia, "SIA", "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4b/Singapore_Airlines_logo.svg/200px-Singapore_Airlines_logo.svg.png", "https://www.singaporeair.com", "SG", "🇸🇬", 1972, 150, "Singapore"),
            "Qantas": ("Qantas", "Australia", .oceania, "QFA", "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4b/Qantas_logo_2016.svg/200px-Qantas_logo_2016.svg.png", "https://www.qantas.com", "AU", "🇦🇺", 1920, 130, "Sydney"),
            "South African Airways": ("South African Airways", "South Africa", .africa, "SAA", "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8e/South_African_Airways_logo.svg/200px-South_African_Airways_logo.svg.png", "https://www.flysaa.com", "ZA", "🇿🇦", 1934, 50, "Johannesburg"),
            "Air Canada": ("Air Canada", "Canada", .america, "ACA", "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1d/Air_Canada_logo.svg/200px-Air_Canada_logo.svg.png", "https://www.aircanada.com", "CA", "🇨🇦", 1937, 180, "Montreal"),
            "Ukraine International Airlines": ("Ukraine International Airlines", "Ukraine", .europe, "PS", nil, "https://www.flyuia.com", "UA", "🇺🇦", 1992, 25, "Kyiv"),
            "Wizz Air": ("Wizz Air", "Hungary", .europe, "WZZ", nil, "https://wizzair.com", "HU", "🇭🇺", 2003, 180, "Budapest"),
            "Ryanair": ("Ryanair", "Ireland", .europe, "RYR", nil, "https://www.ryanair.com", "IE", "🇮🇪", 1984, 470, "Dublin"),
            "easyJet": ("easyJet", "United Kingdom", .europe, "EZY", nil, "https://www.easyjet.com", "GB", "🇬🇧", 1995, 330, "London"),
            "Swiss International Air Lines": ("Swiss International Air Lines", "Switzerland", .europe, "SWR", nil, "https://www.swiss.com", "CH", "🇨🇭", 2002, 90, "Zurich"),
            "KLM Royal Dutch Airlines": ("KLM Royal Dutch Airlines", "Netherlands", .europe, "KLM", nil, "https://www.klm.com", "NL", "🇳🇱", 1919, 110, "Amsterdam"),
            "Iberia": ("Iberia", "Spain", .europe, "IBE", nil, "https://www.iberia.com", "ES", "🇪🇸", 1927, 80, "Madrid"),
            "Alitalia": ("Alitalia", "Italy", .europe, "AZA", nil, "https://www.alitalia.com", "IT", "🇮🇹", 1946, 50, "Rome"),
            "Aeroflot": ("Aeroflot", "Russia", .europe, "AFL", nil, "https://www.aeroflot.com", "RU", "🇷🇺", 1923, 180, "Moscow"),
            "Turkish Airlines": ("Turkish Airlines", "Turkey", .europe, "THY", nil, "https://www.turkishairlines.com", "TR", "🇹🇷", 1933, 350, "Istanbul")
        ]
        
        if let mapping = airlineMappings[airlineName] {
            print("✅ Found mapping for '\(airlineName)': \(mapping.name)")
            return (
                name: mapping.name,
                country: mapping.country,
                region: mapping.region,
                callsign: mapping.callsign,
                logoURL: mapping.logoURL.flatMap(URL.init),
                website: mapping.website.flatMap(URL.init),
                countryCode: mapping.countryCode,
                countryFlag: mapping.countryFlag,
                foundedYear: mapping.foundedYear,
                fleetSize: mapping.fleetSize,
                headquarters: mapping.headquarters
            )
        } else {
            print("❌ No mapping found for '\(airlineName)', creating generic entry")
            // For unknown airlines, determine region from aircraft coordinates
            let region = determineRegionFromAircraft(aircraftList)
            let (countryCode, countryFlag) = getCountryInfoFromRegion(region)
            return (
                name: airlineName,
                country: "Unknown",
                region: region,
                callsign: "UNK",
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
