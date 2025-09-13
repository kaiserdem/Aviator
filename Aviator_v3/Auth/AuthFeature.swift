import Foundation
import ComposableArchitecture

struct AuthFeature: Reducer {
    struct State: Equatable {
        var isAuthenticated = false
        var currentUser: AppUser?
        var isLoading = false
        var errorMessage: String?
        
        // Login state
        var loginEmail = ""
        var loginPassword = ""
        
        // Register state
        var registerEmail = ""
        var registerPassword = ""
        var registerFirstName = ""
        var registerLastName = ""
        
        // UI state
        var showingLogin = true
        var showingAuth = false
        
        init() {
            self.isAuthenticated = false
            self.currentUser = nil
            self.isLoading = false
            self.errorMessage = nil
            self.loginEmail = ""
            self.loginPassword = ""
            self.registerEmail = ""
            self.registerPassword = ""
            self.registerFirstName = ""
            self.registerLastName = ""
            self.showingLogin = true
            self.showingAuth = false
        }
    }
    
    enum Action: Equatable {
        case checkAuthStatus
        case login(String, String)
        case register(String, String, String, String)
        case logout
        case setCurrentUser(AppUser?)
        case setLoading(Bool)
        case setError(String?)
        case updateLoginEmail(String)
        case updateLoginPassword(String)
        case updateRegisterEmail(String)
        case updateRegisterPassword(String)
        case updateRegisterFirstName(String)
        case updateRegisterLastName(String)
        case toggleAuthMode
        case showAuth(Bool)
    }
    
    @Dependency(\.amadeusClient) var amadeusClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .checkAuthStatus:
                state.isLoading = true
                return .run { send in
                    let user = await amadeusClient.getCurrentUser()
                    await send(.setCurrentUser(user))
                }
                
            case let .login(email, password):
                state.isLoading = true
                state.errorMessage = nil
                return .run { send in
                    let user = await amadeusClient.login(email, password)
                    await send(.setCurrentUser(user))
                }
                
            case let .register(email, password, firstName, lastName):
                state.isLoading = true
                state.errorMessage = nil
                return .run { send in
                    let user = await amadeusClient.register(email, password, firstName, lastName)
                    await send(.setCurrentUser(user))
                }
                
            case .logout:
                return .run { send in
                    await amadeusClient.logout()
                    await send(.setCurrentUser(nil))
                }
                
            case let .setCurrentUser(user):
                state.currentUser = user
                state.isAuthenticated = user != nil
                state.isLoading = false
                if user != nil {
                    state.showingAuth = false
                } else {
                    // Set error message if login failed
                    state.errorMessage = "Невірний email або пароль. Спробуйте ще раз."
                }
                return .none
                
            case let .setLoading(isLoading):
                state.isLoading = isLoading
                return .none
                
            case let .setError(error):
                state.errorMessage = error
                state.isLoading = false
                return .none
                
            case let .updateLoginEmail(email):
                state.loginEmail = email
                return .none
                
            case let .updateLoginPassword(password):
                state.loginPassword = password
                return .none
                
            case let .updateRegisterEmail(email):
                state.registerEmail = email
                return .none
                
            case let .updateRegisterPassword(password):
                state.registerPassword = password
                return .none
                
            case let .updateRegisterFirstName(firstName):
                state.registerFirstName = firstName
                return .none
                
            case let .updateRegisterLastName(lastName):
                state.registerLastName = lastName
                return .none
                
            case .toggleAuthMode:
                state.showingLogin.toggle()
                state.errorMessage = nil
                return .none
                
            case let .showAuth(show):
                state.showingAuth = show
                return .none
            }
        }
    }
}
