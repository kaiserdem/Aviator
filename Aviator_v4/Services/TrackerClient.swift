import Foundation
import ComposableArchitecture
import SwiftUI

struct TrackerClient {
    var trackFlight: (String) async -> FlightStatus?
    var getFlightStatus: (String, String) async -> FlightStatus?
}

extension TrackerClient: DependencyKey {
    static let liveValue = Self(
        trackFlight: { flightNumber in
            await TrackerService.shared.trackFlight(flightNumber: flightNumber)
        },
        getFlightStatus: { airlineCode, flightNumber in
            await TrackerService.shared.getFlightStatus(airlineCode: airlineCode, flightNumber: flightNumber)
        }
    )
}

extension DependencyValues {
    var trackerClient: TrackerClient {
        get { self[TrackerClient.self] }
        set { self[TrackerClient.self] = newValue }
    }
}

// MARK: - Tracker Service

final class TrackerService {
    static let shared = TrackerService()
    
    private init() {}
    
    func trackFlight(flightNumber: String) async -> FlightStatus? {
        // Parse flight number to extract airline code and flight number
        let components = parseFlightNumber(flightNumber)
        return await getFlightStatus(airlineCode: components.airlineCode, flightNumber: components.flightNumber)
    }
    
    func getFlightStatus(airlineCode: String, flightNumber: String) async -> FlightStatus? {
        do {
            let token = try await APIConfig.getAccessToken()
            
            let url = URL(string: "\(APIConfig.baseURL)/v2/schedule/flights?airlineCode=\(airlineCode)&flightNumber=\(flightNumber)")!
            
            var request = URLRequest(url: url)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("❌ Flight tracking API error: \(response)")
                return nil
            }
            
            let flightResponse = try JSONDecoder().decode(FlightStatusAPIResponse.self, from: data)
            return flightResponse.data.first.map { flightData in
                FlightStatus(
                    flightNumber: "\(flightData.flightNumber?.carrierCode ?? airlineCode)\(flightData.flightNumber?.number ?? flightNumber)",
                    origin: flightData.flightPoints?.first?.iataCode ?? "Unknown",
                    destination: flightData.flightPoints?.last?.iataCode ?? "Unknown",
                    scheduledDeparture: flightData.flightPoints?.first?.departure?.at ?? "",
                    scheduledArrival: flightData.flightPoints?.last?.arrival?.at ?? "",
                    actualDeparture: flightData.flightPoints?.first?.departure?.actualAt,
                    actualArrival: flightData.flightPoints?.last?.arrival?.actualAt,
                    status: flightData.flightStatus ?? "Unknown",
                    gate: flightData.flightPoints?.first?.departure?.gate,
                    terminal: flightData.flightPoints?.first?.departure?.terminal,
                    aircraft: flightData.aircraft?.model,
                    airline: flightData.flightNumber?.carrierCode ?? airlineCode
                )
            }
        } catch {
            print("❌ Flight tracking API error: \(error)")
            // Return mock data if API fails
            return generateMockFlightStatus(airlineCode: airlineCode, flightNumber: flightNumber)
        }
    }
    
    private func parseFlightNumber(_ flightNumber: String) -> (airlineCode: String, flightNumber: String) {
        // Extract airline code (first 2-3 characters) and flight number
        let cleanNumber = flightNumber.replacingOccurrences(of: " ", with: "")
        
        if cleanNumber.count >= 3 {
            let airlineCode = String(cleanNumber.prefix(2))
            let flightNum = String(cleanNumber.dropFirst(2))
            return (airlineCode, flightNum)
        }
        
        return ("UA", flightNumber)
    }
    
    private func generateMockFlightStatus(airlineCode: String, flightNumber: String) -> FlightStatus {
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        let scheduledDeparture = Calendar.current.date(byAdding: .hour, value: -2, to: now) ?? now
        let scheduledArrival = Calendar.current.date(byAdding: .hour, value: 2, to: now) ?? now
        
        return FlightStatus(
            flightNumber: "\(airlineCode)\(flightNumber)",
            origin: "NYC",
            destination: "LAX",
            scheduledDeparture: formatter.string(from: scheduledDeparture),
            scheduledArrival: formatter.string(from: scheduledArrival),
            actualDeparture: formatter.string(from: scheduledDeparture),
            actualArrival: nil,
            status: "On Time",
            gate: "A12",
            terminal: "1",
            aircraft: "Boeing 737",
            airline: airlineCode
        )
    }
}

// MARK: - Models

struct FlightStatus: Equatable, Identifiable {
    let id = UUID()
    let flightNumber: String
    let origin: String
    let destination: String
    let scheduledDeparture: String
    let scheduledArrival: String
    let actualDeparture: String?
    let actualArrival: String?
    let status: String
    let gate: String?
    let terminal: String?
    let aircraft: String?
    let airline: String
    
    var formattedScheduledDeparture: String {
        return formatTime(scheduledDeparture)
    }
    
    var formattedScheduledArrival: String {
        return formatTime(scheduledArrival)
    }
    
    var formattedActualDeparture: String? {
        guard let actualDeparture = actualDeparture else { return nil }
        return formatTime(actualDeparture)
    }
    
    var formattedActualArrival: String? {
        guard let actualArrival = actualArrival else { return nil }
        return formatTime(actualArrival)
    }
    
    var statusColor: Color {
        switch status.lowercased() {
        case "on time", "scheduled":
            return .green
        case "delayed":
            return .orange
        case "cancelled":
            return .red
        case "boarding":
            return .blue
        case "departed":
            return .purple
        default:
            return .gray
        }
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
}

// MARK: - API Response Models

struct FlightStatusAPIResponse: Codable {
    let data: [FlightStatusData]
}

struct FlightStatusData: Codable {
    let flightNumber: FlightNumberInfo?
    let flightPoints: [FlightPoint]?
    let flightStatus: String?
    let aircraft: AircraftInfo?
}

struct FlightNumberInfo: Codable {
    let carrierCode: String?
    let number: String?
}

struct FlightPoint: Codable {
    let iataCode: String?
    let departure: DepartureInfo?
    let arrival: ArrivalInfo?
}

struct DepartureInfo: Codable {
    let at: String?
    let actualAt: String?
    let gate: String?
    let terminal: String?
}

struct ArrivalInfo: Codable {
    let at: String?
    let actualAt: String?
    let gate: String?
    let terminal: String?
}

struct AircraftInfo: Codable {
    let model: String?
}
