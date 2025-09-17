import ComposableArchitecture
import Foundation

struct AviationSportsFeature: Reducer {
    struct State: Equatable {
        var isLoading = false
        var sports: [AviationSport] = []
        var selectedCategory: SportCategory = .all
        var selectedLocation = "Global"
        var errorMessage: String?
        var favoriteSports: Set<String> = []
        var loadedImages: Set<String> = [] 
        var loadedDescriptions: Set<String> = [] 
        
        init() {}
    }
    
    enum Action: Equatable {
        case onAppear
        case categoryChanged(SportCategory)
        case locationChanged(String)
        case loadSports
        case sportsResponse([AviationSport])
        case loadError(String)
        case loadSportImage(String, String) 
        case sportImageResponse(String, String?) 
        case loadSportDescription(String, String) 
        case sportDescriptionResponse(String, String?) 
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
                state.loadedImages.removeAll() 
                state.loadedDescriptions.removeAll() 
                return .send(.loadSports)
                
            case let .locationChanged(location):
                state.selectedLocation = location
                state.loadedImages.removeAll() 
                state.loadedDescriptions.removeAll() 
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
                
            case let .loadSportImage(sportId, sportName):
                
                if state.loadedImages.contains(sportId) {
                    return .none
                }
                state.loadedImages.insert(sportId)
                return .run { send in
                    let imageURL = await aviationSportsClient.getSportImage(sportName)
                    await send(.sportImageResponse(sportId, imageURL))
                }
                
            case let .sportImageResponse(sportId, imageURL):
                if let index = state.sports.firstIndex(where: { $0.id.uuidString == sportId }) {
                    state.sports[index] = AviationSport(
                        name: state.sports[index].name,
                        category: state.sports[index].category,
                        description: state.sports[index].description,
                        difficulty: state.sports[index].difficulty,
                        equipment: state.sports[index].equipment,
                        locations: state.sports[index].locations,
                        imageURL: imageURL,
                        rules: state.sports[index].rules
                    )
                }
                return .none
                
            case let .loadSportDescription(sportId, sportName):
                
                if state.loadedDescriptions.contains(sportId) {
                    return .none
                }
                state.loadedDescriptions.insert(sportId)
                return .run { send in
                    let description = await aviationSportsClient.getSportDescription(sportName)
                    await send(.sportDescriptionResponse(sportId, description))
                }
                
            case let .sportDescriptionResponse(sportId, description):
                if let index = state.sports.firstIndex(where: { $0.id.uuidString == sportId }),
                   let newDescription = description {
                    state.sports[index] = AviationSport(
                        name: state.sports[index].name,
                        category: state.sports[index].category,
                        description: newDescription,
                        difficulty: state.sports[index].difficulty,
                        equipment: state.sports[index].equipment,
                        locations: state.sports[index].locations,
                        imageURL: state.sports[index].imageURL,
                        rules: state.sports[index].rules
                    )
                }
                return .none
            }
        }
    }
}
