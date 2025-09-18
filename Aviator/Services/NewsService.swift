import Foundation
import ComposableArchitecture

struct NewsPost: Identifiable, Equatable, Hashable {
    let id: String
    let title: String
    let url: URL?
    let author: String
    let createdAt: Date
    let description: String
    let imageURL: String?
    let source: String
}

struct NewsClient {
    var fetchTop: @Sendable (_ limit: Int) async -> [NewsPost]
}

extension DependencyValues {
    var newsClient: NewsClient {
        get { self[NewsClientKey.self] }
        set { self[NewsClientKey.self] = newValue }
    }
}

enum NewsClientKey: DependencyKey {
    static let liveValue: NewsClient = .init(fetchTop: { limit in
        var components = URLComponents(string: "https://newsapi.org/v2/everything")!
        components.queryItems = [
            URLQueryItem(name: "q", value: "avia"),
            URLQueryItem(name: "from", value: "2025-09-01"),
            URLQueryItem(name: "sortBy", value: "popularity"),
            URLQueryItem(name: "apiKey", value: "96d6a43448504d8fa60ca4cde10987ee")
        ]
        
        guard let url = components.url else { return mock }
        
        do {
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                return mock
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let newsModel = try decoder.decode(NewsModel.self, from: data)
            
            let posts = newsModel.articles.prefix(limit).map { article in
                NewsPost(
                    id: article.url,
                    title: article.title,
                    url: URL(string: article.url),
                    author: article.author ?? "Unknown",
                    createdAt: article.publishedAt,
                    description: article.description,
                    imageURL: article.urlToImage,
                    source: article.source.name
                )
            }
            
            return Array(posts)
        } catch {
            return mock
        }
    })

    static let testValue: NewsClient = .init(fetchTop: { _ in mock })
}

private let mock: [NewsPost] = [
    NewsPost(
        id: "m1", 
        title: "Airline announces new A321neo routes", 
        url: URL(string: "https://example.com/a321"), 
        author: "avgeek", 
        createdAt: Date().addingTimeInterval(-3600),
        description: "New routes announced for A321neo aircraft",
        imageURL: nil,
        source: "Aviation News"
    ),
    NewsPost(
        id: "m2", 
        title: "737 MAX makes record-breaking flight", 
        url: URL(string: "https://example.com/737"), 
        author: "pilot123", 
        createdAt: Date().addingTimeInterval(-7200),
        description: "737 MAX aircraft achieves new distance record",
        imageURL: nil,
        source: "Flight News"
    )
]


