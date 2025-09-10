import ComposableArchitecture

struct NewsFeature: Reducer {
    struct State: Equatable {
        var isLoading: Bool = false
        var posts: [NewsPost] = []
        var selected: NewsPost?
    }
    enum Action: Equatable {
        case onAppear
        case _response([NewsPost])
        case select(NewsPost?)
    }

    @Dependency(\.newsClient) var newsClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    let posts = await newsClient.fetchTop(100)
                    await send(._response(posts))
                }
            case let ._response(posts):
                state.isLoading = false
                state.posts = posts
                return .none
            case let .select(post):
                state.selected = post
                return .none
            }
        }
    }
}


