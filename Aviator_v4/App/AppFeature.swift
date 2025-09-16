import ComposableArchitecture
import Foundation

struct AppFeature: Reducer {
    struct State: Equatable {
        enum Tab: Hashable { case hotels, aviationSports, tab3, favorites }
        var selectedTab: Tab = .aviationSports
        var hotels = HotelsFeature.State()
        var aviationSports = AviationSportsFeature.State()
        var tab3 = Tab3Feature.State()
        var favorites = FavoritesFeature.State()
        
        // Спільний стан улюблених спорту
        var favoriteSports: Set<String> = []
        
        init() {
            // Завантажуємо збережені улюблені спорти з UserDefaults
            if let savedFavorites = UserDefaults.standard.object(forKey: "favoriteSports") as? [String] {
                self.favoriteSports = Set(savedFavorites)
                print("📱 Loaded \(self.favoriteSports.count) favorites from UserDefaults: \(self.favoriteSports)")
            } else {
                self.favoriteSports = []
                print("📱 No saved favorites found, starting with empty set")
            }
            
            // Ініціалізуємо спільний стан
            self.aviationSports.favoriteSports = self.favoriteSports
            self.favorites.favoriteSports = self.favoriteSports
        }
    }

    enum Action: Equatable {
        case selectTab(State.Tab)
        case hotels(HotelsFeature.Action)
        case aviationSports(AviationSportsFeature.Action)
        case tab3(Tab3Feature.Action)
        case favorites(FavoritesFeature.Action)
        case toggleFavorite(String) // sportId
        case clearAllFavorites // Очистити всі улюблені
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.hotels, action: /Action.hotels) { HotelsFeature() }
        Scope(state: \.aviationSports, action: /Action.aviationSports) { AviationSportsFeature() }
        Scope(state: \.tab3, action: /Action.tab3) { Tab3Feature() }
        Scope(state: \.favorites, action: /Action.favorites) { FavoritesFeature() }

        Reduce { state, action in
            switch action {
            case let .selectTab(tab):
                state.selectedTab = tab
                return .none
                
            case let .toggleFavorite(sportId):
                print("🔄 Toggle favorite: \(sportId)")
                print("📊 Current favorites before: \(state.favoriteSports)")
                
                if state.favoriteSports.contains(sportId) {
                    state.favoriteSports.remove(sportId)
                    print("❌ Removed from favorites")
                } else {
                    state.favoriteSports.insert(sportId)
                    print("✅ Added to favorites")
                }
                
                print("📊 Current favorites after: \(state.favoriteSports)")
                
                // Зберігаємо в UserDefaults
                let favoritesArray = Array(state.favoriteSports)
                UserDefaults.standard.set(favoritesArray, forKey: "favoriteSports")
                print("💾 Saved \(favoritesArray.count) favorites to UserDefaults: \(favoritesArray)")
                
                // Синхронізуємо стан з AviationSportsFeature
                state.aviationSports.favoriteSports = state.favoriteSports
                // Синхронізуємо стан з FavoritesFeature
                state.favorites.favoriteSports = state.favoriteSports
                
                print("🔄 Synced with AviationSports: \(state.aviationSports.favoriteSports)")
                print("🔄 Synced with Favorites: \(state.favorites.favoriteSports)")
                
                // Перезавантажуємо список улюблених
                return .send(.favorites(.loadFavorites))
                
            case .clearAllFavorites:
                print("🗑️ Clearing all favorites")
                state.favoriteSports.removeAll()
                
                // Зберігаємо порожній список в UserDefaults
                UserDefaults.standard.set([], forKey: "favoriteSports")
                print("💾 Cleared all favorites from UserDefaults")
                
                // Синхронізуємо стан
                state.aviationSports.favoriteSports = state.favoriteSports
                state.favorites.favoriteSports = state.favoriteSports
                
                // Перезавантажуємо список улюблених
                return .send(.favorites(.loadFavorites))
                
            default:
                return .none
            }
        }
    }
}
