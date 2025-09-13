import Foundation
import ComposableArchitecture

struct ProfileFeature: Reducer {
    struct State: Equatable {
        var user: AppUser?
        var isLoading = false
        
        init() {
            self.user = nil
            self.isLoading = false
        }
    }
    
    enum Action: Equatable {
        case loadUser
        case logout
        case setUser(AppUser?)
    }
    
    @Dependency(\.amadeusClient) var amadeusClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .loadUser:
                state.isLoading = true
                return .run { send in
                    let user = await amadeusClient.getCurrentUser()
                    await send(.setUser(user))
                }
                
            case .logout:
                return .run { send in
                    await amadeusClient.logout()
                    await send(.setUser(nil))
                }
                
            case let .setUser(user):
                state.user = user
                state.isLoading = false
                return .none
            }
        }
    }
}