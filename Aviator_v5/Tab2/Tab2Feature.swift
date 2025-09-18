import ComposableArchitecture
import Foundation

@Reducer
struct Tab2Feature {
    @ObservableState
    struct State: Equatable {
        var message = "Вкладка 2"
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
