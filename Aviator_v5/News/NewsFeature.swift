import ComposableArchitecture
import Foundation

@Reducer
struct NewsFeature {
    @ObservableState
    struct State: Equatable {
        var isLoading = false
        var errorMessage: String?
        var newsItems: [NewsItem] = []
        var selectedNews: NewsItem?
    }
    
    enum Action: Equatable {
        case onAppear
        case newsLoaded([NewsItem])
        case newsLoadFailed(String)
        case selectNews(NewsItem?)
    }
    
    @Dependency(\.newsClient) var newsClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                state.errorMessage = nil
                
                return .run { send in
                    do {
                        let newsModel = try await newsClient.fetchNews(
                            "avia",
                            "2025-09-01",
                            "96d6a43448504d8fa60ca4cde10987ee"
                        )
                        
                        let newsItems = newsModel.articles.map { article in
                            NewsItem(
                                id: article.url,
                                title: article.title,
                                summary: article.description,
                                date: article.publishedAt,
                                category: article.source.name,
                                url: article.url,
                                imageURL: article.urlToImage
                            )
                        }
                        
                        await send(.newsLoaded(newsItems))
                    } catch {
                        await send(.newsLoadFailed(error.localizedDescription))
                    }
                }
                
            case let .newsLoaded(news):
                state.isLoading = false
                state.newsItems = news
                return .none
                
            case let .newsLoadFailed(error):
                state.isLoading = false
                state.errorMessage = error
                return .none
                
            case let .selectNews(news):
                state.selectedNews = news
                return .none
            }
        }
    }
}

struct NewsItem: Identifiable, Equatable {
    let id: String
    let title: String
    let summary: String
    let date: Date
    let category: String
    let url: String
    let imageURL: String?
}
