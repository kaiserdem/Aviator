import ComposableArchitecture
import Foundation

struct AppFeature: Reducer {
    struct State: Equatable {
        enum Tab: Hashable { case hotels, aviationSports, tab3, favorites }
        var selectedTab: Tab = .aviationSports
        var hotels = HotelsFeature.State()
        var aviationSports = AviationSportsFeature.State()
        var tab3 = SearchFeature.State()
        var favorites = FavoritesFeature.State()
        
        var favoriteSports: Set<String> = []
        
        init() {
            if let savedFavorites = UserDefaults.standard.object(forKey: "favoriteSports") as? [String] {
                self.favoriteSports = Set(savedFavorites)
                print("📱 Loaded \(self.favoriteSports.count) favorites from UserDefaults: \(self.favoriteSports)")
            } else {
                self.favoriteSports = []
                print("📱 No saved favorites found, starting with empty set")
            }
            
            self.aviationSports.favoriteSports = self.favoriteSports
            self.favorites.favoriteSports = self.favoriteSports
        }
    }

    enum Action: Equatable {
        case selectTab(State.Tab)
        case hotels(HotelsFeature.Action)
        case aviationSports(AviationSportsFeature.Action)
        case tab3(SearchFeature.Action)
        case favorites(FavoritesFeature.Action)
        case toggleFavorite(String)
        case clearAllFavorites
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.hotels, action: /Action.hotels) { HotelsFeature() }
        Scope(state: \.aviationSports, action: /Action.aviationSports) { AviationSportsFeature() }
        Scope(state: \.tab3, action: /Action.tab3) { SearchFeature() }
        Scope(state: \.favorites, action: /Action.favorites) { FavoritesFeature() }

        Reduce { state, action in
            switch action {
            case let .selectTab(tab):
                state.selectedTab = tab
                return .none
                
            case let .toggleFavorite(sportId):
               
                if state.favoriteSports.contains(sportId) {
                    state.favoriteSports.remove(sportId)
                } else {
                    state.favoriteSports.insert(sportId)
                }
                
                
                let favoritesArray = Array(state.favoriteSports)
                UserDefaults.standard.set(favoritesArray, forKey: "favoriteSports")
                
                state.aviationSports.favoriteSports = state.favoriteSports
                state.favorites.favoriteSports = state.favoriteSports
              
                return .send(.favorites(.loadFavorites))
                
            case .clearAllFavorites:
                state.favoriteSports.removeAll()
                
                UserDefaults.standard.set([], forKey: "favoriteSports")
                
                state.aviationSports.favoriteSports = state.favoriteSports
                state.favorites.favoriteSports = state.favoriteSports
                
                return .send(.favorites(.loadFavorites))
                
            default:
                return .none
            }
        }
    }
}
