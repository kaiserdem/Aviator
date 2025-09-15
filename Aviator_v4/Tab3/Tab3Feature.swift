import ComposableArchitecture

struct Tab3Feature: Reducer {
    struct State: Equatable {
        var title = "Flights"
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
