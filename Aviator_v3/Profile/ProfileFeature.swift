import ComposableArchitecture
import Foundation

struct ProfileFeature: Reducer {
    struct State: Equatable {
        var user: User?
        var isLoading = false
        var isLoggedIn = false
    }

    enum Action: Equatable {
        case onAppear
        case login(String, String)
        case logout
        case _userResponse(User?)
    }

    @Dependency(\.amadeusClient) var amadeusClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    let user = await amadeusClient.getCurrentUser()
                    await send(._userResponse(user))
                }
                
            case let .login(email, password):
                state.isLoading = true
                return .run { send in
                    let user = await amadeusClient.login(email, password)
                    await send(._userResponse(user))
                }
                
            case .logout:
                state.user = nil
                state.isLoggedIn = false
                return .none
                
            case let ._userResponse(user):
                state.isLoading = false
                state.user = user
                state.isLoggedIn = user != nil
                return .none
            }
        }
    }
}

// MARK: - Models

struct User: Identifiable, Equatable {
    let id: UUID = UUID()
    let email: String
    let firstName: String
    let lastName: String
    let phoneNumber: String?
    let preferences: UserPreferences
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id &&
        lhs.email == rhs.email &&
        lhs.firstName == rhs.firstName &&
        lhs.lastName == rhs.lastName &&
        lhs.phoneNumber == rhs.phoneNumber &&
        lhs.preferences == rhs.preferences
    }
}

struct UserPreferences: Equatable {
    let preferredAirline: String?
    let preferredSeat: String?
    let preferredMeal: String?
    let notificationsEnabled: Bool
    
    static func == (lhs: UserPreferences, rhs: UserPreferences) -> Bool {
        lhs.preferredAirline == rhs.preferredAirline &&
        lhs.preferredSeat == rhs.preferredSeat &&
        lhs.preferredMeal == rhs.preferredMeal &&
        lhs.notificationsEnabled == rhs.notificationsEnabled
    }
}
