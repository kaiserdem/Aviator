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
    
    static let testValue = Self(
        fetchAirlines: {
            [
                Airline(
                    name: "Lufthansa",
                    country: "Germany",
                    region: .europe,
                    callsign: "DLH",
                    activeFlights: 45,
                    logoURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8e/Lufthansa_logo_2018.svg/200px-Lufthansa_logo_2018.svg.png"),
                    website: URL(string: "https://www.lufthansa.com")
                ),
                Airline(
                    name: "British Airways",
                    country: "United Kingdom",
                    region: .europe,
                    callsign: "BAW",
                    activeFlights: 38,
                    logoURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/British_Airways_logo.svg/200px-British_Airways_logo.svg.png"),
                    website: URL(string: "https://www.britishairways.com")
                ),
                Airline(
                    name: "Air France",
                    country: "France",
                    region: .europe,
                    callsign: "AFR",
                    activeFlights: 42,
                    logoURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/44/Air_France_logo.svg/200px-Air_France_logo.svg.png"),
                    website: URL(string: "https://www.airfrance.com")
                ),
                Airline(
                    name: "Japan Airlines",
                    country: "Japan",
                    region: .asia,
                    callsign: "JAL",
                    activeFlights: 28,
                    logoURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1d/Japan_Airlines_logo.svg/200px-Japan_Airlines_logo.svg.png"),
                    website: URL(string: "https://www.jal.com")
                ),
                Airline(
                    name: "United Airlines",
                    country: "United States",
                    region: .america,
                    callsign: "UAL",
                    activeFlights: 67,
                    logoURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/6/63/United_Airlines_logo_2010.svg/200px-United_Airlines_logo_2010.svg.png"),
                    website: URL(string: "https://www.united.com")
                )
            ]
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
        // For now, return mock data
        // In the future, this could fetch from OpenSky API and group by callsign
        return [
            Airline(
                name: "Lufthansa",
                country: "Germany",
                region: .europe,
                callsign: "DLH",
                activeFlights: Int.random(in: 20...60),
                logoURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8e/Lufthansa_logo_2018.svg/200px-Lufthansa_logo_2018.svg.png"),
                website: URL(string: "https://www.lufthansa.com")
            ),
            Airline(
                name: "British Airways",
                country: "United Kingdom",
                region: .europe,
                callsign: "BAW",
                activeFlights: Int.random(in: 20...60),
                logoURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/British_Airways_logo.svg/200px-British_Airways_logo.svg.png"),
                website: URL(string: "https://www.britishairways.com")
            ),
            Airline(
                name: "Air France",
                country: "France",
                region: .europe,
                callsign: "AFR",
                activeFlights: Int.random(in: 20...60),
                logoURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/44/Air_France_logo.svg/200px-Air_France_logo.svg.png"),
                website: URL(string: "https://www.airfrance.com")
            ),
            Airline(
                name: "Japan Airlines",
                country: "Japan",
                region: .asia,
                callsign: "JAL",
                activeFlights: Int.random(in: 20...60),
                logoURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1d/Japan_Airlines_logo.svg/200px-Japan_Airlines_logo.svg.png"),
                website: URL(string: "https://www.jal.com")
            ),
            Airline(
                name: "United Airlines",
                country: "United States",
                region: .america,
                callsign: "UAL",
                activeFlights: Int.random(in: 20...60),
                logoURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/6/63/United_Airlines_logo_2010.svg/200px-United_Airlines_logo_2010.svg.png"),
                website: URL(string: "https://www.united.com")
            ),
            Airline(
                name: "Emirates",
                country: "United Arab Emirates",
                region: .asia,
                callsign: "UAE",
                activeFlights: Int.random(in: 20...60),
                logoURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d0/Emirates_logo.svg/200px-Emirates_logo.svg.png"),
                website: URL(string: "https://www.emirates.com")
            ),
            Airline(
                name: "Singapore Airlines",
                country: "Singapore",
                region: .asia,
                callsign: "SIA",
                activeFlights: Int.random(in: 20...60),
                logoURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4b/Singapore_Airlines_logo.svg/200px-Singapore_Airlines_logo.svg.png"),
                website: URL(string: "https://www.singaporeair.com")
            ),
            Airline(
                name: "Qantas",
                country: "Australia",
                region: .oceania,
                callsign: "QFA",
                activeFlights: Int.random(in: 20...60),
                logoURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4b/Qantas_logo_2016.svg/200px-Qantas_logo_2016.svg.png"),
                website: URL(string: "https://www.qantas.com")
            ),
            Airline(
                name: "South African Airways",
                country: "South Africa",
                region: .africa,
                callsign: "SAA",
                activeFlights: Int.random(in: 20...60),
                logoURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8e/South_African_Airways_logo.svg/200px-South_African_Airways_logo.svg.png"),
                website: URL(string: "https://www.flysaa.com")
            ),
            Airline(
                name: "Air Canada",
                country: "Canada",
                region: .america,
                callsign: "ACA",
                activeFlights: Int.random(in: 20...60),
                logoURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1d/Air_Canada_logo.svg/200px-Air_Canada_logo.svg.png"),
                website: URL(string: "https://www.aircanada.com")
            )
        ]
    }
}
