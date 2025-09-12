import ComposableArchitecture
import Foundation

struct SavedFeature: Reducer {
    struct State: Equatable {
        var savedSearches: [SavedSearch] = []
        var selectedSearch: SavedSearch?
    }

    enum Action: Equatable {
        case onAppear
        case addSearch(SavedSearch)
        case removeSearch(SavedSearch)
        case selectSearch(SavedSearch?)
        case _savedSearchesResponse([SavedSearch])
    }

    @Dependency(\.amadeusClient) var amadeusClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    let searches = await amadeusClient.getSavedSearches()
                    await send(._savedSearchesResponse(searches))
                }
                
            case let .addSearch(search):
                state.savedSearches.append(search)
                return .none
                
            case let .removeSearch(search):
                state.savedSearches.removeAll { $0.id == search.id }
                return .none
                
            case let .selectSearch(search):
                state.selectedSearch = search
                return .none
                
            case let ._savedSearchesResponse(searches):
                state.savedSearches = searches
                return .none
            }
        }
    }
}

// MARK: - Models

struct SavedSearch: Identifiable, Equatable {
    let id: UUID = UUID()
    let origin: String
    let destination: String
    let departureDate: Date
    let returnDate: Date
    let adults: Int
    let children: Int
    let infants: Int
    let travelClass: String
    let createdAt: Date
    
    static func == (lhs: SavedSearch, rhs: SavedSearch) -> Bool {
        lhs.id == rhs.id &&
        lhs.origin == rhs.origin &&
        lhs.destination == rhs.destination &&
        lhs.departureDate == rhs.departureDate &&
        lhs.returnDate == rhs.returnDate &&
        lhs.adults == rhs.adults &&
        lhs.children == rhs.children &&
        lhs.infants == rhs.infants &&
        lhs.travelClass == rhs.travelClass &&
        lhs.createdAt == rhs.createdAt
    }
}
