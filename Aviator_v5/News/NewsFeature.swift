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
        var totalFromAPI = 0
        var filteredCount = 0
    }
    
    enum Action: Equatable {
        case onAppear
        case newsLoaded([NewsItem], totalFromAPI: Int, filteredCount: Int)
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
                            "flight",
                            "2025-09-01",
                            "96d6a43448504d8fa60ca4cde10987ee"
                        )
                        
                        let allArticles = newsModel.articles.map { article in
                            NewsItem(
                                id: article.url,
                                title: article.title,
                                summary: article.description ?? "No description available",
                                date: article.publishedAt,
                                category: article.source.name,
                                url: article.url,
                                imageURL: article.urlToImage
                            )
                        }
                        
                        // Фільтруємо новини за авіаційними темами
                        let aviationKeywords = ["авіація", "політ", "рейс", "космос", "небо", "aviation", "flight", "aircraft", "airplane", "space", "spacecraft", "rocket", "satellite", "pilot", "airline", "airport", "airspace", "aerospace", "helicopter", "drone", "jet", "boeing", "airbus", "spacex", "nasa"]
                        
                        let filteredNews = allArticles.filter { newsItem in
                            let titleLower = newsItem.title.lowercased()
                            let summaryLower = newsItem.summary.lowercased()
                            
                            return aviationKeywords.contains { keyword in
                                titleLower.contains(keyword.lowercased()) || 
                                summaryLower.contains(keyword.lowercased())
                            }
                        }
                        
                        print("📊 News Filtering Results:")
                        print("   Total articles from API: \(allArticles.count)")
                        print("   Aviation-related articles: \(filteredNews.count)")
                        print("   Filtered out: \(allArticles.count - filteredNews.count)")
                        
                        let newsItems = filteredNews
                        
                        await send(.newsLoaded(newsItems, totalFromAPI: allArticles.count, filteredCount: filteredNews.count))
                    } catch {
                        await send(.newsLoadFailed(error.localizedDescription))
                    }
                }
                
            case let .newsLoaded(news, totalFromAPI, filteredCount):
                state.isLoading = false
                state.newsItems = news
                state.totalFromAPI = totalFromAPI
                state.filteredCount = filteredCount
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
