import ComposableArchitecture

struct Tab4Feature: Reducer {
    struct State: Equatable {
        var title = "Tracker"
        var message = "Coming Soon..."
        
        init() {}
    }
    
    enum Action: Equatable {
        case onAppear
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            }
        }
    }
}
