import ComposableArchitecture
import Foundation

@Reducer
struct AviationFeature {
    @ObservableState
    struct State: Equatable {
        var isLoading = false
        var errorMessage: String?
        var aviationData: [AviationItem] = []
    }
    
    enum Action: Equatable {
        case onAppear
        case dataLoaded([AviationItem])
        case dataLoadFailed(String)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                state.errorMessage = nil
                
                let aviationData = [
                    AviationItem(
                        id: "1",
                        title: "Aviation Sports",
                        description: "Various types of aviation sports disciplines",
                        category: "Sports"
                    ),
                    AviationItem(
                        id: "2",
                        title: "Aviation Technology",
                        description: "Modern aircraft and helicopters",
                        category: "Technology"
                    ),
                    AviationItem(
                        id: "3",
                        title: "Aviation History",
                        description: "Important events in aviation history",
                        category: "History"
                    )
                ]
                
                return .run { send in
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                    await send(.dataLoaded(aviationData))
                }
                
            case let .dataLoaded(data):
                state.isLoading = false
                state.aviationData = data
                return .none
                
            case let .dataLoadFailed(error):
                state.isLoading = false
                state.errorMessage = error
                return .none
            }
        }
    }
}

struct AviationItem: Identifiable, Equatable {
    let id: String
    let title: String
    let description: String
    let category: String
}
