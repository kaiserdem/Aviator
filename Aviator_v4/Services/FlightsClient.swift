import Foundation
import ComposableArchitecture

struct FlightsClient {
    var searchFlights: (String, String, Date, Int) async -> [Flight]
}

extension FlightsClient: DependencyKey {
    static let liveValue = Self(
        searchFlights: { origin, destination, departureDate, passengers in
            await FlightsService.shared.searchFlights(
                origin: origin,
                destination: destination,
                departureDate: departureDate,
                passengers: passengers
            )
        }
    )
}

extension DependencyValues {
    var flightsClient: FlightsClient {
        get { self[FlightsClient.self] }
        set { self[FlightsClient.self] = newValue }
    }
}


final class FlightsService {
    static let shared = FlightsService()
    
    private init() {}
    
    func searchFlights(origin: String, destination: String, departureDate: Date, passengers: Int) async -> [Flight] {
        do {
            
            let normalizedOrigin = normalizeAirportCode(origin)
            let normalizedDestination = normalizeAirportCode(destination)
            
            print("🌐 Normalized codes: \(normalizedOrigin) -> \(normalizedDestination)")
            
            let token = try await APIConfig.getAccessToken()
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let departureDateString = formatter.string(from: departureDate)
            
            let url = URL(string: "\(APIConfig.baseURL)/v2/shopping/flight-offers?originLocationCode=\(normalizedOrigin)&destinationLocationCode=\(normalizedDestination)&departureDate=\(departureDateString)&adults=\(passengers)&max=10")!
            
            var request = URLRequest(url: url)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("❌ Flights API error: \(response)")
                return []
            }
            
            let flightsResponse = try JSONDecoder().decode(FlightsAPIResponse.self, from: data)
            return flightsResponse.data.map { flightData in
                Flight(
                    id: flightData.id,
                    origin: flightData.itineraries.first?.segments.first?.departure?.iataCode ?? normalizedOrigin,
                    destination: flightData.itineraries.first?.segments.last?.arrival?.iataCode ?? normalizedDestination,
                    departureTime: flightData.itineraries.first?.segments.first?.departure?.at ?? "",
                    arrivalTime: flightData.itineraries.first?.segments.last?.arrival?.at ?? "",
                    airline: flightData.itineraries.first?.segments.first?.carrierCode ?? "Unknown",
                    flightNumber: flightData.itineraries.first?.segments.first?.number ?? "",
                    price: flightData.price?.total ?? "0",
                    currency: flightData.price?.currency ?? "USD",
                    duration: flightData.itineraries.first?.duration ?? "PT0H0M",
                    stops: flightData.itineraries.first?.segments.count ?? 1 - 1
                )
            }
        } catch {
            print("❌ Flights API error: \(error)")
            return []
        }
    }
    
    
    
    private func normalizeAirportCode(_ input: String) -> String {
        let code = input.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        
        let mappings: [String: String] = [
            "WARSHAWA": "WAW",    
            "WARSAW": "WAW",
            "SIFIA": "SOF",       
            "SOFIA": "SOF",
            "PARIS": "CDG",
            "LONDON": "LHR",
            "NEW YORK": "NYC",
            "LOS ANGELES": "LAX",
            "MADRID": "MAD",
            "ROME": "FCO",
            "BERLIN": "BER",
            "MUNICH": "MUC",
            "FRANKFURT": "FRA",
            "AMSTERDAM": "AMS",
            "VIENNA": "VIE",
            "PRAGUE": "PRG",
            "BUDAPEST": "BUD",
            "STOCKHOLM": "ARN",
            "COPENHAGEN": "CPH",
            "OSLO": "OSL",
            "HELSINKI": "HEL",
            "MOSCOW": "SVO",
            "ISTANBUL": "IST",
            "DUBAI": "DXB",
            "TOKYO": "NRT",
            "SEOUL": "ICN",
            "BEIJING": "PEK",
            "SHANGHAI": "PVG",
            "SYDNEY": "SYD",
            "MELBOURNE": "MEL",
            "TORONTO": "YYZ",
            "VANCOUVER": "YVR",
            "MEXICO CITY": "MEX",
            "SAO PAULO": "GRU",
            "BUENOS AIRES": "EZE",
            "JOHANNESBURG": "JNB",
            "CAIRO": "CAI",
            "MUMBAI": "BOM",
            "DELHI": "DEL",
            "BANGKOK": "BKK",
            "SINGAPORE": "SIN",
            "HONG KONG": "HKG",
            "TAIPEI": "TPE"
        ]
        
        
        if code.count == 3 && code.allSatisfy({ $0.isLetter }) {
            return code
        }
        
        
        if let mapped = mappings[code] {
            return mapped
        }
        
        
        let letters = code.filter { $0.isLetter }
        if letters.count >= 3 {
            return String(letters.prefix(3))
        }
        
        
        print("⚠️ Could not normalize airport code: \(input)")
        return code
    }
    
    
}


struct Flight: Equatable, Identifiable {
    let id: String
    let origin: String
    let destination: String
    let departureTime: String
    let arrivalTime: String
    let airline: String
    let flightNumber: String
    let price: String
    let currency: String
    let duration: String
    let stops: Int
    
    var formattedDepartureTime: String {
        return formatTime(departureTime)
    }
    
    var formattedArrivalTime: String {
        return formatTime(arrivalTime)
    }
    
    var formattedDuration: String {
        return formatDuration(duration)
    }
    
    private func formatTime(_ timeString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let date = formatter.date(from: timeString) {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            return timeFormatter.string(from: date)
        }
        return timeString
    }
    
    private func formatDuration(_ duration: String) -> String {
        
        let cleanDuration = duration.replacingOccurrences(of: "PT", with: "")
        let hours = cleanDuration.components(separatedBy: "H").first ?? "0"
        let minutes = cleanDuration.components(separatedBy: "H").last?.replacingOccurrences(of: "M", with: "") ?? "0"
        return "\(hours)h \(minutes)m"
    }
}


struct FlightsAPIResponse: Codable {
    let data: [FlightData]
}

struct FlightData: Codable {
    let id: String
    let itineraries: [Itinerary]
    let price: FlightPrice?
}

struct Itinerary: Codable {
    let duration: String
    let segments: [Segment]
}

struct Segment: Codable {
    let departure: Departure?
    let arrival: Arrival?
    let carrierCode: String?
    let number: String?
}

struct Departure: Codable {
    let iataCode: String?
    let at: String?
}

struct Arrival: Codable {
    let iataCode: String?
    let at: String?
}

struct FlightPrice: Codable {
    let total: String?
    let currency: String?
}
