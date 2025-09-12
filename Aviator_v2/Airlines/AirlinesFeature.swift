import ComposableArchitecture
import Foundation

struct AirlinesFeature: Reducer {
    struct State: Equatable {
        var isLoading = false
        var airlines: [Airline] = []
        var selectedAirline: Airline?
        var selectedRegion: Region = .all
    }

    enum Action: Equatable {
        case onAppear
        case _airlinesResponse([Airline])
        case selectAirline(Airline?)
        case selectRegion(Region)
    }

    @Dependency(\.airlineClient) var airlineClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    let airlines = await airlineClient.fetchAirlines()
                    await send(._airlinesResponse(airlines))
                }
                
            case let ._airlinesResponse(airlines):
                state.isLoading = false
                state.airlines = airlines
                return .none
                
            case let .selectAirline(airline):
                state.selectedAirline = airline
                return .none
                
            case let .selectRegion(region):
                state.selectedRegion = region
                return .none
            }
        }
    }
}

// MARK: - Models

struct Airline: Identifiable, Equatable, Hashable {
    let id: UUID = UUID()
    let name: String
    let country: String
    let region: Region
    let callsign: String
    let activeFlights: Int
    let logoURL: URL?
    let website: URL?
    let countryCode: String
    let countryFlag: String
    let foundedYear: Int?
    let fleetSize: Int?
    let headquarters: String?
}

enum Region: String, CaseIterable, Equatable {
    case all = "All"
    case europe = "Europe"
    case asia = "Asia"
    case america = "America"
    case africa = "Africa"
    case oceania = "Oceania"
    
    var emoji: String {
        switch self {
        case .all: return "🌍"
        case .europe: return "🇪🇺"
        case .asia: return "🌏"
        case .america: return "🌎"
        case .africa: return "🌍"
        case .oceania: return "🌏"
        }
    }
}
