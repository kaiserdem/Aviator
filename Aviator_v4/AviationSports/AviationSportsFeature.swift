import ComposableArchitecture
import Foundation

struct AviationSportsFeature: Reducer {
    struct State: Equatable {
        var isLoading = false
        var sports: [AviationSport] = []
        var selectedCategory: SportCategory = .all
        var selectedLocation = "Global"
        var errorMessage: String?
        
        init() {}
    }
    
    enum Action: Equatable {
        case onAppear
        case categoryChanged(SportCategory)
        case locationChanged(String)
        case loadSports
        case sportsResponse([AviationSport])
        case loadError(String)
    }
    
    @Dependency(\.aviationSportsClient) var aviationSportsClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { [category = state.selectedCategory, location = state.selectedLocation] send in
                    let sports = await aviationSportsClient.getSports(category, location)
                    await send(.sportsResponse(sports))
                }
                
            case let .categoryChanged(category):
                state.selectedCategory = category
                return .send(.loadSports)
                
            case let .locationChanged(location):
                state.selectedLocation = location
                return .send(.loadSports)
                
            case .loadSports:
                state.isLoading = true
                state.errorMessage = nil
                return .run { [category = state.selectedCategory, location = state.selectedLocation] send in
                    let sports = await aviationSportsClient.getSports(category, location)
                    await send(.sportsResponse(sports))
                }
                
            case let .sportsResponse(sports):
                state.isLoading = false
                state.sports = sports
                return .none
                
            case let .loadError(error):
                state.isLoading = false
                state.errorMessage = error
                return .none
            }
        }
    }
}

// MARK: - Models

enum SportCategory: String, CaseIterable, Equatable {
    case all = "All"
    case aerobatics = "Aerobatics"
    case gliding = "Gliding"
    case parachuting = "Parachuting"
    case ballooning = "Ballooning"
    case airRacing = "Air Racing"
    case formationFlying = "Formation Flying"
    case precisionFlying = "Precision Flying"
}

struct AviationSport: Equatable, Identifiable {
    let id = UUID()
    let name: String
    let category: SportCategory
    let description: String
    let difficulty: DifficultyLevel
    let equipment: [String]
    let locations: [String]
    let imageURL: String?
    let rules: [String]
    let competitions: [Competition]
    
    init(name: String, category: SportCategory, description: String, difficulty: DifficultyLevel, equipment: [String], locations: [String], imageURL: String? = nil, rules: [String], competitions: [Competition]) {
        self.name = name
        self.category = category
        self.description = description
        self.difficulty = difficulty
        self.equipment = equipment
        self.locations = locations
        self.imageURL = imageURL
        self.rules = rules
        self.competitions = competitions
    }
    
    static func == (lhs: AviationSport, rhs: AviationSport) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.category == rhs.category &&
               lhs.description == rhs.description &&
               lhs.difficulty == rhs.difficulty &&
               lhs.equipment == rhs.equipment &&
               lhs.locations == rhs.locations &&
               lhs.imageURL == rhs.imageURL &&
               lhs.rules == rhs.rules &&
               lhs.competitions == rhs.competitions
    }
}

enum DifficultyLevel: String, CaseIterable, Equatable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case expert = "Expert"
    
    var color: String {
        switch self {
        case .beginner: return "green"
        case .intermediate: return "blue"
        case .advanced: return "orange"
        case .expert: return "red"
        }
    }
}

struct Competition: Equatable, Identifiable {
    let id = UUID()
    let name: String
    let date: String
    let location: String
    let type: CompetitionType
    let prize: String?
    
    init(name: String, date: String, location: String, type: CompetitionType, prize: String? = nil) {
        self.name = name
        self.date = date
        self.location = location
        self.type = type
        self.prize = prize
    }
    
    static func == (lhs: Competition, rhs: Competition) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.date == rhs.date &&
               lhs.location == rhs.location &&
               lhs.type == rhs.type &&
               lhs.prize == rhs.prize
    }
}

enum CompetitionType: String, CaseIterable, Equatable {
    case worldChampionship = "World Championship"
    case nationalChampionship = "National Championship"
    case regionalChampionship = "Regional Championship"
    case localCompetition = "Local Competition"
    case exhibition = "Exhibition"
}
