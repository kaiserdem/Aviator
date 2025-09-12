import ComposableArchitecture
import Foundation

struct StatsFeature: Reducer {
    struct State: Equatable {
        var isLoading = false
        var stats: FlightStats = FlightStats()
        var selectedCategory: StatCategory = .live
    }

    enum Action: Equatable {
        case onAppear
        case _statsResponse(FlightStats)
        case selectCategory(StatCategory)
    }

    @Dependency(\.statsClient) var statsClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    let stats = await statsClient.fetchStats()
                    await send(._statsResponse(stats))
                }
                
            case let ._statsResponse(stats):
                state.isLoading = false
                state.stats = stats
                return .none
                
            case let .selectCategory(category):
                state.selectedCategory = category
                return .none
            }
        }
    }
}

// MARK: - Models

struct FlightStats: Equatable {
    let totalAircraft: Int
    let fastestAircraft: AircraftStat
    let highestAircraft: AircraftStat
    let lowestAircraft: AircraftStat
    let regionalStats: [RegionStat]
    let aircraftTypeStats: [AircraftTypeStat]
    let lastUpdated: Date
    
    init() {
        self.totalAircraft = 0
        self.fastestAircraft = AircraftStat()
        self.highestAircraft = AircraftStat()
        self.lowestAircraft = AircraftStat()
        self.regionalStats = []
        self.aircraftTypeStats = []
        self.lastUpdated = Date()
    }
    
    init(totalAircraft: Int, fastestAircraft: AircraftStat, highestAircraft: AircraftStat, lowestAircraft: AircraftStat, regionalStats: [RegionStat], aircraftTypeStats: [AircraftTypeStat], lastUpdated: Date) {
        self.totalAircraft = totalAircraft
        self.fastestAircraft = fastestAircraft
        self.highestAircraft = highestAircraft
        self.lowestAircraft = lowestAircraft
        self.regionalStats = regionalStats
        self.aircraftTypeStats = aircraftTypeStats
        self.lastUpdated = lastUpdated
    }
    
    static func == (lhs: FlightStats, rhs: FlightStats) -> Bool {
        lhs.totalAircraft == rhs.totalAircraft &&
        lhs.fastestAircraft == rhs.fastestAircraft &&
        lhs.highestAircraft == rhs.highestAircraft &&
        lhs.lowestAircraft == rhs.lowestAircraft &&
        lhs.regionalStats == rhs.regionalStats &&
        lhs.aircraftTypeStats == rhs.aircraftTypeStats &&
        lhs.lastUpdated == rhs.lastUpdated
    }
}

struct AircraftStat: Equatable {
    let callsign: String
    let value: Double
    let unit: String
    let country: String
    let aircraftType: String
    
    init() {
        self.callsign = ""
        self.value = 0
        self.unit = ""
        self.country = ""
        self.aircraftType = ""
    }
    
    init(callsign: String, value: Double, unit: String, country: String, aircraftType: String) {
        self.callsign = callsign
        self.value = value
        self.unit = unit
        self.country = country
        self.aircraftType = aircraftType
    }
}

struct RegionStat: Equatable {
    let region: Region
    let aircraftCount: Int
    let averageSpeed: Double
    let averageAltitude: Double
    
    static func == (lhs: RegionStat, rhs: RegionStat) -> Bool {
        lhs.region == rhs.region &&
        lhs.aircraftCount == rhs.aircraftCount &&
        lhs.averageSpeed == rhs.averageSpeed &&
        lhs.averageAltitude == rhs.averageAltitude
    }
}

struct AircraftTypeStat: Equatable {
    let type: String
    let count: Int
    let averageSpeed: Double
    let averageAltitude: Double
    
    static func == (lhs: AircraftTypeStat, rhs: AircraftTypeStat) -> Bool {
        lhs.type == rhs.type &&
        lhs.count == rhs.count &&
        lhs.averageSpeed == rhs.averageSpeed &&
        lhs.averageAltitude == rhs.averageAltitude
    }
}

enum StatCategory: String, CaseIterable, Equatable {
    case live = "Live Stats"
    case regional = "Regional"
    case aircraft = "Aircraft Types"
    
    var icon: String {
        switch self {
        case .live: return "bolt.fill"
        case .regional: return "globe"
        case .aircraft: return "airplane"
        }
    }
}
