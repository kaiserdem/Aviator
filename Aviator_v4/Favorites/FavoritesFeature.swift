import ComposableArchitecture
import Foundation

struct FavoritesFeature: Reducer {
    struct State: Equatable {
        var favoriteSports: Set<String> = []
        var favoriteSportsData: [AviationSport] = []
        var isLoading = false
        var errorMessage: String?
        
        init() {}
    }
    
    enum Action: Equatable {
        case onAppear
        case loadFavorites
        case favoritesResponse([AviationSport])
        case loadError(String)
        case removeFavorite(String) 
        case favoriteRemoved(String) 
    }
    
    @Dependency(\.aviationSportsClient) var aviationSportsClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .send(.loadFavorites)
                
            case .loadFavorites:
                state.isLoading = true
                state.errorMessage = nil
                return .run { send in
                    
                    let allSports = await aviationSportsClient.getSports(.all, "Global")
                    await send(.favoritesResponse(allSports))
                }
                
            case let .favoritesResponse(sports):
                state.isLoading = false
                print("📋 FavoritesFeature: Received \(sports.count) sports")
                print("❤️ Current favoriteSports: \(state.favoriteSports)")
                print("🔍 Looking for favorites in: \(state.favoriteSports)")
                
                
                state.favoriteSportsData = sports.filter { sport in
                    let isFavorite = state.favoriteSports.contains(sport.id.uuidString)
                    print("🔍 Sport '\(sport.name)' (\(sport.id.uuidString)) is favorite: \(isFavorite)")
                    if isFavorite {
                        print("✅ Found favorite: \(sport.name)")
                    }
                    return isFavorite
                }
                
                print("✅ Filtered to \(state.favoriteSportsData.count) favorite sports")
                print("📊 Final favoriteSportsData: \(state.favoriteSportsData.map { $0.name })")
                return .none
                
            case let .loadError(error):
                state.isLoading = false
                state.errorMessage = error
                return .none
                
            case let .removeFavorite(sportId):
                state.favoriteSports.remove(sportId)
                return .send(.favoriteRemoved(sportId))
                
            case let .favoriteRemoved(sportId):
                
                return .none
            }
        }
    }
}
